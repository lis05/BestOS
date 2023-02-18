#!/bin/bash

# this script completelly installs BestOS to a freshly installed minimal Arch Linux system

#! creating all neccessary directories      
sudo mkdir /etc/sddm.conf.d
mkdir $HOME/scripts
mkdir $HOME/software
mkdir $HOME/.config


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
pacman-install xorg-server xf86-video-amdgpu mesa 

# display manager
pacman-install sddm                                                 
sudo systemctl enable sddm

# python
pamac-install python3 python-pip

# AwesomeWM
pacman-install awesome         
sudo cp files/sddm-config /etc/sddm.conf.d/default.conf

#! software
pacman-install xterm terminology                            # terminals
pacman-install firefox                                      # webbrowsers
pamac-install kate micro vim                                # text editors  
pacman-install telegram-dekstop                             # messagers
pamac-install brightnessctl                             
pamac-install flameshot                                     # screenshot tool
pamac-install rofi                                     
pamac-install rofi-pass                                   
cp files/change-lang.sh $HOME/scripts/change-lang.sh
pacman-install lolcat             

# system-stats-server for awesome widgets
cd $HOME/software
git clone https://github.com/lis05/system-stats-server
cd system-stats-server
bash install.sh
cd $HOME/BestOS

echo "DONE! BestOS has been installed, reboot now to see the changes" | lolcat




