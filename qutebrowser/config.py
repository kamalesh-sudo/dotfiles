
# ============================================================
# Qutebrowser Configuration
# ============================================================

# ------------------------------------------------------------
# Core
# ------------------------------------------------------------


# ------------------------------------------------------------
# proxy
# ------------------------------------------------------------
config.bind('<Ctrl-Shift-P>', 'config-cycle content.proxy http://127.0.0.1:8070 none')


config.load_autoconfig(False)

c.editor.command = ["kitty", "nvim", "{}"]


# ------------------------------------------------------------
# Content / Permissions
# ------------------------------------------------------------

# JavaScript
c.content.javascript.enabled = True

# Cookies
c.content.cookies.accept = "all"
c.content.local_content_can_access_remote_urls = True
c.content.local_content_can_access_file_urls = True
# Images
c.content.images = True

# Autoplay
c.content.autoplay = True

# Notifications
c.content.notifications.enabled = True

# Geolocation
c.content.geolocation = False

# Media capture
c.content.media.audio_capture = True
c.content.media.video_capture = True

# WebGL
c.content.webgl = True


# ------------------------------------------------------------
# Ad / Content Blocking
# ------------------------------------------------------------

config.set("content.blocking.enabled", True)
config.set("content.blocking.method", "adblock")

config.set("content.blocking.adblock.lists", [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
])


# ------------------------------------------------------------
# Media Shortcuts
# ------------------------------------------------------------

# Stream current page with VLC
config.bind(
    ",v",
    "spawn --detach streamlink --player vlc {url} best"
)

# Play current page with MPV
config.bind(
    ",m",
    'spawn --detach mpv --ytdl-format="bestvideo[height<=?1080]+bestaudio/best" {url}'
)


# ------------------------------------------------------------
# WhatsApp Web
# ------------------------------------------------------------

with config.pattern("*://web.whatsapp.com/*"):
    c.content.javascript.enabled = True
    c.content.cookies.accept = "all"

    c.content.headers.user_agent = (
        "Mozilla/5.0 (X11; Linux x86_64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/131.0.0.0 Safari/537.36"
    )


# ------------------------------------------------------------
# Google / reCAPTCHA
# ------------------------------------------------------------

for pattern in [
    "*://google.com/*",
    "*://www.google.com/*",
    "*://accounts.google.com/*",
    "*://gstatic.com/*",
    "*://www.gstatic.com/*",
    "*://googleusercontent.com/*",
    "*://*.googleusercontent.com/*",
    "*://recaptcha.net/*",
    "*://www.recaptcha.net/*",
]:
    with config.pattern(pattern):
        c.content.javascript.enabled = True
        c.content.cookies.accept = "all"

        c.content.headers.user_agent = (
            "Mozilla/5.0 (X11; Linux x86_64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/131.0.0.0 Safari/537.36"
        )


# ------------------------------------------------------------
# Fiverr
# ------------------------------------------------------------

with config.pattern("*://www.fiverr.com/*"):
    c.content.javascript.enabled = True
    c.content.cookies.accept = "all"


# ------------------------------------------------------------
# ChatGPT / OpenAI / Cloudflare
# ------------------------------------------------------------

for pattern in [
    "*://chatgpt.com/*",
    "*://*.chatgpt.com/*",
    "*://auth.openai.com/*",
    "*://*.openai.com/*",
    "*://accounts.google.com/*",
    "*://*.google.com/*",
    "*://*.gstatic.com/*",
    "*://*.googleusercontent.com/*",
    "*://challenges.cloudflare.com/*",
]:
    with config.pattern(pattern):
        c.content.javascript.enabled = True
        c.content.cookies.accept = "all"
        c.content.notifications.enabled = True


# ------------------------------------------------------------
# GPU / Chromium / Qt
# ------------------------------------------------------------

c.qt.args = [
    "ignore-gpu-blocklist",
    "enable-gpu-rasterization",
    "enable-zero-copy",
    "enable-accelerated-video-decode",
]


# ------------------------------------------------------------
# Search Engines
# ------------------------------------------------------------

c.url.searchengines = {
    "DEFAULT": "https://www.duckduckgo.com/search?q={}",
    "g": "https://www.google.com/search?q={}",
}


# ------------------------------------------------------------
# Dynamic Rice Colors
# ------------------------------------------------------------

try:
    config.source("colors-wal.py")
except Exception:
    pass
