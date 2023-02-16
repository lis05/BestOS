#!/bin/bash

# this script completelly installs BestOS to a freshly installed minimal Arch Linux system

# PAMAC
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/libpamac-aur.git
cd libpamac-aur
makepkg -si
cd ..
git clone https://aur.archlinux.org/pamac-aur.git
cd pamac-aur
makepkg -si
cd ..