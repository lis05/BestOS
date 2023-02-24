#!/bin/bash
rsync -r ./ $HOME/.icons/rgbw-cursors/
cp default-index.theme $HOME/.icons/default/index.theme
cp gtk3-settings.ini ~/.config/gtk-3.0/settings.ini