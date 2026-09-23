#!/usr/bin/env python3
# Generates the qutebrowser startpage.
# Usage: apply-qutebrowser-startpage.py <colors.json> <palette-image> <qutebrowser-config-dir>
#
# >>> EDIT HERE: swap in your own shortcut list. Format: (title, url, icon).

import random
import subprocess
import sys
from pathlib import Path
from color_utils import load_colors
from paths import QUTEBROWSER_CONFIG, STARTPAGE_WALLPAPERS, WAL_COLORS


SHORTCUTS = [
    ("github", "https://github.com/kamalesh-sudo", "\uf09b"),
    ("youtube", "https://youtube.com", "\uf16a"),
    ("chat", "https://chatgpt.com", "\uf0eb"),
    ("arch wiki", "https://wiki.archlinux.org", "\uf303"),
    ("reddit", "https://reddit.com", "\uf281"),
    ("mail", "https://gmail.com", "\uf0e0"),
]


TEMPLATE = '''<!doctype html><html><head><meta charset="utf-8"><title>// startpage</title><style>
*{box-sizing:border-box}
:root{--fg:@@FG@@;--bg:@@BG@@;--ac:@@ACCENT@@;--ac2:@@ACCENT2@@;--mu:@@MUTED@@}
body{margin:0;min-height:100vh;overflow:hidden;color:var(--fg);
  font-family:Inter,system-ui,sans-serif;position:relative;
  background:#05050a @@WALL_CSS@@;
  display:flex;flex-direction:column;align-items:center;justify-content:center;gap:36px}
body:before{content:"";position:fixed;inset:0;pointer-events:none;z-index:0;
  background:radial-gradient(ellipse at 50% 0%,var(--ac)22,transparent 55%),
             radial-gradient(ellipse at 50% 100%,var(--ac2)18,transparent 55%),
             linear-gradient(var(--bg)cc,var(--bg)ee)}
body:after{content:"";position:fixed;inset:0;pointer-events:none;z-index:0;opacity:.06;
  background-image:linear-gradient(var(--fg) 1px,transparent 1px),
                    linear-gradient(90deg,var(--fg) 1px,transparent 1px);
  background-size:44px 44px}
.bracket{position:fixed;width:26px;height:26px;pointer-events:none;z-index:2}
.bracket b{position:absolute;background:var(--ac);display:block}
.tl{top:22px;left:22px}.tl .h{top:0;left:0;width:26px;height:2px}.tl .v{top:0;left:0;width:2px;height:26px}
.tr{top:22px;right:22px}.tr .h{top:0;right:0;width:26px;height:2px}.tr .v{top:0;right:0;width:2px;height:26px}
.bl{bottom:22px;left:22px}.bl .h{bottom:0;left:0;width:26px;height:2px}.bl .v{bottom:0;left:0;width:2px;height:26px}
.br{bottom:22px;right:22px}.br .h{bottom:0;right:0;width:26px;height:2px}.br .v{bottom:0;right:0;width:2px;height:26px}
.hud{z-index:1;text-align:center}
.clock{font-size:64px;font-weight:200;letter-spacing:2px;color:var(--fg);
  text-shadow:0 0 24px var(--ac)aa;line-height:1}
.status{margin-top:10px;font-family:"Symbols Nerd Font",monospace;font-size:11px;
  letter-spacing:4px;text-transform:uppercase;color:var(--ac2);opacity:.85}
.status .dot{display:inline-block;width:6px;height:6px;border-radius:50%;
  background:var(--ac2);margin-right:8px;box-shadow:0 0 8px var(--ac2);
  animation:blink 2s ease-in-out infinite}
@keyframes blink{50%{opacity:.25}}
.grid{z-index:1;display:grid;grid-template-columns:repeat(3,200px);gap:14px}
.card{min-height:120px;padding:20px;text-decoration:none;color:var(--fg);
  display:flex;flex-direction:column;justify-content:center;gap:8px;
  border-radius:14px;border:1px solid var(--ac)44;
  background:var(--bg)55;
  backdrop-filter:blur(16px) saturate(1.4);-webkit-backdrop-filter:blur(16px) saturate(1.4);
  box-shadow:inset 0 1px #ffffff22,0 10px 24px #00000044;
  animation:enter .5s cubic-bezier(.2,.8,.2,1) both;
  transition:transform .22s cubic-bezier(.2,.9,.2,1),box-shadow .22s,border-color .22s}
@keyframes enter{from{opacity:0;transform:translateY(18px)}}
.card:hover{transform:translateY(-5px);border-color:var(--ac);
  box-shadow:0 0 22px var(--ac)66,inset 0 1px #ffffff33}
.card b{font-size:22px;font-weight:400;color:var(--ac2);
  font-family:"Symbols Nerd Font",monospace}
.card span{font-size:14px;letter-spacing:.5px}
</style></head><body>
<div class="bracket tl"><b class="h"></b><b class="v"></b></div>
<div class="bracket tr"><b class="h"></b><b class="v"></b></div>
<div class="bracket bl"><b class="h"></b><b class="v"></b></div>
<div class="bracket br"><b class="h"></b><b class="v"></b></div>
<div class="hud">
  <div class="clock" id="c">--:--</div>
  <div class="status"><span class="dot"></span>system online</div>
</div>
<main class="grid">@@CARDS@@</main>
<script>
function tick(){document.getElementById("c").textContent=
  new Date().toLocaleTimeString("en-US",{hour:"2-digit",minute:"2-digit"});}
tick();setInterval(tick,1000);
</script></body></html>'''


