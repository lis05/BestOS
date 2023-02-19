pcall(require, "luarocks.loader")

-- basic modules ========================================================
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local theme=require("themes.default.theme")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), "default")
beautiful.init(theme_path)
beautiful.font=theme.font

-- custom modules ========================================================

-- error checking ========================================================
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end



-- preferred apps ========================================================
terminal="terminology"
web_browser="firefox"
file_manager="mc"
editor="kate"

menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- modkeys ========================================================
modkey = "Mod4"

-- functions ========================================================
function restart_awesome()
    awful.spawn.with_shell("killall /bin/bash -c '/home/lis05st/scripts/mute-micro.sh'")
    awful.spawn.with_shell("killall volumeicon")
    awesome.restart()
end

function send_notification(s)
    awful.spawn.with_shell("notify-send 'Notification' "..s)
end

function add_brightness_send_notification(delta)
    awful.spawn.with_shell("brightnessctl set "..delta)
    send_notification("\"Brightness: $(python3 -c \"print(int(round($(brightnessctl get)/255*100,1)))\")%\"")
end

-- awesome menu ========================================================
mymainmenu = awful.menu({ items = {
                                    { "open terminal", terminal },
                                    { "edit config", editor .. " " .. awesome.conffile },
                                    { "restart awesome", restart_awesome }
                                  }
                        })


-- wibar widgets ========================================================
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })
mykeyboardlayout = awful.widget.keyboardlayout()
mytextclock = wibox.widget.textclock()
month_calendar = awful.widget.calendar_popup.month()
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

-- custom widgets ========================================================
local ram_usage = require("my-widgets.ram-usage")
local cpu_data = require("my-widgets.cpu-data")
local battery_data = require("my-widgets.battery-data")
local os_data = require("my-widgets.os-data")
local separator=wibox.widget.textbox(" ")

-- wibar setup ========================================================
DATE_COLOR="#66ff00" -- TODO
UNDERLINE_HEIGHT=3
UNDERLINE_MARGIN=2
WIBAR_HEIGHT=26

awful.screen.connect_for_each_screen(function(s)
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.suit.floating)
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

    s.mywibox = awful.wibar({ position = "top", screen = s, height=WIBAR_HEIGHT })
    s.mywibox:setup {
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

            separator,
            {
                {

                    os_data,
                    bottom=UNDERLINE_HEIGHT,
                    color=os_data.text_color,
                    widget=wibox.container.margin
                },
                left = UNDERLINE_MARGIN,
                right = UNDERLINE_MARGIN,
                layout=wibox.container.margin
            },

            separator,
            {
                {

                    cpu_data,
                    bottom=UNDERLINE_HEIGHT,
                    color=cpu_data.text_color,
                    widget=wibox.container.margin
                },
                left = UNDERLINE_MARGIN,
                right = UNDERLINE_MARGIN,
                layout=wibox.container.margin
            },

            separator,
            {
                {

                    ram_usage,
                    bottom=UNDERLINE_HEIGHT,
                    color=ram_usage.text_color,
                    widget=wibox.container.margin
                },
                left = UNDERLINE_MARGIN,
                right = UNDERLINE_MARGIN,
                layout=wibox.container.margin
            },

            separator,
            {
                {

                    battery_data,
                    bottom=UNDERLINE_HEIGHT,
                    color=battery_data.text_color,
                    widget=wibox.container.margin
                },
                left = UNDERLINE_MARGIN,
                right = UNDERLINE_MARGIN,
                layout=wibox.container.margin
            },

            separator,
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

-- mouse settings ========================================================
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))


