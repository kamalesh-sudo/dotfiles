#!/usr/bin/env python3
"""
apply-fastfetch-colors.py [colors.json] [config_path_or_dir]

Updates fastfetch configuration to obey the rice color system from colors.json.
Applies accent, secondary accent, muted, and foreground colors to display settings,
constants, and logos.
"""

import json
import re
import sys
from pathlib import Path
from color_utils import ansi_rgb, load_colors
from paths import FASTFETCH_CONFIG, WAL_COLORS


def strip_jsonc(content: str) -> str:
    """Strip comments and trailing commas from JSONC so it parses as standard JSON."""
    result = []
    i = 0
    n = len(content)
    in_string = False
    escape = False

    while i < n:
        c = content[i]
        if in_string:
            result.append(c)
            if escape:
                escape = False
            elif c == "\\":
                escape = True
            elif c == '"':
                in_string = False
            i += 1
            continue

        if c == '"':
            in_string = True
            result.append(c)
            i += 1
            continue

        if c == "/" and i + 1 < n:
            next_c = content[i + 1]
            if next_c == "/":
                i += 2
                while i < n and content[i] != "\n":
                    i += 1
                continue
            elif next_c == "*":
                i += 2
                while i + 1 < n and not (content[i] == "*" and content[i + 1] == "/"):
                    i += 1
                i += 2
                continue

        result.append(c)
        i += 1

    clean = "".join(result)
    clean = re.sub(r",\s*([}\]])", r"\1", clean)
    return clean


def resolve_paths():
    colors_json = (
        Path(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1]
        else WAL_COLORS
    )

    if len(sys.argv) > 2 and sys.argv[2]:
        p = Path(sys.argv[2])
        if p.is_dir():
            config_file = p / "config.jsonc"
            if not config_file.exists() and (p / "config.json").exists():
                config_file = p / "config.json"
        else:
            config_file = p
    else:
        config_file = FASTFETCH_CONFIG

    return colors_json, config_file


def apply_colors(config_data: dict, colors: dict, special: dict) -> dict:
    bg = special.get("background", "#000000")
    fg = special.get("foreground", "#ffffff")
    accent = colors.get("color4", fg)
    accent2 = colors.get("color6", fg)
    color2 = colors.get("color2", fg)
    muted = colors.get("color8", bg)
    color1 = colors.get("color1", fg)
    color3 = colors.get("color3", fg)
    color5 = colors.get("color5", fg)

    if "display" not in config_data:
        config_data["display"] = {}

    display = config_data["display"]

    # 1. Update display.color
    if isinstance(display.get("color"), dict):
        display["color"]["keys"] = accent
        display["color"]["title"] = accent
        display["color"]["separator"] = muted
    elif isinstance(display.get("color"), str):
        display["color"] = accent
    else:
        display["color"] = {
            "keys": accent,
            "title": accent,
            "separator": muted,
        }

    # 2. Update display.constants if present
    if "constants" in display and isinstance(display["constants"], list):
        palette_ansi = [
            ansi_rgb(fg),       # {$1}: text / border close
            ansi_rgb(accent),   # {$2}: primary accent / icons
            ansi_rgb(accent2),  # {$3}: secondary accent
            ansi_rgb(color2),   # {$4}: green / distro
            ansi_rgb(color5),   # {$5}: magenta
            ansi_rgb(color3),   # {$6}: yellow
            ansi_rgb(color1),   # {$7}: error / red
            ansi_rgb(muted),    # {$8}: muted
        ]
        for idx in range(len(display["constants"])):
            if idx < len(palette_ansi):
                display["constants"][idx] = palette_ansi[idx]

    # 3. Update logo.color if present
    if "logo" in config_data and isinstance(config_data["logo"], dict):
        logo = config_data["logo"]
        if "color" not in logo or not isinstance(logo["color"], dict):
            logo["color"] = {}
        logo["color"]["1"] = accent
        logo["color"]["2"] = accent2

    return config_data


def get_default_config(colors: dict, special: dict) -> dict:
    bg = special.get("background", "#000000")
    fg = special.get("foreground", "#ffffff")
    accent = colors.get("color4", fg)
    muted = colors.get("color8", bg)

    return {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "display": {
            "color": {
                "keys": accent,
                "title": accent,
                "separator": muted,
            }
        },
        "modules": [
            "title",
            "separator",
            "os",
            "host",
            "kernel",
            "uptime",
            "packages",
            "shell",
            "display",
            "de",
            "wm",
            "theme",
            "icons",
            "font",
            "cursor",
            "terminal",
            "cpu",
            "gpu",
            "memory",
            "break",
            "colors",
        ],
    }


def main():
    colors_json, config_file = resolve_paths()

    if not colors_json.exists():
        print(f"Error: {colors_json} not found", file=sys.stderr)
        sys.exit(1)

    data = load_colors(colors_json)

    colors = data.get("colors", {})
    special = data.get("special", {})

    config_file.parent.mkdir(parents=True, exist_ok=True)

    if config_file.exists():
        content = config_file.read_text(encoding="utf-8").strip()
        if content:
            try:
                config_data = json.loads(content)
            except Exception:
                try:
                    config_data = json.loads(strip_jsonc(content))
                except Exception as e:
                    print(f"Warning: could not parse {config_file} as JSON/JSONC: {e}", file=sys.stderr)
                    config_data = get_default_config(colors, special)
        else:
            config_data = get_default_config(colors, special)
    else:
        config_data = get_default_config(colors, special)

    updated_config = apply_colors(config_data, colors, special)

    config_file.write_text(json.dumps(updated_config, indent=2) + "\n", encoding="utf-8")
    print(f"fastfetch: colors updated in {config_file}")


if __name__ == "__main__":
    main()
