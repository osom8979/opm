# -*- coding: utf-8 -*-

from argparse import ArgumentParser, Namespace
from typing import Final, List, Optional

import cv2

PROG: Final[str] = "opy-cv2-video-capture"


def get_default_arguments(
    cmdline: Optional[List[str]] = None,
    namespace: Optional[Namespace] = None,
) -> Namespace:
    parser = ArgumentParser(prog=PROG)
    parser.add_argument("--title", default=PROG, help="Window title")
    parser.add_argument("source", help="Input source")
    return parser.parse_known_args(cmdline, namespace)[0]


def main() -> None:
    args = get_default_arguments()
    assert isinstance(args.title, str)
    assert isinstance(args.source, str)

    cv2.namedWindow(args.title, cv2.WINDOW_NORMAL)
    cap = cv2.VideoCapture(args.source)

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        # Display the resulting frame
        cv2.imshow(args.title, frame)

        if cv2.waitKey(1) & 0xFF == ord("q"):
            break

    cap.release()
    cv2.destroyWindow(args.title)


if __name__ == "__main__":
    main()