-- global keybindings ========================================================
globalkeys = gears.table.join(
    -- apps
    awful.key(
        {modkey}, "Return",
        function() awful.spawn(terminal) end,
        {description="open a terminal",group="apps"}
    ),

    -- tools
    awful.key(
        {}, "Print",
        function() awful.spawn.with_shell("flameshot gui") end,
        {description="take a screenshot",group="tools"}
    ),
    awful.key(
        {}, "#232", -- F2 fn
        function() add_brightness_send_notification("10%-") end,
        {description="decrease brightness",group="tools"}
    ),
    awful.key(
        {}, "#233", -- F3 fn
        function() add_brightness_send_notification("+10%") end,
        {description="increase brightness",group="tools"}
    ),
    awful.key(
        {modkey}, "r",
        function() awful.spawn.with_shell("rofi -show drun") end,
        {description="run rofi drun",group="tools"}
    ),
    awful.key(
        {"Mod1"}, "#52",
        function() awful.spawn.with_shell("/home/lis05st/scripts/change-lang.sh") end,
        {description="run rofi drun",group="tools"}
    ),
    awful.key(
        {modkey}, "p",
        function() awful.spawn.with_shell("rofi-pass") end,
        {description="password manager",group="tools"}
    ),

    -- help
    awful.key(
        {modkey}, "s",
        hotkeys_popup.show_help,
        {description="show keybindings help",group="help"}
    ),

    -- system
    awful.key(
        {modkey, "Shift"}, "r",
        restart_awesome,
        {description="restart awesome",group="system"}
    )
)
-- workspace keybindings
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View workspace only.
        awful.key(
            {"Mod1"}, "F" .. i,
            function()
                local screen = awful.screen.focused();
                local tag = screen.tags[i];
                if tag then tag:view_only() end
            end,
            {description="view workspace "..i,group="workspace"}
        ),
        -- Move client to workspace
        awful.key(
            {modkey, "Shift"}, "F" .. i,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then client.focus:move_to_tag(tag) end
                end
            end,
            {description="move focused client to workspace #"..i,group="workspace"}
        )
    )
end
root.keys(globalkeys)

-- client keybindings ========================================================
clientkeys = gears.table.join(
    awful.key(
        {modkey}, "f",
        function(c) c.fullscreen=not c.fullscreen; c:raise() end,
        {description="toggle fullscreen",group="client"}
    ),
    awful.key(
        {modkey}, "c",
        function(c) c:kill() end,
        {description="close a client",group="client"}
    ),
    awful.key(
        {modkey}, "h",
        function(c) c.minimized = true  end,
        {description="minimize a client",group="client"}
    ),
    awful.key({modkey}, "m",
        function(c) c.maximized=not c.maximized; c:raise() end,
        {description="(un)maximize a client",group="client"}
    )
)

-- client mousebindings ========================================================
clientbuttons = gears.table.join(
    awful.button(
        {}, 1,
        function(c) c:emit_signal("request::activate", "mouse_click", {raise = true}) end
    ),
    awful.button(
        {modkey}, 1,
        function(c) c:emit_signal("request::activate", "mouse_click", {raise = true}); awful.mouse.client.move(c) end
    ),
    awful.button(
        {modkey}, 3,
        function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}); awful.mouse.client.resize(c) end
    )
)


-- rules ========================================================
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
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


-- signals ========================================================
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)




-- autostart programs ========================================================
-- compositor
awful.spawn.with_shell("picom")

-- mirror both monitors
awful.spawn.with_shell("~/scripts/mirror-monitors.sh")

-- set brightness
awful.spawn.with_shell("brightnessctl set 50%")

-- restore the wallpaper
awful.spawn.with_shell("nitrogen --restore")

-- turn off display blanking
awful.spawn.with_shell("xset s off && xset -dpms && xset s noblank")

-- disable touchpad TODO: the device number may change
--awful.spawn.with_shell("xinput disable 19")

-- polkit for visual password prompts
awful.spawn.with_shell("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

-- screenshot tool
awful.spawn.with_shell("flameshot")

-- network manager
awful.spawn.with_shell("nm-applet --indicator")

-- volume control
awful.spawn.with_shell("volumeicon")

-- microphone mute script
awful.spawn.with_shell("/usr/bin/bash -c /home/lis05st/scripts/mute-micro.sh")

-- data server for widgets
awful.spawn.with_shell("/home/lis05st/scripts/awesome-data-for-widgets/server.py")


-- in case when the wallpaper didn't restore itself
awful.spawn.with_shell("sleep 5 && nitrogen --restore") -- if the first try didnt help

