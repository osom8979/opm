# -*- coding: utf-8 -*-

import os
import sys
from argparse import ArgumentParser, Namespace, RawDescriptionHelpFormatter
from datetime import datetime, timedelta
from json import JSONEncoder, dumps
from logging import DEBUG, StreamHandler, getLogger
from pathlib import Path
from pprint import pprint
from typing import Any, Dict, Final, List, Optional, Sequence, Tuple, Union
from urllib.parse import urlparse

from requests import Session
from requests.auth import HTTPBasicAuth, HTTPDigestAuth
from wsdiscovery.discovery import ThreadedWSDiscovery
from zeep import Client
from zeep.cache import Base as ZeepCacheBase
from zeep.helpers import serialize_object
from zeep.proxy import ServiceProxy
from zeep.transports import Transport
from zeep.wsse.username import UsernameToken

PROG: Final[str] = "opy-onvif"
EPILOG = f"""
ONVIF device discovery:
  {PROG} -j WS-Discovery | jq '.[].XAddrs[]'

Obtain a list of device capabilities:
  {PROG} -j -a [URL] GetCapabilities | jq '.[].XAddr'

If authentication is required:
  {PROG} -u 'admin' -p '1q2w3e4r5t!' -a [URL] ...
  {PROG} -u 'admin' -p '1q2w3e4r5t!' --use-digest -a [URL] ...
  {PROG} -u 'admin' -p '1q2w3e4r5t!' --with-http-basic -a [URL] ...
  {PROG} -u 'admin' -p '1q2w3e4r5t!' --use-digest --with-http-digest -a [URL] ...

Obtain a list of media profiles:
  {PROG} -j -a [URL] GetProfiles | jq '.[].token'

Obtain a stream URI:
  {PROG} -j -a [URL] GetStreamUri [TOKEN] | jq '.Uri'

Obtain a snapshot URI:
  {PROG} -j -a [URL] GetSnapshotUri [TOKEN] | jq '.Uri'
"""

ONVIF_V10_SCHEMA_URL: Final[str] = "http://www.onvif.org/ver10/schema"

TRANSPORT_PROTOCOL_UDP: Final[str] = "UDP"
TRANSPORT_PROTOCOL_TCP: Final[str] = "TCP"  # Deprecated
TRANSPORT_PROTOCOL_RTSP: Final[str] = "RTSP"
TRANSPORT_PROTOCOL_HTTP: Final[str] = "HTTP"
TRANSPORT_PROTOCOLS: Sequence[str] = (
    TRANSPORT_PROTOCOL_UDP,
    TRANSPORT_PROTOCOL_TCP,
    TRANSPORT_PROTOCOL_RTSP,
    TRANSPORT_PROTOCOL_HTTP,
)

_UDP: Final[str] = TRANSPORT_PROTOCOL_UDP
_TCP: Final[str] = TRANSPORT_PROTOCOL_TCP
_RTSP: Final[str] = TRANSPORT_PROTOCOL_RTSP
_HTTP: Final[str] = TRANSPORT_PROTOCOL_HTTP
_PROTOCOLS: Sequence[str] = TRANSPORT_PROTOCOLS

STREAM_TYPE_RTP_UNICAST: Final[str] = "RTP-Unicast"
STREAM_TYPE_RTP_MULTICAST: Final[str] = "RTP-Multicast"
STREAM_TYPES: Sequence[str] = (STREAM_TYPE_RTP_UNICAST, STREAM_TYPE_RTP_MULTICAST)

_RTP_UNICAST: Final[str] = STREAM_TYPE_RTP_UNICAST
_RTP_MULTICAST: Final[str] = STREAM_TYPE_RTP_MULTICAST
_STREAMS: Sequence[str] = STREAM_TYPES

PROFILE_TOKEN_MAX_LENGTH: Final[int] = 64

logger = getLogger("opm.onvif")


def default_logger_setup():
    logger.addHandler(StreamHandler(sys.stderr))
    logger.setLevel(DEBUG)


