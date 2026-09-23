#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import os
import sys
from argparse import ArgumentParser, Namespace, RawDescriptionHelpFormatter
from pathlib import Path
from typing import Any, Dict, Final, Iterable, List, Optional

from PIL import Image

PROG: Final[str] = "opm-yolo2labelme"
DESCRIPTION: Final[str] = """
Convert YOLO (detect/segment) labels to labelme JSON.

Each JSON file is written next to its image with the same stem (e.g. 100.png -> 100.json).
  - 5 values  (cls cx cy w h)          -> rectangle
  - 7+ values (cls x1 y1 x2 y2 x3 y3 ...) -> polygon
"""
EPILOG: Final[str] = """
Label lookup order (when --labels is not given):
  1. <image_dir>/<stem>.txt
  2. last 'images' path component replaced by 'labels'
  3. every 'images' path component replaced by 'labels'

Class names: --names > --data > data.yaml/dataset.yaml found in input's parent dirs > class id.

Examples:
  {prog} dataset/images/train
  {prog} -r dataset/images --data dataset/data.yaml
  {prog} images/ --labels labels/ --names person,car --overwrite
""".format(prog=PROG)

IMAGE_EXTS: Final[frozenset] = frozenset(
    {".png", ".jpg", ".jpeg", ".bmp", ".tif", ".tiff", ".webp"}
)
DATA_YAML_NAMES: Final[tuple] = ("data.yaml", "dataset.yaml", "data.yml", "dataset.yml")
DEFAULT_LABELME_VERSION: Final[str] = "5.2.1"
DEFAULT_DECIMALS: Final[int] = 2


def get_default_arguments(
    cmdline: Optional[List[str]] = None,
    namespace: Optional[Namespace] = None,
) -> Namespace:
    parser = ArgumentParser(
        prog=PROG,
        description=DESCRIPTION,
        epilog=EPILOG,
        formatter_class=RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "inputs",
        nargs="+",
        help="Image files or directories",
    )
    parser.add_argument(
        "--labels",
        "-l",
        default=None,
        help="YOLO label directory (default: auto-detect)",
    )
    parser.add_argument(
        "--data",
        "-d",
        default=None,
        help="YOLO data yaml with 'names' (default: auto-detect)",
    )
    parser.add_argument(
        "--names",
        "-n",
        default=None,
        help="Comma separated class names (overrides --data)",
    )
    parser.add_argument(
        "--recursive",
        "-r",
        action="store_true",
        help="Search input directories recursively",
    )
    parser.add_argument(
        "--overwrite",
        "-f",
        action="store_true",
        help="Overwrite existing JSON files",
    )
    parser.add_argument(
        "--skip-missing",
        action="store_true",
        help="Do not write JSON for images without a label file",
    )
    parser.add_argument(
        "--image-data",
        action="store_true",
        help="Embed base64 image data in JSON (default: null)",
    )
    parser.add_argument(
        "--decimals",
        type=int,
        default=DEFAULT_DECIMALS,
        help=f"Round point coordinates (default: {DEFAULT_DECIMALS})",
    )
    parser.add_argument(
        "--labelme-version",
        default=DEFAULT_LABELME_VERSION,
        help=f"Value of the 'version' field (default: {DEFAULT_LABELME_VERSION})",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Do not write any files",
    )
    parser.add_argument(
        "--quiet",
        "-q",
        action="store_true",
        help="Print summary only",
    )
    return parser.parse_known_args(cmdline, namespace)[0]


def load_names_from_yaml(path: Path) -> Dict[int, str]:
    import yaml

    with path.open(encoding="utf-8") as f:
        names = (yaml.safe_load(f) or {}).get("names", {})
    if isinstance(names, list):
        names = dict(enumerate(names))
    return {int(k): str(v) for k, v in names.items()}


def find_data_yaml(inputs: Iterable[Path]) -> Optional[Path]:
    for path in inputs:
        start = path if path.is_dir() else path.parent
        for directory in (start, *start.parents):
            for name in DATA_YAML_NAMES:
                candidate = directory / name
                if candidate.is_file():
                    return candidate
    return None


def iter_images(inputs: Iterable[Path], recursive: bool) -> List[Path]:
    result = set()
    for path in inputs:
        if path.is_file():
            if path.suffix.lower() in IMAGE_EXTS:
                result.add(path)
        elif path.is_dir():
            files = path.rglob("*") if recursive else path.iterdir()
            result.update(
                p for p in files if p.is_file() and p.suffix.lower() in IMAGE_EXTS
            )
        else:
            print(f"[WARN] Not found: {path}", file=sys.stderr)
    return sorted(result)


