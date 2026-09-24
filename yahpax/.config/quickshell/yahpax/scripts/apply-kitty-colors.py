#!/usr/bin/env python3
"""
apply-kitty-colors.py [colors.json] [kitty.conf]

Generates colors-wal.conf in the kitty config directory from pywal colors,
ensures existing kitty.conf includes it, and signals all running kitty
instances to reload immediately.
"""

import re
import subprocess
import sys
from pathlib import Path
from paths import KITTY_CONFIG, WAL_COLORS
from color_utils import hex6, load_colors


def build_kitty_colors(colors: dict, special: dict) -> str:
    bg = hex6(special.get("background", "#000000"))
    fg = hex6(special.get("foreground", "#ffffff"))
    cursor = hex6(special.get("cursor", fg))
    c4 = hex6(colors.get("color4", fg))
    c8 = hex6(colors.get("color8", bg))
    c1 = hex6(colors.get("color1", fg))
    c0 = hex6(colors.get("color0", bg))

    lines = [
        "# Generated from ~/.cache/yahpax/wal/colors.json",
        "# Do not hand-edit",
        "",
        f"foreground         #{fg}",
        f"background         #{bg}",
        "selection_foreground none",
        "selection_background none",
        f"cursor             #{cursor}",
        f"cursor_text_color  #{bg}",
        "",
        f"url_color          #{c4}",
        "",
        f"active_border_color   #{c4}",
        f"inactive_border_color #{c8}",
        f"bell_border_color     #{c1}",
        "",
        f"active_tab_foreground   #{bg}",
        f"active_tab_background   #{c4}",
        f"inactive_tab_foreground #{fg}",
        f"inactive_tab_background #{c0}",
        "",
        "# 16 terminal colors",
    ]

    for i in range(8):
        lines.append(f"color{i:<2}  #{hex6(colors.get(f'color{i}', bg))}")
    lines.append("")
    for i in range(8, 16):
        lines.append(f"color{i:<2} #{hex6(colors.get(f'color{i}', fg))}")

    return "\n".join(lines) + "\n"


def resolve_paths():
    colors_json = Path(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1] else WAL_COLORS

    if len(sys.argv) > 2 and sys.argv[2]:
        p = Path(sys.argv[2])
        if p.is_dir():
            kitty_conf = p / "kitty.conf"
        elif p.name == "kitty.ini":
            kitty_conf = p.parent / "kitty.conf"
        else:
            kitty_conf = p
    else:
        kitty_conf = KITTY_CONFIG

    return colors_json, kitty_conf


def update_kitty_conf(kitty_conf: Path):
    kitty_conf.parent.mkdir(parents=True, exist_ok=True)
    if not kitty_conf.exists():
        kitty_conf.write_text("include colors-wal.conf\n", encoding="utf-8")
        return

    content = kitty_conf.read_text(encoding="utf-8")

    # Clean up any leftover kitty/ini artifacts if previously corrupted
    content = re.sub(r"\[colors(-dark)?\].*?(?=\n\[|\Z)", "", content, flags=re.DOTALL)

    # Ensure include colors-wal.conf is present
    if not re.search(r"^\s*include\s+.*?colors-wal\.conf", content, re.MULTILINE):
        separator = "\n" if content.endswith("\n") else "\n\n"
        content = content.rstrip() + separator + "include colors-wal.conf\n"

    kitty_conf.write_text(content, encoding="utf-8")


def apply_live(wal_conf_path: Path):
    # Send SIGUSR1 to reload configuration in all running kitty instances
    try:
        subprocess.run(
            ["pkill", "-SIGUSR1", "-x", "kitty"],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except Exception:
        pass


def main():
    colors_json, kitty_conf = resolve_paths()

    if not colors_json.exists():
        print(f"Error: {colors_json} not found", file=sys.stderr)
        sys.exit(1)

    data = load_colors(colors_json)

    colors_content = build_kitty_colors(data["colors"], data["special"])

    wal_conf_path = kitty_conf.parent / "colors-wal.conf"
    wal_conf_path.write_text(colors_content, encoding="utf-8")

    update_kitty_conf(kitty_conf)
    apply_live(wal_conf_path)

    print(f"kitty: colors updated in {wal_conf_path} and applied to {kitty_conf}")


if __name__ == "__main__":
    main()
