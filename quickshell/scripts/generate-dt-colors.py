#!/usr/bin/env python3

import json
from pathlib import Path

WAL = Path.home() / ".cache/wal/colors.json"
OUT = Path.home() / ".local/share/color-schemes/Pywal.colors"


def rgb(hex_color):
    hex_color = hex_color.lstrip("#")
    return ",".join(str(int(hex_color[i:i + 2], 16)) for i in (0, 2, 4))


with WAL.open("r", encoding="utf-8") as f:
    data = json.load(f)

special = data["special"]
colors = data["colors"]

background = rgb(special["background"])
foreground = rgb(special["foreground"])

# Pywal palette
accent = rgb(colors["color4"])
accent2 = rgb(colors["color6"])
muted = rgb(colors["color8"])

qt_colors = f"""[ColorEffects:Disabled]
Color=128,128,128
ColorAmount=1
ColorEffect=0
ContrastAmount=0
ContrastEffect=0
IntensityAmount=0
IntensityEffect=0

[ColorEffects:Inactive]
ChangeSelectionColor=false
Color=112,111,110
ColorAmount=0.5
ColorEffect=0
ContrastAmount=0
ContrastEffect=0
IntensityAmount=0
IntensityEffect=0

[Colors:Window]
BackgroundNormal={background}
ForegroundNormal={foreground}
ForegroundInactive={muted}
DecorationFocus={accent}
DecorationHover={accent2}

[Colors:View]
BackgroundNormal={background}
ForegroundNormal={foreground}
ForegroundInactive={muted}
ForegroundLink={accent}
ForegroundVisited={accent2}
DecorationFocus={accent}
DecorationHover={accent2}

[Colors:Button]
BackgroundNormal={background}
ForegroundNormal={foreground}
ForegroundInactive={muted}
ForegroundActive={foreground}
DecorationFocus={accent}
DecorationHover={accent2}

[Colors:Selection]
BackgroundNormal={accent}
ForegroundNormal={background}
ForegroundInactive={background}
ForegroundActive={foreground}
DecorationFocus={accent2}
DecorationHover={accent2}

[Colors:Tooltip]
BackgroundNormal={background}
ForegroundNormal={foreground}
ForegroundInactive={muted}
ForegroundActive={foreground}

[Colors:Header]
BackgroundNormal={background}
ForegroundNormal={foreground}
ForegroundInactive={muted}
ForegroundActive={foreground}

[Colors:Complementary]
BackgroundNormal={background}
ForegroundNormal={foreground}
ForegroundInactive={muted}
ForegroundActive={foreground}
"""

OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(qt_colors, encoding="utf-8")

print(f"Generated: {OUT}")
