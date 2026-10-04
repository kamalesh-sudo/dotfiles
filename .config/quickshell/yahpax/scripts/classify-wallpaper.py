#!/usr/bin/env python3
"""Classify a wallpaper by the majority of its sampled dark/light pixels."""

import sys
from pathlib import Path

from PIL import Image


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: classify-wallpaper.py <image>", file=sys.stderr)
        return 2
    path = Path(sys.argv[1])
    with Image.open(path) as image:
        image = image.convert("RGB")
        image.thumbnail((160, 160))
        light = 0
        dark = 0
        for red, green, blue in image.getdata():
            luminance = (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255.0
            if luminance >= 0.5:
                light += 1
            else:
                dark += 1
    print("light" if light > dark else "dark")
    print(f"light={light} dark={dark}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
