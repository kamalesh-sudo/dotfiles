-- ~/.config/hypr/keybinds.lua

---------------------
-- PROGRAMS --------
---------------------

local terminal    = "kitty"
local fileManager = "kitty yazi"
local browser     = "qutebrowser"
local music       = "/opt/Spun/scripts/run.sh"
local notes       = "obsidian"
local code        = "vscodium"
local monitor     = "kitty --start-as=fullscreen -e btop"

local mainMod = "SUPER"
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())


---------------------
-- SLEEP / POWER ---
---------------------

hl.bind(mainMod .. " + L",
    hl.dsp.exec_cmd("hyprlock"))

hl.bind("CTRL + ALT + DELETE",
    hl.dsp.exec_cmd("systemctl poweroff"))


---------------------
-- APPLICATIONS ----
---------------------

hl.bind(mainMod .. " + PERIOD",
    hl.dsp.exec_cmd("plasma-emojier"))

hl.bind(mainMod .. " + Return",
    hl.dsp.exec_cmd(terminal))

hl.bind(mainMod .. " + E",
    hl.dsp.exec_cmd(fileManager))

-- hl.bind(mainMod .. " + R",
--     hl.dsp.exec_cmd("hyprlauncher"))

hl.bind(mainMod .. " + B",
    hl.dsp.exec_cmd(browser))

hl.bind(mainMod .. " + O",
    hl.dsp.exec_cmd(notes))

hl.bind(mainMod .. " + ALT + O",
    hl.dsp.exec_cmd(code))

hl.bind(mainMod .. " + M",
    hl.dsp.exec_cmd(music))

hl.bind(mainMod .. " + grave",
    hl.dsp.exec_cmd(monitor))


---------------------
-- YAHPAX ----------
---------------------

local yahpax = "qs -p /home/kamal/.config/quickshell/yahpax"

hl.bind(mainMod .. " + SPACE",
    hl.dsp.exec_cmd(yahpax .. " ipc call appLauncher toggle"))

hl.bind(mainMod .. " + W",
    hl.dsp.exec_cmd(yahpax .. " ipc call wallpaperSelector toggle"))

hl.bind(mainMod .. " + V",
    hl.dsp.exec_cmd(yahpax .. " ipc call clipboardHistory toggle"))

hl.bind(mainMod .. " + N",
    hl.dsp.exec_cmd(yahpax .. " ipc call notifications toggle"))


---------------------
-- SCREEN RECORDING -
---------------------
-- Start partial recording
hl.bind(
    mainMod .. " + R",
    hl.dsp.exec_cmd([[
        sh -c '
            mkdir -p "$HOME/Videos/Recordings"

            gpu-screen-recorder \
                -w screen \
                -f 60 \
                -o "$HOME/Videos/Recordings/$(date +%Y-%m-%d_%H-%M-%S).mp4" &

            echo $! > "$XDG_RUNTIME_DIR/yahpax-recorder.pid"
        '
    ]])
)
-- Start partial recording
hl.bind(
    mainMod .. " + ALT + R",
    hl.dsp.exec_cmd(
        [[
        sh -c '
            mkdir -p "$HOME/Videos/Recordings"

            region=$(slurp | sed -E "s/^([0-9]+),([0-9]+) ([0-9]+x[0-9]+)$/\3+\1+\2/")
            [ -n "$region" ] || exit 0

            gpu-screen-recorder \
                -w "$region" \
                -f 60 \
                -o "$HOME/Videos/Recordings/$(date +%Y-%m-%d_%H-%M-%S).mp4"
        '
        ]]
    )
)

-- Stop recording
hl.bind(
    mainMod .." + ALT + X",
    hl.dsp.exec_cmd(
        [[
        pkill gpu-screen-reco
        ]]
    )
)

hl.bind(mainMod .. "+ CTRL+ S",
    hl.dsp.exec_cmd([[mkdir -p "$HOME/Pictures/Screenshots/tmp" && grim -g "$(slurp)" "$HOME/Pictures/Screenshots/tmp/$(date +'%Y-%m-%d_%H-%M-%S').png"]]))
hl.bind(mainMod .. "+ ALT+ S",
    hl.dsp.exec_cmd([[mkdir -p "$HOME/Pictures/Screenshots/tmp" && grim "$HOME/Pictures/Screenshots/tmp/$(date +'%Y-%m-%d_%H-%M-%S').png"]]))

---------------------
-- FULLSCREEN -------
---------------------

-- Maximized
hl.bind(
    mainMod .. " + ALT + F",
    hl.dsp.window.fullscreen({
        mode = "maximized",
        action = "toggle"
    })
)

-- True fullscreen
hl.bind(
    mainMod .. " + F",
    hl.dsp.window.fullscreen({
        mode = "fullscreen",
        action = "toggle"
    })
)


---------------------
-- RESIZE -----------
---------------------

-- hl.bind(mainMod .. " + Z", "Right",
--     hl.dsp.resizeactive({ res = "20 0" }))