def find_default_wsdl_cache_dir() -> str:
    """
    Default cache folder location to use when used within an OPM library.
    """

    temp_cache_dir = os.path.join(os.path.dirname(__file__), "wsdl")
    opm_home_dir = os.environ.get("OPM_HOME", None)

    if opm_home_dir is None:
        current_dir = os.path.dirname(__file__)
        current_dirname = os.path.basename(current_dir)
        if current_dirname != "python3":
            return temp_cache_dir

        parent_dir = os.path.dirname(current_dir)
        parent_dirname = os.path.basename(parent_dir)
        if parent_dirname != "lib":
            return temp_cache_dir

        opm_home_dir = os.path.dirname(parent_dir)

    var_dir = os.path.join(opm_home_dir, "var")
    if not os.path.isdir(var_dir):
        return temp_cache_dir

    wsdl_dir = os.path.join(var_dir, "wsdl")
    if not os.path.isdir(wsdl_dir):
        return temp_cache_dir

    return wsdl_dir


class ZeepFileCache(ZeepCacheBase):
    def __init__(self, prefix: str):
        super().__init__()
        self._prefix = prefix

    def get_cache_path(self, url: str) -> Path:
        o = urlparse(url)
        return Path(os.path.join(self._prefix, o.hostname, *o.path.split("/")))

    def add(self, url: str, content: Any):
        filepath = self.get_cache_path(url)
        filepath.parent.mkdir(parents=True, exist_ok=True)
        try:
            if not filepath.exists():
                with filepath.open("wb") as f:
                    f.write(content)
        except BaseException as e:  # noqa
            logger.error(f"ZeepFileCache.add(url={url}) error: {e}")
        else:
            logger.debug(f"ZeepFileCache.add(url={url}) ok")

    def get(self, url: str):
        filepath = self.get_cache_path(url)
        try:
            if filepath.is_file():
                with filepath.open("rb") as f:
                    return f.read()
        except BaseException as e:  # noqa
            logger.error(f"ZeepFileCache.get(url={url}) error: {e}")
        else:
            logger.debug(f"ZeepFileCache.get(url={url}) ok")
        return None


class OnvifWsdlDeclaration:
    def __init__(
        self,
        declaration: str,
        http_sub: str,
        wsdl_file: str,
        subclass: str,
        binding_names: Optional[List[str]] = None,
    ):
        self.declaration = declaration
        self.http_sub = http_sub
        self.wsdl_file = wsdl_file
        self.subclass = subclass

        # <wsdl:binding name="???" ...> ... </wsdl:binding>
        self.binding_names = binding_names if binding_names else list()

    @property
    def wsdl_file_url(self) -> str:
        return self.declaration + "/" + self.wsdl_file

    def create_client(
        self,
        wsse: Optional[UsernameToken] = None,
        cache_dir: Optional[str] = None,
        with_http_basic=False,
        with_http_digest=False,
    ):
        cache = ZeepFileCache(cache_dir) if cache_dir else None
        session = Session()
        if wsse:
            if with_http_basic and with_http_digest:
                raise ValueError(
                    "The 'with_http_basic' and 'with_http_digest' flags cannot coexist"
                )
            if with_http_basic:
                assert not with_http_digest
                session.auth = HTTPBasicAuth(wsse.username, wsse.password)
            if with_http_digest:
                assert not with_http_basic
                if not wsse.use_digest:
                    logger.warning("<UsernameToken> should be encoded as a digest.")
                session.auth = HTTPDigestAuth(wsse.username, wsse.password)
        transport = Transport(cache=cache, session=session)
        return Client(wsdl=self.wsdl_file_url, wsse=wsse, transport=transport)

    def get_service_binding_name(self, index_or_name: Union[str, int] = 0) -> str:
        if isinstance(index_or_name, int):
            return "{" + self.declaration + "}" + self.binding_names[index_or_name]
        else:
            return "{" + self.declaration + "}" + index_or_name


