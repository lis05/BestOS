pcall(require, "luarocks.loader")


--? AWESOME MODULES =====================================
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local theme = require("theme")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")
require("awful.autofocus")

beautiful.init(os.getenv("HOME").."/.config/awesome/theme.lua")

HOME=os.getenv("HOME")

--? AWESOME ERROR CHECKING =====================================
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors })
end
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err) })
        in_error = false
    end)
end


--? DEFAULT AWESOME THINGS =====================================
local modkey = "Mod4"
local altkey = "Mod1"
local shiftkey = "Shift"
local controlkey = "Control"


--? DEFAULT APPS =====================================
local terminal = "kitty"
local editor = "kate"


--? FUNCTIONS =====================================
local function restart_awesome()
    awesome.restart()
end

local function send_notification(s)
    awful.spawn.with_shell("notify-send 'Notification' "..s)
end

local function add_brightness_send_notification(delta)
    awful.spawn.with_shell("brightnessctl set "..delta)
    send_notification("\"Brightness: $(python3 -c \"print(int(round($(brightnessctl get)/255*100,1)))\")%\"")
end


-- TODO TOP BAR =====================================
local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })
local mykeyboardlayout = awful.widget.keyboardlayout()
local mytextclock = wibox.widget.textclock()
local month_calendar = awful.widget.calendar_popup.month()
month_calendar:attach( mytextclock, "tr" )
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )
local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))


local DATE_COLOR="#66ff00" -- TODO
local UNDERLINE_HEIGHT=3
local UNDERLINE_MARGIN=2
local WIBAR_HEIGHT=26

awful.screen.connect_for_each_screen(function(s)
    --awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.suit.floating)
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.suit.tile.right)
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    s.topbar = awful.wibar({ position = "top", screen = s, height=WIBAR_HEIGHT })
    s.topbar:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(true),
            {
                {

                    mytextclock,
                    bottom=UNDERLINE_HEIGHT,
                    color=DATE_COLOR,
                    widget=wibox.container.margin
                },
                left = UNDERLINE_MARGIN,
                right = UNDERLINE_MARGIN,
                layout=wibox.container.margin
            },
        },
    }
end)


--? BOTTOM BAR
local os_info_widget=require("widgets.os_info_widget")
local cpu_info_widget=require("widgets.cpu_info_widget")
local memory_info_widget=require("widgets.memory_info_widget")
local battery_info_widget=require("widgets.battery_info_widget")
local net_info_widget=require("widgets.net_info_widget")
local disks_info_widget=require("widgets.disks_info_widget")
local sep=wibox.widget.textbox(" ")

local function pretty_widget(widget,color)
    return
    {
        {

            widget,
            bottom=3,
            color=color,
            widget=wibox.container.margin
        },
        left=3,
        right=3,
        layout=wibox.container.margin
    }
end

awful.screen.connect_for_each_screen(function(s)
    s.bottombar = awful.wibar({ position = "bottom", screen = s, height=26 })
    s.bottombar:setup {
        layout = wibox.layout.fixed.horizontal,
        pretty_widget(os_info_widget,theme.os_info_widget_color),sep,
        pretty_widget(cpu_info_widget,theme.cpu_info_widget_color),sep,
        pretty_widget(memory_info_widget,theme.memory_info_widget_color),sep,
        pretty_widget(battery_info_widget,theme.battery_info_widget_color),sep,
        pretty_widget(net_info_widget,theme.net_info_widget_color),sep,
        pretty_widget(disks_info_widget,theme.disks_info_widget_color),sep,
    }
end)

--? GLOBAL KEYBINDINGS
local globalkeys = gears.table.join()
local function add_global_keybinding(key1,key2,func,description)
    globalkeys=gears.table.join(globalkeys,
        awful.key(
            key1,key2,
            func,
            {description=description,group="global keybindings"}
        )
    )
end

add_global_keybinding(
    {modkey}, "Return",
    function() awful.spawn(terminal) end,
    "open a terminal"
)

add_global_keybinding(
    {}, "Print",
    function() awful.spawn.with_shell("flameshot gui") end,
    "take screenshot"
)

add_global_keybinding(
    {}, "#232", -- F2 fn
    function() add_brightness_send_notification("10%-") end,
    "decrease brightness"
)

add_global_keybinding(
    {}, "#233", -- F3 fn
    function() add_brightness_send_notification("+10%") end,
    "increase brightness"
)

