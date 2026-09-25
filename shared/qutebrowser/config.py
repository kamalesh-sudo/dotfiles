# ─────────────────────────────────────────────────────────────
# qutebrowser config.py
# Flexible web compatibility configuration
# ─────────────────────────────────────────────────────────────

config.load_autoconfig(False)


# ─────────────────────────────────────────────────────────────
# QT / CHROMIUM
# ─────────────────────────────────────────────────────────────

c.qt.args = [
    'ignore-gpu-blocklist',
    'enable-gpu-rasterization',
    'enable-zero-copy',
    'enable-accelerated-video-decode',
]


# ─────────────────────────────────────────────────────────────
# WEB COMPATIBILITY
# ─────────────────────────────────────────────────────────────

# JavaScript
c.content.javascript.enabled = True

# Cookies and browser storage
#
# QtWebEngine uses this for:
# - cookies
# - IndexedDB
# - DOM storage
# - filesystem API
# - service workers
# - AppCache
#
c.content.cookies.accept = 'all'
c.content.cookies.store = True

# Canvas
#
# Required by some modern websites and browser verification systems.
c.content.canvas_reading = True

# WebGL
c.content.webgl = True

# Images
c.content.images = True

# HTML5 local storage
c.content.local_storage = True

# Modern site compatibility quirks
c.content.site_specific_quirks.enabled = True

# Normal browser referer behavior
c.content.headers.referer = 'same-domain'

# Accept normal web languages
c.content.headers.accept_language = 'en-US,en;q=0.9'

# Keep the browser's native qutebrowser/QtWebEngine UA.
#
# IMPORTANT:
# Do NOT force a fake/static Chrome version globally.
#
# qutebrowser's default UA already removes QtWebEngine
# from the UA for compatibility.
#
# c.content.headers.user_agent = ...


# ─────────────────────────────────────────────────────────────
# CLOUDFLARE / CHALLENGE COMPATIBILITY
# ─────────────────────────────────────────────────────────────

# Cloudflare challenge infrastructure must not be blocked.
c.content.blocking.whitelist = [
    'https://challenges.cloudflare.com/*',
]


# ─────────────────────────────────────────────────────────────
# COOKIES / STORAGE
# ─────────────────────────────────────────────────────────────

# Accept cookies globally.
c.content.cookies.accept = 'all'

# Persist cookies between browser sessions.
c.content.cookies.store = True


# ─────────────────────────────────────────────────────────────
# MEDIA
# ─────────────────────────────────────────────────────────────

c.content.autoplay = True

c.content.media.audio_capture = True
c.content.media.video_capture = True


# ─────────────────────────────────────────────────────────────
# NOTIFICATIONS
# ─────────────────────────────────────────────────────────────

c.content.notifications.enabled = True


# ─────────────────────────────────────────────────────────────
# GEOLOCATION
# ─────────────────────────────────────────────────────────────

# Don't automatically expose location.
c.content.geolocation = False


# ─────────────────────────────────────────────────────────────
# PROXY
# ─────────────────────────────────────────────────────────────

# Leave normal browsing on the system/default connection.
#
# Your Ctrl+Shift+P binding below toggles Burp.
#
# c.content.proxy = 'system'


# ─────────────────────────────────────────────────────────────
# SITE-SPECIFIC SETTINGS
# ─────────────────────────────────────────────────────────────

# Google
#
# Keep the Firefox UA you already configured specifically for
# Google accounts.
config.set(
    'content.headers.user_agent',
    'Mozilla/5.0 ({os_info}; rv:149.0) Gecko/20100101 Firefox/149.0',
    'https://accounts.google.com/*'
)


# GNOME GitLab
#
# Keep the existing qutebrowser-compatible UA override.
config.set(
    'content.headers.user_agent',
    'Mozilla/5.0 ({os_info}) AppleWebKit/{webkit_version} '
    '(KHTML, like Gecko) {qt_key}/{qt_version} '
    '{upstream_browser_key}/{upstream_browser_version_short} '
    'Safari/{webkit_version}',
    'https://gitlab.gnome.org/*'
)


# Krunker
config.set(
    'content.headers.accept_language',
    '',
    'https://matchmaker.krunker.io/*'
)


# Duck.ai clipboard
config.set(
    'content.javascript.clipboard',
    'access-paste',
    'https://duck.ai'
)