ONVIF_DECL_DEVICE_MANAGEMENT = OnvifWsdlDeclaration(
    declaration="http://www.onvif.org/ver10/device/wsdl",
    http_sub="device_service",
    wsdl_file="devicemgmt.wsdl",
    subclass="DeviceManagement",
    binding_names=["DeviceBinding"],
)
ONVIF_DECL_MEDIA = OnvifWsdlDeclaration(
    declaration="http://www.onvif.org/ver10/media/wsdl",
    http_sub="Media",
    wsdl_file="media.wsdl",
    subclass="Media",
    binding_names=["MediaBinding"],
)
ONVIF_DECL_EVENTS = OnvifWsdlDeclaration(
    declaration="http://www.onvif.org/ver10/events/wsdl",
    http_sub="Events",
    wsdl_file="events.wsdl",
    subclass="Events",
)
ONVIF_DECL_PTZ = OnvifWsdlDeclaration(
    declaration="http://www.onvif.org/ver20/ptz/wsdl",
    http_sub="PTZ",
    wsdl_file="ptz.wsdl",
    subclass="PTZ",
    binding_names=["PTZBinding"],
)
ONVIF_DECL_IMAGING = OnvifWsdlDeclaration(
    declaration="http://www.onvif.org/ver20/imaging/wsdl",
    http_sub="Imaging",
    wsdl_file="imaging.wsdl",
    subclass="Imaging",
    binding_names=["ImagingBinding"],
)
ONVIF_DECL_DEVICE_IO = OnvifWsdlDeclaration(
    declaration="http://www.onvif.org/ver10/deviceIO/wsdl",
    http_sub="DeviceIO",
    wsdl_file="deviceio.wsdl",
    subclass="DeviceIO",
)
ONVIF_DECL_ANALYTICS = OnvifWsdlDeclaration(
    declaration="http://www.onvif.org/ver20/analytics/wsdl",
    http_sub="Analytics",
    wsdl_file="analytics.wsdl",
    subclass="Analytics",
    binding_names=["RuleEngineBinding", "AnalyticsEngineBinding"],
)

ONVIF_DECLS: Sequence[OnvifWsdlDeclaration] = (
    ONVIF_DECL_DEVICE_MANAGEMENT,
    ONVIF_DECL_MEDIA,
    # ONVIF_DECL_EVENTS,
    ONVIF_DECL_PTZ,
    ONVIF_DECL_IMAGING,
    # ONVIF_DECL_DEVICE_IO,
    ONVIF_DECL_ANALYTICS,
)


def dumps_default(o: Any) -> Any:
    if isinstance(o, datetime):
        return o.isoformat()
    elif isinstance(o, timedelta):
        return o.total_seconds()
    try:
        return JSONEncoder().default(o)
    except TypeError:
        return str(o)


def create_username_token(
    username: Optional[str],
    password: Optional[str],
    use_digest=False,
) -> Optional[UsernameToken]:
    if not username:
        return None
    if not password:
        return None
    return UsernameToken(username=username, password=password, use_digest=use_digest)


def create_username_token_with_namespace(args: Namespace) -> Optional[UsernameToken]:
    assert isinstance(args.username, (type(None), str))
    assert isinstance(args.password, (type(None), str))
    assert isinstance(args.use_digest, bool)
    return create_username_token(args.username, args.password, args.use_digest)


def create_client_and_service(
    decl: OnvifWsdlDeclaration,
    args: Namespace,
) -> Tuple[Client, ServiceProxy]:
    if not args.address:
        raise ValueError("The 'address' argument is required.")

    assert isinstance(args.no_cache, bool)
    assert isinstance(args.cache_dir, str)
    assert isinstance(args.with_http_basic, bool)
    assert isinstance(args.with_http_digest, bool)
    client = decl.create_client(
        wsse=create_username_token_with_namespace(args),
        cache_dir=None if args.no_cache else args.cache_dir,
        with_http_basic=args.with_http_basic,
        with_http_digest=args.with_http_digest,
    )
    binding_name = decl.get_service_binding_name()
    service = client.create_service(binding_name, args.address)
    return client, service


def create_service(decl: OnvifWsdlDeclaration, args: Namespace) -> ServiceProxy:
    return create_client_and_service(decl, args)[1]


