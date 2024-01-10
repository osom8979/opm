# -*- coding: utf-8 -*-

import sys
import os

from argparse import ArgumentParser, Namespace, RawDescriptionHelpFormatter
from typing import Final, List, Optional

from boto3 import resource as boto3_resource

PROG: Final[str] = "opy-s3"


class S3Client:
    def __init__(
        self,
        endpoint: str,
        access: str,
        secret: str,
        region: str,
        bucket: str,
    ):
        self._s3 = boto3_resource(
            service_name="s3",
            endpoint_url=endpoint,
            aws_access_key_id=access,
            aws_secret_access_key=secret,
            region_name=region,
        )
        self._bucket = self._s3.Bucket(bucket)

    @classmethod
    def from_args(cls, args: Namespace):
        assert isinstance(args.endpoint, (type(None), str))
        assert isinstance(args.access, (type(None), str))
        assert isinstance(args.secret, (type(None), str))
        assert isinstance(args.region, (type(None), str))
        assert isinstance(args.bucket, (type(None), str))
        endpoint = args.endpoint
        access = args.access
        secret = args.secret
        region = args.region
        bucket = args.bucket

        if not all((endpoint, access, secret, region, bucket)):
            raise ValueError("Invalid S3 params")

        assert isinstance(endpoint, str)
        assert isinstance(access, str)
        assert isinstance(secret, str)
        assert isinstance(region, str)
        assert isinstance(bucket, str)

        return cls(
            endpoint=endpoint,
            access=access,
            secret=secret,
            region=region,
            bucket=bucket,
        )

    @property
    def objects(self):
        return [obj for obj in self._bucket.objects.all()]

    @property
    def keys(self):
        return [obj.key for obj in self.objects]

    def exists_file(self, key: str) -> bool:
        try:
            self._bucket.Object(key).load()
        except:  # noqa
            return False
        else:
            return True

    def upload_file(self, filename: str, key: str):
        return self._bucket.Object(key).upload_file(filename)

    def download_file(self, key: str, filename: str):
        return self._bucket.Object(key).download_file(filename)


def launch_get(args: Namespace) -> None:
    s3 = S3Client.from_args(args)
    assert isinstance(args.remote, str)
    assert isinstance(args.host, str)
    if os.path.exists(args.host):
        raise FileExistsError(f"Host file already exists: '{args.host}'")
    s3.download_file(args.remote, args.host)


def launch_put(args: Namespace) -> None:
    s3 = S3Client.from_args(args)
    assert isinstance(args.host, str)
    assert isinstance(args.remote, str)
    if not os.path.exists(args.host):
        raise FileNotFoundError(f"Host file not found: '{args.host}'")
    s3.upload_file(args.host, args.remote)


def launch_ls(args: Namespace) -> None:
    s3 = S3Client.from_args(args)
    print(s3.keys)


def get_default_arguments(
    cmdline: Optional[List[str]] = None,
    namespace: Optional[Namespace] = None,
) -> Namespace:
    parser = ArgumentParser(prog=PROG, formatter_class=RawDescriptionHelpFormatter)
    parser.add_argument(
        "--endpoint",
        default=os.environ.get("S3_ENDPOINT"),
        metavar="url",
        help="S3 Endpoint URL",
    )
    parser.add_argument(
        "--access",
        default=os.environ.get("S3_ACCESS"),
        metavar="key",
        help="S3 Access Key ID",
    )
    parser.add_argument(
        "--secret",
        default=os.environ.get("S3_SECRET"),
        metavar="key",
        help="S3 Secret Access Key",
    )
    parser.add_argument(
        "--region",
        default=os.environ.get("S3_REGION"),
        metavar="region",
        help="S3 Region Name",
    )
    parser.add_argument(
        "--bucket",
        default=os.environ.get("S3_BUCKET"),
        metavar="bucket",
        help="S3 Bucket Name",
    )
    subparsers = parser.add_subparsers(dest="cmd")

    get = subparsers.add_parser(name="get")
    get.add_argument("remote")
    get.add_argument("host")
    get.set_defaults(func=launch_get)

    put = subparsers.add_parser(name="put")
    get.add_argument("host")
    get.add_argument("remote")
    put.set_defaults(func=launch_put)

    ls = subparsers.add_parser(name="ls")
    get.add_argument("remote")
    ls.set_defaults(func=launch_ls)

    return parser.parse_known_args(cmdline, namespace)[0]


def main() -> None:
    args = get_default_arguments()

    if args.cmd is None:
        print("Empty command", file=sys.stderr)
        sys.exit(1)

    args.func(args)


if __name__ == "__main__":
    main()