# ─────────────────────────────────────────────────────────────
# CONTENT BLOCKING
# ─────────────────────────────────────────────────────────────

c.content.blocking.enabled = True
c.content.blocking.method = 'adblock'

c.content.blocking.adblock.lists = [
    'https://easylist.to/easylist/easylist.txt',
    'https://easylist.to/easylist/easyprivacy.txt',
]


# ─────────────────────────────────────────────────────────────
# IMAGES
# ─────────────────────────────────────────────────────────────

c.content.images = True


# ─────────────────────────────────────────────────────────────
# LOCAL CONTENT
# ─────────────────────────────────────────────────────────────

c.content.local_content_can_access_remote_urls = True
c.content.local_content_can_access_file_urls = True


# ─────────────────────────────────────────────────────────────
# CLIPBOARD
# ─────────────────────────────────────────────────────────────

c.content.javascript.clipboard = 'access'


# ─────────────────────────────────────────────────────────────
# AUDIO / VIDEO
# ─────────────────────────────────────────────────────────────

c.content.media.audio_capture = True
c.content.media.video_capture = True


# ─────────────────────────────────────────────────────────────
# NOTIFICATIONS
# ─────────────────────────────────────────────────────────────

c.content.notifications.enabled = True


# ─────────────────────────────────────────────────────────────
# EDITOR
# ─────────────────────────────────────────────────────────────

c.editor.command = [
    'kitty',
    'nvim',
    '{}',
]


# ─────────────────────────────────────────────────────────────
# HINTS
# ─────────────────────────────────────────────────────────────

c.hints.radius = 8


# ─────────────────────────────────────────────────────────────
# TABS
# ─────────────────────────────────────────────────────────────

c.tabs.padding = {
    'top': 6,
    'bottom': 6,
    'left': 10,
    'right': 10,
}


# ─────────────────────────────────────────────────────────────
# START PAGE
# ─────────────────────────────────────────────────────────────

c.url.default_page = (
    'file:///home/kamal/.config/qutebrowser/startpage.html'
)

c.url.start_pages = [
    'file:///home/kamal/.config/qutebrowser/startpage.html'
]


# ─────────────────────────────────────────────────────────────
# SEARCH ENGINES
# ─────────────────────────────────────────────────────────────

c.url.searchengines = {
    'DEFAULT': 'https://www.duckduckgo.com/search?q={}',
    'g': 'https://www.google.com/search?q={}',
}


# ─────────────────────────────────────────────────────────────
# COLORS
# ─────────────────────────────────────────────────────────────

c.colors.completion.fg = '#dbcace'

c.colors.completion.odd.bg = '#0b0a17'
c.colors.completion.even.bg = '#0b0a17'

c.colors.completion.category.fg = '#A58AA0'
c.colors.completion.category.bg = '#0b0a17'

c.colors.completion.category.border.top = '#998d90'
c.colors.completion.category.border.bottom = '#998d90'

c.colors.completion.item.selected.fg = '#0b0a17'
c.colors.completion.item.selected.bg = '#A58AA0'

c.colors.completion.item.selected.border.top = '#A58AA0'
c.colors.completion.item.selected.border.bottom = '#A58AA0'

c.colors.completion.item.selected.match.fg = '#0b0a17'

c.colors.completion.match.fg = '#E3AA9D'

c.colors.completion.scrollbar.fg = '#A58AA0'
c.colors.completion.scrollbar.bg = '#0b0a17'


# ─────────────────────────────────────────────────────────────
# CONTEXT MENU
# ─────────────────────────────────────────────────────────────

c.colors.contextmenu.menu.bg = '#0b0a17'
c.colors.contextmenu.menu.fg = '#dbcace'

c.colors.contextmenu.selected.bg = '#A58AA0'
c.colors.contextmenu.selected.fg = '#0b0a17'


# ─────────────────────────────────────────────────────────────
# DOWNLOADS
# ─────────────────────────────────────────────────────────────

c.colors.downloads.bar.bg = '#0b0a17'

c.colors.downloads.start.fg = '#0b0a17'
c.colors.downloads.start.bg = '#A58AA0'

c.colors.downloads.stop.fg = '#0b0a17'
c.colors.downloads.stop.bg = '#E3AA9D'

c.colors.downloads.error.fg = '#0b0a17'
c.colors.downloads.error.bg = '#98849E'