def ws_discovery_dict() -> List[Dict[str, any]]:
    wsd = ThreadedWSDiscovery()
    wsd.start()
    try:
        result = list()
        for service in wsd.searchServices():
            item = dict()
            item["EPR"] = service.getEPR()
            item["InstanceId"] = service.getInstanceId()
            item["MessageNumber"] = service.getMessageNumber()
            item["MetadataVersion"] = service.getMetadataVersion()
            item["Scopes"] = [s.getValue() for s in service.getScopes()]
            item["Types"] = [t.getFullname() for t in service.getTypes()]
            item["XAddrs"] = [a for a in service.getXAddrs()]
            result.append(item)
        return result
    finally:
        wsd.stop()


def ws_discovery(args: Namespace):
    assert args
    return ws_discovery_dict()


# ------------------------------------------------------
# http://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl
# ------------------------------------------------------

def get_system_date_and_time(args: Namespace):
    service = create_service(ONVIF_DECL_DEVICE_MANAGEMENT, args)
    return service.GetSystemDateAndTime()


def get_capabilities(args: Namespace):
    """
    This method has been replaced by the more generic GetServices method.
    For capabilities of individual services refer to the GetServiceCapabilities methods.
    """
    service = create_service(ONVIF_DECL_DEVICE_MANAGEMENT, args)
    return service.GetCapabilities()


def get_services(args: Namespace):
    assert isinstance(args.IncludeCapability, bool)
    service = create_service(ONVIF_DECL_DEVICE_MANAGEMENT, args)
    return service.GetServices(IncludeCapability=args.IncludeCapability)


def get_device_information(args: Namespace):
    service = create_service(ONVIF_DECL_DEVICE_MANAGEMENT, args)
    return service.GetDeviceInformation()


# ------------------------------------------------------
# http://www.onvif.org/ver10/media/wsdl/media.wsdl
# ------------------------------------------------------


def get_profiles(args: Namespace):
    service = create_service(ONVIF_DECL_MEDIA, args)
    return service.GetProfiles()


def get_stream_uri(args: Namespace):
    assert isinstance(args.Protocol, str)
    assert isinstance(args.Stream, str)
    assert isinstance(args.ProfileToken, str)
    assert args.Protocol in TRANSPORT_PROTOCOLS
    if args.Protocol == TRANSPORT_PROTOCOL_TCP:
        logger.warning(f"'{TRANSPORT_PROTOCOL_TCP}' protocol is deprecated")
    assert args.Stream in STREAM_TYPES
    assert len(args.ProfileToken) <= PROFILE_TOKEN_MAX_LENGTH

    client, service = create_client_and_service(ONVIF_DECL_MEDIA, args)
    schema = client.type_factory(namespace=ONVIF_V10_SCHEMA_URL)
    transport = schema.Transport(Protocol=args.Protocol)
    setup = schema.StreamSetup(Stream=args.Stream, Transport=transport)
    return service.GetStreamUri(StreamSetup=setup, ProfileToken=args.ProfileToken)


def get_snapshot_uri(args: Namespace):
    assert isinstance(args.ProfileToken, str)
    assert len(args.ProfileToken) <= PROFILE_TOKEN_MAX_LENGTH

    service = create_service(ONVIF_DECL_MEDIA, args)
    return service.GetSnapshotUri(ProfileToken=args.ProfileToken)


