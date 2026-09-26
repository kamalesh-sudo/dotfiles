-- ~/.config/hypr/settings.lua

------------------
-- MONITORS -----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "1",
})


---------------------
-- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "kitty yazi"
local browser     = "qutebrowser"
local music       = "/opt/Spun/scripts/run.sh"
local notes       = "obsidian"
local code        = "vscodium"
local monitor     = "kitty --start-as=fullscreen -e btop"


-------------------------------
-- ENVIRONMENT VARIABLES -----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
-- PERMISSIONS -------
-----------------------

hl.config({
    ecosystem = {
        enforce_permissions = true,
    },
})

hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")
hl.permission("/usr/(bin|local/bin)/hyprlock", "screencopy", "allow")


-----------------------
-- LOOK AND FEEL -----
-----------------------

hl.config({
    general = {
        gaps_in  = 2,
        gaps_out = 2,

        border_size = 2,

        col = {
            active_border   = "rgba(33ccffee)",
            inactive_border = "rgba(33ccff88)",
        },

        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding       = 2,
        rounding_power = 20,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 8,
            passes   = 4,
            vibrancy = 0.3,
        },
    },
})


-----------------------
-- RICE / COLORS -----
-----------------------

package.loaded["colors-wal"] = nil
pcall(require, "colors-wal")


-----------------------
-- LAYOUTS -----------
-----------------------

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})


----------------
-- MISC --------
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
    },
})


----------------
-- INPUT -------
----------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})
