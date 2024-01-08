# -*- coding: utf-8 -*-

import os
from argparse import ArgumentParser, Namespace
from logging import getLogger
from pathlib import Path
from typing import Any, Final, List, Optional, Sequence
from urllib.parse import urlparse

from zeep import Client
from zeep.cache import Base as ZeepCacheBase
from zeep.transports import Transport
from zeep.wsse.username import UsernameToken

PROG: Final[str] = "opy-onvif"
OPM_LIB_DIR: Final[str] = os.path.dirname(os.path.dirname(__file__))
OPM_HOME: Final[str] = os.environ.get("OPM_HOME", os.path.dirname(OPM_LIB_DIR))
CACHE_DIR: Final[str] = os.path.join(OPM_HOME, "var", "wsdl")

logger = getLogger()


class ZeepFileCache(ZeepCacheBase):
    def __init__(self, prefix: Optional[str] = None):
        super().__init__()
        self._prefix = prefix if prefix else CACHE_DIR

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
            logger.info(f"ZeepFileCache.add(url={url}) ok")

    def get(self, url: str):
        filepath = self.get_cache_path(url)
        try:
            if filepath.is_file():
                with filepath.open("rb") as f:
                    return f.read()
        except BaseException as e:  # noqa
            logger.error(f"ZeepFileCache.get(url={url}) error: {e}")
        else:
            logger.info(f"ZeepFileCache.get(url={url}) ok")
        return None


class OnvifWsdlDeclaration:
    def __init__(
        self,
        declaration: str,
        http_sub: str,
        wsdl_file: str,
        subclass: str,
    ):
        self.declaration = declaration
        self.http_sub = http_sub
        self.wsdl_file = wsdl_file
        self.subclass = subclass

    @property
    def wsdl_file_url(self) -> str:
        return self.declaration + "/" + self.wsdl_file

    def create_client(self, wsse: Optional[UsernameToken] = None):
        return Client(
            wsdl=self.wsdl_file_url,
            wsse=wsse,
            transport=Transport(cache=ZeepFileCache()),
        )


ONVIF_DECL_DEVICE_MANAGEMENT = OnvifWsdlDeclaration(
    declaration="http://www.onvif.org/ver10/device/wsdl",
    http_sub="device_service",
    wsdl_file="devicemgmt.wsdl",
    subclass="DeviceManagement",
)
ONVIF_DECL_MEDIA = OnvifWsdlDeclaration(
    declaration="http://www.onvif.org/ver10/media/wsdl",
    http_sub="Media",
    wsdl_file="media.wsdl",
    subclass="Media",
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
)
ONVIF_DECL_IMAGING = OnvifWsdlDeclaration(
    declaration="http://www.onvif.org/ver20/imaging/wsdl",
    http_sub="Imaging",
    wsdl_file="imaging.wsdl",
    subclass="Imaging",
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
)

ONVIF_DECLS: Sequence[OnvifWsdlDeclaration] = (
    ONVIF_DECL_DEVICE_MANAGEMENT,
    ONVIF_DECL_MEDIA,
    ONVIF_DECL_EVENTS,
    ONVIF_DECL_PTZ,
    ONVIF_DECL_IMAGING,
    ONVIF_DECL_DEVICE_IO,
    ONVIF_DECL_ANALYTICS,
)


def get_default_arguments(
    cmdline: Optional[List[str]] = None,
    namespace: Optional[Namespace] = None,
) -> Namespace:
    parser = ArgumentParser(prog=PROG)
    parser.add_argument("--user", "-u", help="User ID")
    parser.add_argument("--password", "-p", help="User Password")
    parser.add_argument("--use-digest", action="store_true", default=False)
    parser.add_argument("address", help="ONVIF Device Service Address")
    return parser.parse_known_args(cmdline, namespace)[0]


def main() -> None:
    args = get_default_arguments()
    assert isinstance(args.address, str)

    for decl in ONVIF_DECLS:
        _ = decl.create_client()

    # binding_name = "{http://www.onvif.org/ver10/device/wsdl}DeviceBinding"
    # client = ONVIF_DECL_DEVICE_MANAGEMENT.create_client()
    # service = client.create_service(binding_name=binding_name, address=args.address)
    # # print(service.GetCapabilities())


if __name__ == "__main__":
    main()