def get_default_arguments(
    cmdline: Optional[List[str]] = None,
    namespace: Optional[Namespace] = None,
    default_cache_dir: Optional[str] = None,
) -> Namespace:
    parser = ArgumentParser(
        prog=PROG,
        epilog=EPILOG,
        formatter_class=RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--address",
        "-a",
        metavar="{uri}",
        default="",
        help="URI to request ONVIF service",
    )
    parser.add_argument(
        "--username",
        "-u",
        metavar="{id}",
        default=None,
        help="Username for <UsernameToken>",
    )
    parser.add_argument(
        "--password",
        "-p",
        metavar="{pw}",
        default=None,
        help="Password for <UsernameToken>",
    )
    parser.add_argument(
        "--use-digest",
        "-d",
        action="store_true",
        default=False,
        help="Digest-encode <UsernameToken>",
    )
    parser.add_argument(
        "--with-http-basic",
        "-B",
        action="store_true",
        default=False,
        help="Add Basic authentication to the HTTP Authorization header.",
    )
    parser.add_argument(
        "--with-http-digest",
        "-D",
        action="store_true",
        default=False,
        help="Add Digest authentication to the HTTP Authorization header.",
    )
    parser.add_argument(
        "--use-json",
        "-j",
        action="store_true",
        default=False,
        help="The final result is output in JSON format.",
    )
    parser.add_argument(
        "--json-indent",
        "-i",
        metavar="{indent}",
        type=int,
        default=4,
        help="When outputting JSON, pretty-printed with that indent level."
    )
    parser.add_argument(
        "--json-sort",
        "-s",
        action="store_true",
        default=False,
        help="When outputting JSON, sort by key.",
    )
    parser.add_argument(
        "--no-cache",
        action="store_true",
        default=False,
        help="Do not save the WSDL schema as a file.",
    )
    parser.add_argument(
        "--cache-dir",
        metavar="{dir}",
        default=default_cache_dir,
        help=f"Specify WSDL cache directory (default: '{default_cache_dir}')",
    )
    subparsers = parser.add_subparsers(dest="cmd")

    discovery = subparsers.add_parser(
        name="WS-Discovery",
        help="Discover ONVIF devices.",
    )
    discovery.set_defaults(func=ws_discovery)

    dt = subparsers.add_parser(
        name="GetSystemDateAndTime",
        help="This operation gets the device system date and time.",
    )
    dt.set_defaults(func=get_system_date_and_time)

    caps = subparsers.add_parser(
        name="GetCapabilities",
        help="Returns the capabilities of the device service.",
    )
    caps.set_defaults(func=get_capabilities)

    services = subparsers.add_parser(
        name="GetServices",
        help="Returns information about services on the device.",
    )
    services.add_argument("-IncludeCapability", action="store_true", default=False)
    services.set_defaults(func=get_services)

    info = subparsers.add_parser(
        name="GetDeviceInformation",
        help="Gets basic device information from the device.",
    )
    info.set_defaults(func=get_device_information)

    profiles = subparsers.add_parser(
        name="GetProfiles",
        help="Get a list of media profiles.",
    )
    profiles.set_defaults(func=get_profiles)

    stream_uri = subparsers.add_parser(
        name="GetStreamUri",
        help="Obtain the RTSP stream address.",
    )
    stream_uri.add_argument("-Protocol", choices=_PROTOCOLS, default=_RTSP)
    stream_uri.add_argument("-Stream", choices=_STREAMS, default=_RTP_UNICAST)
    stream_uri.add_argument("ProfileToken")
    stream_uri.set_defaults(func=get_stream_uri)

    snapshot_uri = subparsers.add_parser(
        name="GetSnapshotUri",
        help="Obtain a JPEG snapshot from the device.",
    )
    snapshot_uri.add_argument("ProfileToken")
    snapshot_uri.set_defaults(func=get_snapshot_uri)

    return parser.parse_known_args(cmdline, namespace)[0]


def main() -> None:
    default_logger_setup()
    default_cache_dir = find_default_wsdl_cache_dir()
    args = get_default_arguments(default_cache_dir=default_cache_dir)

    if args.cmd is None:
        print("Empty command", file=sys.stderr)
        sys.exit(1)

    try:
        o = serialize_object(args.func(args), dict)
        assert isinstance(args.use_json, bool)
        if args.use_json:
            assert isinstance(args.json_indent, int)
            assert isinstance(args.json_sort, bool)
            indent = args.json_indent
            sort = args.json_sort
            json = dumps(o, indent=indent, sort_keys=sort, default=dumps_default)
            print(json)
        else:
            pprint(o)
    except Exception as e:
        logger.exception(e)
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()
