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
sudo cp files/pamac.conf /etc/pamac.conf


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

pacman-install rsync # tool for merging directories

#! basic software
# Xorg, video drivers, openGL
pacman-install xorg-server xf86-video-amdgpu mesa 

# display manager
pacman-install sddm                                                 
sudo systemctl enable sddm

# libs and other stuff
pamac-install python3 python-pip
python3 -m pip install psutil pid

# AwesomeWM
pacman-install awesome         
sudo cp files/sddm-config /etc/sddm.conf.d/default.conf # SDDM

#! software
pamac-install xterm terminology  
pamac-install firefox                            
pamac-install kate micro vim                  
pamac-install telegram-desktop                                 
pamac-install brightnessctl                       
pamac-install flameshot                                   
pamac-install rofi rofi-pass   
pamac-install alsa-utils
pamac-install yad
pamac-install volumeicon
pamac-install picom
pamac-install lolcat figlet     
pamac-install feh          
pamac-install polkit-dumb-agent-git 
pamac-install network-manager-applet  

# system-stats-server for awesome widgets
cd $HOME/software
git clone https://github.com/lis05/system-stats-server
cd system-stats-server
bash install.sh
cd $HOME/BestOS


#! configs, scripts, themes, etc
rsync -r files/.config/ $HOME/.config/
rsync -r files/software/ $HOME/software/
rsync -r files/scripts/ $HOME/scripts/

#! BestOS software install
cd files/software

cd random-wallpaper
sudo bash install
cd ..


cd $HOME

echo -e "DONE! BestOS has been installed, reboot now to see the changes\n" | lolcat
figlet "BestOS" | lolcat