-- hl.bind(mainMod .. " + Z", "Left",
--     hl.dsp.resizeactive({ res = "-20 0" }))

-- hl.bind(mainMod .. " + Z", "Up",
--     hl.dsp.resizeactive({ res = "0 -20" }))

-- hl.bind(mainMod .. " + Z", "Down",
--     hl.dsp.resizeactive({ res = "0 20" }))


---------------------
-- WORKSPACES ------
---------------------

-- Previous workspace
hl.bind(
    mainMod .. " + TAB",
    hl.dsp.focus({ workspace = "prev" })
)

-- Next workspace
hl.bind(
    mainMod .. " + G",
    hl.dsp.focus({ workspace = "m+1" })
)

-- Empty workspace
hl.bind(
    mainMod .. " + D",
    hl.dsp.focus({ workspace = "empty" })
)


---------------------
-- WORKSPACE 1-5 ---
---------------------

for i = 1, 5 do
    local key = i % 10

    -- Focus workspace
    hl.bind(
        mainMod .. " + " .. key,
        hl.dsp.focus({ workspace = i })
    )

    -- Move window to workspace
    hl.bind(
        mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = i })
    )
end


---------------------
-- WORKSPACE NEXT ---
---------------------

hl.bind(
    mainMod .. " + CTRL + right",
    function()
        local ws = hl.get_active_workspace().id

        if ws < 5 then
            hl.dispatch(
                hl.dsp.focus({ workspace = "r+1" })
            )
        else
            hl.dispatch(
                hl.dsp.focus({ workspace = 1 })
            )
        end
    end
)


---------------------
-- WORKSPACE PREV ---
---------------------

hl.bind(
    mainMod .. " + CTRL + left",
    function()
        local ws = hl.get_active_workspace().id

        if ws > 1 then
            hl.dispatch(
                hl.dsp.focus({ workspace = "r-1" })
            )
        else
            hl.dispatch(
                hl.dsp.focus({ workspace = 5 })
            )
        end
    end
)


---------------------
-- SPECIAL WORKSPACE
---------------------

hl.bind(
    mainMod .. " + S",
    hl.dsp.workspace.toggle_special("magic")
)

hl.bind(
    mainMod .. " + SHIFT + S",
    hl.dsp.window.move({
        workspace = "special:magic"
    })
)

hl.bind(
    mainMod .. " + A",
    hl.dsp.workspace.toggle_special("hidden")
)

hl.bind(
    mainMod .. " + SHIFT + A",
    hl.dsp.window.move({
        workspace = "special:hidden"
    })
)


---------------------
-- MOUSE ------------
---------------------

-- Move window between workspaces
hl.bind(
    mainMod .."+ ALT + left",
    hl.dsp.window.move({ workspace = "r-1" })
)

hl.bind(
    mainMod .." + ALT + right",
    hl.dsp.window.move({ workspace = "r+1" })
)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))
-- Scroll through workspaces
hl.bind(
    mainMod .. " + mouse_down",
    hl.dsp.focus({ workspace = "e+1" })
)

hl.bind(
    mainMod .. " + mouse_up",
    hl.dsp.focus({ workspace = "e-1" })
)

-- Move window with left mouse
hl.bind(
    mainMod .. " + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true }
)

-- Resize window with right mouse
hl.bind(
    mainMod .. " + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true }
)


---------------------
-- MULTIMEDIA -------
---------------------

-- Volume up
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(
        "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
    ),
    {
        locked = true,
        repeating = true
    }
)

-- Volume down
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd(
        "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ),
    {
        locked = true,
        repeating = true
    }
)

-- Mute
hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    ),
    {
        locked = true,
        repeating = true
    }
)

-- Microphone mute
hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ),
    {
        locked = true,
        repeating = true
    }
)


---------------------
-- BRIGHTNESS -------
---------------------

hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd(
        "brightnessctl -e4 -n2 set 5%+"
    ),
    {
        locked = true,
        repeating = true
    }
)

hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd(
        "brightnessctl -e4 -n2 set 5%-"
    ),
    {
        locked = true,
        repeating = true
    }
)


---------------------
-- MEDIA PLAYER -----
---------------------

hl.bind(
    "XF86AudioNext",
    hl.dsp.exec_cmd("playerctl next"),
    {
        locked = true
    }
)

hl.bind(
    "XF86AudioPause",
    hl.dsp.exec_cmd("playerctl play-pause"),
    {
        locked = true
    }
)

hl.bind(
    "XF86AudioPlay",
    hl.dsp.exec_cmd("playerctl play-pause"),
    {
        locked = true
    }
)

hl.bind(
    "XF86AudioPrev",
    hl.dsp.exec_cmd("playerctl previous"),
    {
        locked = true
    }
)


-------------------------------
-- BIND OPTIONS ---------------
-------------------------------

hl.config({
    binds = {
        hide_special_on_workspace_change = true
    }
})
