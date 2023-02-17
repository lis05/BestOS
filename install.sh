#!/bin/bash

# this script completelly installs BestOS to a freshly installed minimal Arch Linux system

#! PAMAC
sudo pacman -S --noconfirm --needed git base-devel
git clone https://aur.archlinux.org/libpamac-aur.git
cd libpamac-aur
makepkg -si --noconfirm
cd ..
git clone https://aur.archlinux.org/pamac-aur.git
cd pamac-aur
makepkg -si --noconfirm
cd ..

#! basic software

sudo pacman -S --noconfirm --needed xorg-server                     # Xorg
sudo pacman -S --noconfirm --needed xf86-video-amdgpu               # video drivers
sudo pacman -S --noconfirm --needed mesa                            # OpenGL
sudo pacman -S --noconfirm --needed lib32-mesa                      # OpenGL  

sudo pacman -S --noconfirm --needed sddm                            # display manager
sudo systemctl enable sddm

sudo pacman -S --noconfirm --needed qtile                           # Qtile
sudo mkdir /etc/sddm.conf.d
sudo cp files/sddm-config /etc/sddm.conf.d/default.conf

#! software
sudo pacman -S --noconfirm --needed xterm
sudo pacman -S --noconfirm --needed terminology
sudo pacman -S --noconfirm --needed firefox
sudo pacman -S --noconfirm --needed telegram-dekstop      

sudo pacman -S --noconfirm --needed lolcat                           

echo "DONE! BestOS has been installed, reboot now to see the changes" | lolcat