def label_candidates(image: Path, labels_dir: Optional[Path]) -> List[Path]:
    name = image.stem + ".txt"
    if labels_dir is not None:
        return [labels_dir / name]

    candidates = [image.with_suffix(".txt")]
    parts = list(image.parent.parts)
    indices = [i for i, part in enumerate(parts) if part == "images"]
    if indices:
        last = list(parts)
        last[indices[-1]] = "labels"
        candidates.append(Path(*last) / name)
        every = ["labels" if part == "images" else part for part in parts]
        candidates.append(Path(*every) / name)
    return candidates


def find_label(image: Path, labels_dir: Optional[Path]) -> Optional[Path]:
    for candidate in label_candidates(image, labels_dir):
        if candidate.is_file():
            return candidate
    return None


def parse_line(
    line: str,
    width: int,
    height: int,
    names: Dict[int, str],
    decimals: int,
) -> Optional[Dict[str, Any]]:
    values = line.split()
    if not values:
        return None

    cls = int(float(values[0]))
    coords = [float(v) for v in values[1:]]

    if len(coords) == 4:
        cx, cy, w, h = coords
        points = [
            ((cx - w / 2) * width, (cy - h / 2) * height),
            ((cx + w / 2) * width, (cy + h / 2) * height),
        ]
        shape_type = "rectangle"
    elif len(coords) >= 6 and len(coords) % 2 == 0:
        points = [(x * width, y * height) for x, y in zip(coords[0::2], coords[1::2])]
        shape_type = "polygon"
    else:
        raise ValueError(f"Invalid number of coordinates: {len(coords)}")

    return {
        "label": names.get(cls, str(cls)),
        "points": [[round(x, decimals), round(y, decimals)] for x, y in points],
        "group_id": None,
        "description": "",
        "shape_type": shape_type,
        "flags": {},
        "mask": None,
    }


def encode_image_data(image: Path) -> str:
    from base64 import b64encode

    return b64encode(image.read_bytes()).decode("ascii")


def convert(
    image: Path,
    label: Optional[Path],
    names: Dict[int, str],
    args: Namespace,
) -> Dict[str, Any]:
    with Image.open(image) as img:
        width, height = img.size

    shapes = []
    if label is not None:
        lines = label.read_text(encoding="utf-8").splitlines()
        for lineno, line in enumerate(lines, 1):
            try:
                shape = parse_line(line, width, height, names, args.decimals)
            except ValueError as e:
                print(f"[WARN] {label}:{lineno} {e}", file=sys.stderr)
                continue
            if shape is not None:
                shapes.append(shape)

    return {
        "version": args.labelme_version,
        "flags": {},
        "shapes": shapes,
        "imagePath": image.name,
        "imageData": encode_image_data(image) if args.image_data else None,
        "imageHeight": height,
        "imageWidth": width,
    }


def main() -> int:
    args = get_default_arguments()
    inputs = [Path(os.path.expanduser(p)) for p in args.inputs]
    labels_dir = Path(os.path.expanduser(args.labels)) if args.labels else None

    if labels_dir is not None and not labels_dir.is_dir():
        print(f"[ERROR] Label directory not found: {labels_dir}", file=sys.stderr)
        return 1

    names: Dict[int, str] = {}
    if args.names:
        names = dict(enumerate(n.strip() for n in args.names.split(",")))
    else:
        data = Path(os.path.expanduser(args.data)) if args.data else find_data_yaml(inputs)
        if data is not None:
            if not data.is_file():
                print(f"[ERROR] Data yaml not found: {data}", file=sys.stderr)
                return 1
            names = load_names_from_yaml(data)
            if not args.quiet:
                print(f"Class names from {data}: {names}")

    images = iter_images(inputs, args.recursive)
    if not images:
        print("[ERROR] No images found", file=sys.stderr)
        return 1

    written = skipped = missing = failed = total_shapes = 0
    for image in images:
        output = image.with_suffix(".json")
        if output.exists() and not args.overwrite:
            skipped += 1
            if not args.quiet:
                print(f"[SKIP] Already exists: {output}")
            continue

        label = find_label(image, labels_dir)
        if label is None:
            missing += 1
            print(f"[WARN] Label not found: {image}", file=sys.stderr)
            if args.skip_missing:
                continue

        try:
            data = convert(image, label, names, args)
        except Exception as e:  # noqa
            failed += 1
            print(f"[ERROR] {image}: {e}", file=sys.stderr)
            continue

        if not args.dry_run:
            output.write_text(
                json.dumps(data, ensure_ascii=False, indent=2),
                encoding="utf-8",
            )
        written += 1
        total_shapes += len(data["shapes"])
        if not args.quiet:
            print(f"{output} ({len(data['shapes'])} shapes)")

    print(
        f"Images: {len(images)}, written: {written}, shapes: {total_shapes}, "
        f"skipped: {skipped}, missing label: {missing}, failed: {failed}"
        + (" (dry-run)" if args.dry_run else "")
    )
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