add_global_keybinding(
    {modkey}, "r",
    function() awful.spawn.with_shell("rofi -show drun") end,
    "run rofi -show drun"
)

add_global_keybinding(
    {modkey}, "e",
    function() awful.spawn.with_shell("rofi -show run") end,
    "run rofi -show run"
)

add_global_keybinding(
    {altkey}, "#52", -- z
    function() awful.spawn.with_shell(HOME.."/scripts/change-lang.sh") end,
    "change language"
)

--dd_global_keybinding(
--    {modkey}, "s", 
--    hotkeys_popup.show_help,-- bugged
--    "show keybindings help"
--)

add_global_keybinding(
    {modkey}, "p", 
    function() awful.spawn.with_shell("rofi-pass") end,
    "run password panager"
)

add_global_keybinding(
    {modkey,shiftkey}, "r",
    restart_awesome,
    "restart awesome"
)

add_global_keybinding(
    {modkey,controlkey}, "r",
    restart_awesome,
    "restart awesome"
)


-- workspace keybindings
for i = 1, 9 do
    add_global_keybinding(
        {altkey}, "F"..i, 
        function()
            local screen = awful.screen.focused();
            local tag = screen.tags[i];
            if tag then tag:view_only() end
        end,
        "show workspace"
    )

    add_global_keybinding(
        {altkey,shiftkey}, "F"..i, 
        function ()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then client.focus:move_to_tag(tag) end
            end
        end,
        "show workspace"
    )
end

root.keys(globalkeys)


--? CLIENT KEYBINDINGS =====================================
local clientkeys = gears.table.join()
local function add_client_keybinding(key1,key2,func,description)
    clientkeys=gears.table.join(clientkeys,
        awful.key(
            key1,key2,
            func,
            {description=description,group="client keybindings"}
        )
    )
end

add_client_keybinding(
    {modkey}, "f",
    function(c) c.fullscreen=not c.fullscreen; c:raise() end,
    "toggle fullscreen"
)

add_client_keybinding(
    {modkey}, "c",
    function(c) c:kill() end,
    "kill client"
)

add_client_keybinding(
    {modkey}, "h",
    function(c) c.minimized = true  end,
    "hide client"
)

add_client_keybinding(
    {modkey}, "m",
    function(c) c.maximized=not c.maximized; c:raise() end,
    "(un)mazimize client"
)

-- client manipulation 
add_client_keybinding(
    {modkey}, "Left",
    function() awful.client.focus.bydirection("left") end,
    "focus client on the left"
)

add_client_keybinding(
    {modkey}, "Right",
    function() awful.client.focus.bydirection("right") end,
    "focus client on the right"
)

add_client_keybinding(
    {modkey}, "Up",
    function() awful.client.focus.bydirection("up") end,
    "focus client on the top"
)

add_client_keybinding(
    {modkey}, "Down",
    function() awful.client.focus.bydirection("down") end,
    "focus client on the bottom"
)

add_client_keybinding(
    {modkey,shiftkey}, "Left",
    function() awful.client.swap.bydirection("left") end,
    "swap client on the left"
)

add_client_keybinding(
    {modkey,shiftkey}, "Right",
    function() awful.client.swap.bydirection("right") end,
    "swap client on the right"
)

add_client_keybinding(
    {modkey,shiftkey}, "Up",
    function() awful.client.swap.bydirection("up") end,
    "swap client on the top"
)

add_client_keybinding(
    {modkey,shiftkey}, "Down",
    function() awful.client.swap.bydirection("down") end,
    "swap client on the bottom"
)

add_client_keybinding(
    {modkey}, "space",
    function() awful.client.focus.byidx(1) end,
    "focus the next client"
)


-- TODO ADD KEYBINDINGS TO CHANGE CLIENT'S SIZE

--? CLIENT MOUSEBINDINGS =====================================
local clientbuttons = gears.table.join()
local function add_client_mousebinding(key,button,func)
    clientbuttons = gears.table.join(clientbuttons,
        awful.button(
            key,button,
            func
        )
    )
end

add_client_mousebinding(
    {}, 1,
    function(c) c:emit_signal("request::activate", "mouse_click", {raise = true}) end
)

add_client_mousebinding(
    {modkey}, 1,        
    function(c) c:emit_signal("request::activate", "mouse_click", {raise = true}); awful.mouse.client.move(c) end
)

