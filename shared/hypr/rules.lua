-- ~/.config/hypr/rules.lua

--------------------------------
-- WINDOWS AND WORKSPACES -----
--------------------------------

---------------------
-- WINDOW RULES ----
---------------------

-- Suppress maximize events
local suppressMaximizeRule = hl.window_rule({
    name = "suppress-maximize-events",

    match = {
        class = ".*",
    },

    suppress_event = "maximize",
})

-- suppressMaximizeRule:set_enabled(false)


---------------------
-- XWAYLAND DRAGS --
---------------------

hl.window_rule({
    name = "fix-xwayland-drags",

    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})


---------------------
-- HYPRLAND RUN ----
---------------------

hl.window_rule({
    name = "move-hyprland-run",

    match = {
        class = "hyprland-run",
    },

    move  = "20 monitor_h-120",
    float = true,
})


---------------------
-- THUNAR -----------
---------------------

hl.window_rule({
    name = "thunar-style",

    match = {
        class = "^thunar$",
    },

    opacity = 0.75,
})


---------------------
-- KDE EMOJI --------
---------------------

hl.window_rule({
    name = "emoji-selector-style",

    match = {
        class = "^org%.kde%.plasma%.emojier$",
    },

    float = true,
    opacity = 0.75,
})


---------------------
-- KDE CONNECT ------
---------------------

hl.window_rule({
    name = "kdeconnect-glass",

    match = {
        class = "^org.kde.kdeconnect.*$",
    },

    opacity = 0.75,
})


---------------------
-- GLOBAL OPACITY ---
---------------------

hl.window_rule({
    name = "global-transparency",

    match = {
        class = ".*",
    },

    opacity = 0.85,
})


---------------------
-- LAYER RULES -----
---------------------

-- Example overlay rule
--
-- local overlayLayerRule = hl.layer_rule({
--     name = "no-anim-overlay",
--
--     match = {
--         namespace = "^my-overlay$",
--     },
--
--     no_anim = true,
-- })
--
-- overlayLayerRule:set_enabled(false)


---------------------
-- VANTAGE BLUR ----
---------------------

hl.config({
    decoration = {
        blur = {
            enabled = true,
        },
    },
})


hl.layer_rule({
    match = {
        namespace = "quickshell-bar",
    },

    blur = true,
    ignore_alpha = 0.08,
})
