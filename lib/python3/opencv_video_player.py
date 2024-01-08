# -*- coding: utf-8 -*-

from sys import argv

import cv2


def main(src: str, title="VideoPlayer") -> None:
    cv2.namedWindow(title, cv2.WINDOW_NORMAL)
    cap = cv2.VideoCapture(src)

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        # Display the resulting frame
        cv2.imshow(title, frame)

        if cv2.waitKey(1) & 0xFF == ord("q"):
            break

    cap.release()
    cv2.destroyWindow(title)


if __name__ == "__main__":
    main(argv[1])
