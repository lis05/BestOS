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


function pacman-install() {
    for package in "$@"; do
        echo -e "\033[1;35mInstalling $package (pacman)\033[0m"
        sudo pacman -S --noconfirm --needed "$package"
    done
}
function pamac-install() {
    for package in "$@"; do
        echo -e "\033[1;35mInstalling $package (pamac)\033[0m"
        sudo pamac install --no-confirm "$package"
    done
}
#! basic software
# Xorg, video drivers, openGL
pacman-install xorg-server xf86-video-amdgpu mesa lib32-mesa   
     
# display manager
pacman-install sddm                                                 
sudo systemctl enable sddm

# Qtile
pacman-install qtile                           
sudo mkdir /etc/sddm.conf.d
sudo cp files/sddm-config /etc/sddm.conf.d/default.conf

#! software
pacman-install xterm terminology firefox telegram-dekstop  
pacman-install lolcat                           

echo "DONE! BestOS has been installed, reboot now to see the changes" | lolcat