def fill(template, mapping):
    for key, value in mapping.items():
        template = template.replace("@@" + key + "@@", value)
    return template


def generate_startpage_wallpapers(base_color, background_color):
    wallpaper_dir = (
        STARTPAGE_WALLPAPERS
    )
    wallpaper_dir.mkdir(parents=True, exist_ok=True)

    designs = [
        f'''<defs>
<radialGradient id="g1" cx="20%" cy="20%" r="75%">
<stop offset="0%" stop-color="{base_color}" stop-opacity="0.9"/>
<stop offset="100%" stop-color="{base_color}" stop-opacity="0"/>
</radialGradient>
</defs>
<rect width="1920" height="1080" fill="{background_color}"/>
<rect width="1920" height="1080" fill="url(#g1)"/>''',

        f'''<defs>
<linearGradient id="g2" x1="0%" y1="0%" x2="100%" y2="100%">
<stop offset="0%" stop-color="{base_color}" stop-opacity="0.8"/>
<stop offset="50%" stop-color="{base_color}" stop-opacity="0.2"/>
<stop offset="100%" stop-color="{base_color}" stop-opacity="0"/>
</linearGradient>
</defs>
<rect width="1920" height="1080" fill="{background_color}"/>
<rect width="1920" height="1080" fill="url(#g2)"/>''',

        f'''<defs>
<radialGradient id="g3" cx="80%" cy="25%" r="70%">
<stop offset="0%" stop-color="{base_color}" stop-opacity="0.85"/>
<stop offset="100%" stop-color="{base_color}" stop-opacity="0"/>
</radialGradient>
</defs>
<rect width="1920" height="1080" fill="{background_color}"/>
<rect width="1920" height="1080" fill="url(#g3)"/>''',

        f'''<defs>
<radialGradient id="g4" cx="50%" cy="100%" r="80%">
<stop offset="0%" stop-color="{base_color}" stop-opacity="0.8"/>
<stop offset="100%" stop-color="{base_color}" stop-opacity="0"/>
</radialGradient>
</defs>
<rect width="1920" height="1080" fill="{background_color}"/>
<rect width="1920" height="1080" fill="url(#g4)"/>''',

        f'''<defs>
<radialGradient id="g5" cx="50%" cy="50%" r="75%">
<stop offset="0%" stop-color="{base_color}" stop-opacity="0.65"/>
<stop offset="55%" stop-color="{base_color}" stop-opacity="0.2"/>
<stop offset="100%" stop-color="{base_color}" stop-opacity="0"/>
</radialGradient>
</defs>
<rect width="1920" height="1080" fill="{background_color}"/>
<rect width="1920" height="1080" fill="url(#g5)"/>''',
    ]

    for index, design in enumerate(designs, start=1):
        svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
     width="1920"
     height="1080"
     viewBox="0 0 1920 1080">
{design}
</svg>
'''
        (wallpaper_dir / f"design-{index}.svg").write_text(
            svg,
            encoding="utf-8"
        )

    return wallpaper_dir


def main():
    colors_json_path = (
        Path(sys.argv[1])
        if len(sys.argv) > 1 and sys.argv[1]
        else WAL_COLORS
    )

    wall = (
        sys.argv[2]
        if len(sys.argv) > 2 and sys.argv[2]
        else ""
    )

    out_dir = (
        Path(sys.argv[3])
        if len(sys.argv) > 3 and sys.argv[3]
        else QUTEBROWSER_CONFIG
    )

    out_dir.mkdir(parents=True, exist_ok=True)

    if not colors_json_path.exists():
        print(
            f"apply-qutebrowser-startpage: "
            f"{colors_json_path} not found",
            file=sys.stderr
        )
        sys.exit(1)

    data = load_colors(colors_json_path)

    bg = data["special"]["background"]
    fg = data["special"]["foreground"]
    accent = data["colors"]["color4"]
    accent2 = data["colors"]["color6"]
    muted = data["colors"]["color8"]

    # Generate five wallpapers from the current pywal colors.
    wallpaper_dir = generate_startpage_wallpapers(
        accent,
        bg
    )

    # Randomly select one generated wallpaper.
    wallpaper_choices = sorted(
        wallpaper_dir.glob("design-*.svg")
    )

    if wallpaper_choices:
        wall = str(random.choice(wallpaper_choices))

    wall_css = (
        f'url("file://{wall}") center/cover fixed'
        if wall and Path(wall).exists()
        else "none"
    )

    colors = {
        "BG": bg,
        "FG": fg,
        "ACCENT": accent,
        "ACCENT2": accent2,
        "MUTED": muted,
        "WALL_CSS": wall_css,
    }

    cards = "".join(
        '<a class="card" style="animation-delay:{d}s" href="{u}">'
        '<b>{ic}</b><span>{n}</span></a>'.format(
            d=round(i * 0.06, 2),
            u=u,
            ic=ic,
            n=n
        )
        for i, (n, u, ic) in enumerate(SHORTCUTS)
    )

    html = fill(
        TEMPLATE,
        dict(colors, CARDS=cards)
    )

    (out_dir / "startpage.html").write_text(
        html,
        encoding="utf-8"
    )

    print(
        "startpage written to",
        out_dir / "startpage.html"
    )

    # Reload open startpages in running qutebrowser instances if any.
    try:
        res = subprocess.run(
            ["pgrep", "-x", "qutebrowser"],
            capture_output=True,
            text=True
        )

        if res.returncode == 0:
            subprocess.run(
                ["qutebrowser", ":reload"],
                timeout=2,
                check=False,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
    except Exception:
        pass


if __name__ == "__main__":
    main()
