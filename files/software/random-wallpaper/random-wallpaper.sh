#!/bin/bash
image="$(shuf -e $(ls $HOME/software/random-wallpaper/images) -n 1)"
feh --bg-scale "$HOME/software/random-wallpaper/images/$image"