# ─────────────────────────────────────────────────────────────
# HINTS COLORS
# ─────────────────────────────────────────────────────────────

c.colors.hints.fg = '#0b0a17'
c.colors.hints.bg = '#A58AA0'
c.colors.hints.match.fg = '#E3AA9D'


# ─────────────────────────────────────────────────────────────
# ERROR MESSAGES
# ─────────────────────────────────────────────────────────────

c.colors.messages.error.fg = '#0b0a17'
c.colors.messages.error.bg = '#98849E'
c.colors.messages.error.border = '#98849E'


# ─────────────────────────────────────────────────────────────
# WARNING MESSAGES
# ─────────────────────────────────────────────────────────────

c.colors.messages.warning.fg = '#98849E'
c.colors.messages.warning.bg = '#0b0a17'
c.colors.messages.warning.border = '#98849E'


# ─────────────────────────────────────────────────────────────
# INFO MESSAGES
# ─────────────────────────────────────────────────────────────

c.colors.messages.info.fg = '#dbcace'
c.colors.messages.info.bg = '#0b0a17'
c.colors.messages.info.border = '#998d90'


# ─────────────────────────────────────────────────────────────
# PROMPTS
# ─────────────────────────────────────────────────────────────

c.colors.prompts.fg = '#dbcace'
c.colors.prompts.border = '1px solid #998d90'
c.colors.prompts.bg = '#0b0a17'

c.colors.prompts.selected.fg = '#0b0a17'
c.colors.prompts.selected.bg = '#A58AA0'


# ─────────────────────────────────────────────────────────────
# STATUSBAR
# ─────────────────────────────────────────────────────────────

c.colors.statusbar.normal.fg = '#dbcace'
c.colors.statusbar.normal.bg = '#0b0a17'

c.colors.statusbar.insert.fg = '#0b0a17'
c.colors.statusbar.insert.bg = '#A58AA0'

c.colors.statusbar.command.fg = '#dbcace'
c.colors.statusbar.command.bg = '#0b0a17'

c.colors.statusbar.progress.bg = '#A58AA0'

c.colors.statusbar.url.fg = '#dbcace'

c.colors.statusbar.url.error.fg = '#98849E'

c.colors.statusbar.url.success.http.fg = '#E3AA9D'
c.colors.statusbar.url.success.https.fg = '#E3AA9D'

c.colors.statusbar.url.warn.fg = '#98849E'


# ─────────────────────────────────────────────────────────────
# TABS COLORS
# ─────────────────────────────────────────────────────────────

c.colors.tabs.bar.bg = '#0b0a17'

c.colors.tabs.indicator.start = '#E3AA9D'
c.colors.tabs.indicator.stop = '#A58AA0'
c.colors.tabs.indicator.error = '#98849E'

c.colors.tabs.odd.fg = '#dbcace'
c.colors.tabs.odd.bg = '#0b0a17'

c.colors.tabs.even.fg = '#dbcace'
c.colors.tabs.even.bg = '#0b0a17'

c.colors.tabs.selected.odd.fg = '#0b0a17'
c.colors.tabs.selected.odd.bg = '#A58AA0'

c.colors.tabs.selected.even.fg = '#0b0a17'
c.colors.tabs.selected.even.bg = '#A58AA0'


# ─────────────────────────────────────────────────────────────
# WEBPAGE
# ─────────────────────────────────────────────────────────────

c.colors.webpage.bg = '#0b0a17'


# ─────────────────────────────────────────────────────────────
# CUSTOM KEYBINDINGS
# ─────────────────────────────────────────────────────────────

# mpv
config.bind(
    ',m',
    'spawn --detach mpv '
    '--ytdl-format="bestvideo[height<=?1080]+bestaudio/best" '
    '{url}'
)

# streamlink
config.bind(
    ',v',
    'spawn --detach streamlink '
    '--player vlc {url} best'
)

# Burp Suite proxy
config.bind(
    '<Ctrl+Shift+p>',
    'config-cycle content.proxy http://127.0.0.1:8070 none'
)

# Teams
config.bind(
    ',t',
    'spawn --userscript open-teams'
)


# ─────────────────────────────────────────────────────────────
# WAL COLORS
# ─────────────────────────────────────────────────────────────

try:
    config.source('colors-wal.py')
except Exception:
    pass
