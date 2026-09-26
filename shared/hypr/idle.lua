-- ~/.config/hypr/idle.lua

-----------------------
-- HYPR IDLE ---------
-----------------------

hl.on("hyprland.start", function()
    hl.timer(function()
        hl.exec_cmd(
            "hypridle -c /home/kamal/.config/hypr/hypridle.conf >> /tmp/hypridle.log 2>&1"
        )
    end, {
        timeout = 1000,
        type = "oneshot",
    })
end)
