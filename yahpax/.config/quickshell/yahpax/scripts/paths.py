"""Stable user paths shared by the Python theme-application scripts."""

from pathlib import Path


HOME = Path.home()
YAHPAX_CACHE = HOME / ".cache/yahpax"
WAL_COLORS = YAHPAX_CACHE / "wal/colors.json"
KITTY_CONFIG = HOME / ".config/kitty/kitty.conf"
QUTEBROWSER_CONFIG = HOME / ".config/qutebrowser"
FASTFETCH_CONFIG = HOME / ".config/fastfetch/yahpax/config.jsonc"
STARTPAGE_WALLPAPERS = YAHPAX_CACHE / "rice/startpage-wallpapers"
STARSHIP_CONFIG = HOME / ".config/starship.toml"
STARSHIP_WAL_CONFIG = HOME / ".config/starship-yahpax.toml"