add_client_mousebinding(
    {modkey}, 3,        
    function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}); awful.mouse.client.resize(c) end
)


--? RULES =====================================
awful.rules.rules = {
    {
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    }
}


--? SIGNALS =====================================
client.connect_signal("manage", function (c)
    if not awesome.startup then awful.client.setslave(c) end
    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)
--client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus;end)
--client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal;end)

-- Animate active borders
-- Gradient generator, adapted from https://krazydad.com/tutorials/makecolors.php
local border_animate_colours = {}
local len=0

local hexcolor=function(red,green,blue)
    return "#"..string.format("%06x",red*256*256+green*256+blue)
end

local generate_colors=function()
    local red=255
    local green=0
    local blue=0
    local step=6
    table.insert(border_animate_colours,hexcolor(red,green,blue))
    len=len+1
    -- #ff0000 -> #ffff00
    while green ~= 255 do
        green=green+step
        if green>=255 then green=255 end
        table.insert(border_animate_colours,hexcolor(red,green,blue))
        len=len+1
    end
    -- #ffff00 -> #00ff00
    while red ~= 0 do
        red=red-step
        if red<=0 then red=0 end
        table.insert(border_animate_colours,hexcolor(red,green,blue))
        len=len+1
    end
    -- #00ff00 -> #00ffff
    while blue ~= 255 do
        blue=blue+step
        if blue>=255 then blue=255 end
        table.insert(border_animate_colours,hexcolor(red,green,blue))
        len=len+1
    end

    -- #00ffff -> #0000ff
    while green ~= 0 do
        green=green-step
        if green<=0 then green=0 end
        table.insert(border_animate_colours,hexcolor(red,green,blue))
        len=len+1
    end

    -- #0000ff -> #ff00ff
    while red ~= 255 do
        red=red+step
        if red>=255 then red=255 end
        table.insert(border_animate_colours,hexcolor(red,green,blue))
        len=len+1
    end

    -- #ff00ff -> #ff0000
    while blue ~= 0 do
        blue=blue-step
        if blue<=0 then blue=0 end
        table.insert(border_animate_colours,hexcolor(red,green,blue))
        len=len+1
    end
end

generate_colors()
awful.spawn.with_shell("notify-send "..hexcolor(255,255,127))
local borderLoop = 1
local border_animation_timer = gears.timer {
  timeout   = 0.03,
  call_now  = true,
  autostart = true,
  callback  = function()
    -- debug
    -- naughty.notify({ preset = naughty.config.presets.critical, title = "- " .. borderLoop .. " -", bg = border_animate_colours[borderLoop], notification_border_width = 0 })
    local c = client.focus
    if c then
        c.border_color = border_animate_colours[borderLoop]
        borderLoop = borderLoop + 1
        if borderLoop >= len then borderLoop=1 end
    end
  end
}

-- window borders
-- client.connect_signal("focus", function(c) c.border_color = "#ecbc34" end)
client.connect_signal("focus", function(c)
c.border_color = border_animate_colours[borderLoop]
end)

client.connect_signal("border_animation_timer:timeout", function(c)
  c.border_color = border_animate_colours[borderLoop]
end)

-- Make border transparent black on unfocus
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)




--! KILL ALREADY RUNNING PROGRAMS
awful.spawn.with_shell("killall /bin/bash -c '"..HOME.."/scripts/mute-micro.sh'")
awful.spawn.with_shell("killall volumeicon")


--? AUTOSTART APPLICATIONS
awful.spawn.with_shell("picom") -- compositor
awful.spawn.with_shell(HOME.."/scripts/mirror-monitors.sh") -- mirror both monitors
awful.spawn.with_shell("brightnessctl set 50%") -- set brightness
awful.spawn.with_shell("xset s off && xset -dpms && xset s noblank") -- turn off display blanking
awful.spawn.with_shell("polkit-dumb-agent")
awful.spawn.with_shell("flameshot") -- screenshot tool
awful.spawn.with_shell("nm-applet --indicator") -- network manager
awful.spawn.with_shell("volumeicon") -- volume control
awful.spawn.with_shell("/usr/bin/bash -c "..HOME.."/scripts/mute-micro.sh") -- microphone mute script

awful.spawn.with_shell("sleep 5 && ~/scripts/mirror-monitors.sh") -- mirror both monitors
awful.spawn.with_shell("~/software/random-wallpaper/random-wallpaper.sh")
