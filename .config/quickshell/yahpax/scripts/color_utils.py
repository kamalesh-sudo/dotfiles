"""Shared pywal color parsing helpers for the live apply scripts."""

import json
from pathlib import Path


def load_colors(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def hex6(color: str) -> str:
    return color.lstrip("#")


def hex_to_rgb(hex_str: str):
    h = hex_str.lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)


def ansi_rgb(hex_str: str) -> str:
    r, g, b = hex_to_rgb(hex_str)
    return f"\x1b[38;2;{r};{g};{b}m"
