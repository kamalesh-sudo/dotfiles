-- ~/.config/hypr/startup.lua

-------------------------------
-- ANIMATIONS -----------------
-------------------------------

pcall(function()
    hl.config({
        animations = {
            enabled = true,
        },
    })

    hl.curve("yahpaxEaseOut", {
        type = "bezier",
        points = {
            { 0.22, 1.0 },
            { 0.36, 1.0 },
        },
    })

    hl.animation({
        leaf = "global",
        enabled = true,
        speed = 2,
        bezier = "yahpaxEaseOut",
    })

    hl.animation({
        leaf = "windows",
        enabled = true,
        speed = 2,
        bezier = "yahpaxEaseOut",
        style = "popin 95%",
    })

    hl.animation({
        leaf = "windowsIn",
        enabled = true,
        speed = 2,
        bezier = "yahpaxEaseOut",
        style = "popin 95%",
    })

    hl.animation({
        leaf = "windowsOut",
        enabled = true,
        speed = 2,
        bezier = "yahpaxEaseOut",
        style = "popin 95%",
    })

    hl.animation({
        leaf = "fade",
        enabled = true,
        speed = 2,
        bezier = "yahpaxEaseOut",
    })

    hl.animation({
        leaf = "fadeSwitch",
        enabled = true,
        speed = 2,
        bezier = "yahpaxEaseOut",
    })

    hl.animation({
        leaf = "workspaces",
        enabled = true,
        speed = 2,
        bezier = "yahpaxEaseOut",
        style = "slidefade 12%",
    })

    hl.animation({
        leaf = "workspacesIn",
        enabled = true,
        speed = 2,
        bezier = "yahpaxEaseOut",
        style = "slidefade 12%",
    })

    hl.animation({
        leaf = "workspacesOut",
        enabled = true,
        speed = 2,
        bezier = "yahpaxEaseOut",
        style = "slidefade 12%",
    })

    hl.animation({
        leaf = "specialWorkspace",
        enabled = true,
        speed = 2,
        bezier = "yahpaxEaseOut",
        style = "slidefade 12%",
    })

    hl.animation({
        leaf = "specialWorkspaceIn",
        enabled = true,
        speed = 2,
        bezier = "yahpaxEaseOut",
        style = "slidefade 12%",
    })

    hl.animation({
        leaf = "specialWorkspaceOut",
        enabled = true,
        speed = 2,
        bezier = "yahpaxEaseOut",
        style = "slidefade 12%",
    })

    hl.animation({
        leaf = "border",
        enabled = true,
        speed = 2,
        bezier = "yahpaxEaseOut",
    })

    hl.animation({
        leaf = "borderangle",
        enabled = false,
    })
end)


-------------------------------
-- AUTOSTART / STARTUP --------
-------------------------------

hl.on("hyprland.start", function()
    hl.exec_cmd(
        "~/.config/quickshell/yahpax/launch.fish"
    )
end)


-------------------------------
-- SHUTDOWN ------------------
-------------------------------

hl.on("hyprland.shutdown", function()
    hl.exec_cmd(
        "~/.config/quickshell/yahpax/logout-cleanup.fish"
    )
end)
