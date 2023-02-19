local wibox=require("wibox")
local theme=require("theme")
local watch = require("awful.widget.watch")

local display_text = wibox.widget{
    font = theme.widgets_font,
    widget = wibox.widget.textbox,
}
local the_widget = wibox.widget.background()
the_widget:set_widget(display_text) 
display_text:set_text("none")

the_widget.text_color=theme.os_info_widget_color
the_widget:set_fg(the_widget.text_color)

local home=os.getenv("HOME")

watch("python3 "..home.."/.config/awesome/widgets/formatted-output.py os_info_widget", 10, function(widget, stdout, stderr, exitreason, exitcode)
    display_text:set_text(stdout)
  end,
  the_widget
)

return the_widget
