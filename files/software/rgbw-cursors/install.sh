#!/bin/bash
rsync -r ./ $HOME/.icons/rgbw-cursors/
mkdir -p $HOME/.icons/default
mkdir -p $HOME/.config/gtk-3.0
cp default-index.theme $HOME/.icons/default/index.theme
cp gtk3-settings.ini ~/.config/gtk-3.0/settings.ini