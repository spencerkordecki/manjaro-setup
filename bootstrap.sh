#!/bin/bash

# Global Variables
GIT_USER_EMAIL="spencerkordecki@gmail.com"
GIT_USER_NAME="Spencer Kordecki"
YAY_GIT_REPO="https://aur.archlinux.org/yay.git"
SNAP_GIT_REPO="https://aur.archlinux.org/snapd.git"
CONFIG_DIRECTORY=~/.config/
USER_APPLICATIONS=(
    telegram-desktop-bin
    visual-studio-code-bin
)
DEVELOPMENT_TOOLS=(
    docker-git
    npm
    nodejs
)
SNAP_APPLICATIONS=(
    spotify
)

printf "Updating System & Packages...\n"
sudo pacman -Syu

printf "Installing 'git' and 'zsh'...\n"
sudo pacman --needed --noconfirm -S git zsh

printf "Configuring 'git'...\n"
git config --global user.email $GIT_USER_EMAIL
git config --global user.name $GIT_USER_NAME

printf "Changing Default Shell to 'zsh'...\n"
chsh -s /usr/bin/zsh

printf "Installing 'oh-my-zsh'...\n"
yay --needed --noconfirm -S oh-my-zsh-git

printf "Installing 'yay'...\n"
git clone $YAY_GIT_REPO /tmp/yay
cd /tmp/yay
makepkg -si --needed --noconfirm

printf "Installing 'snap'...\n"
git clone $SNAP_GIT_REPO /tmp/snap
cd /tmp/snap
makepkg -si --needed --noconfirm
sudo systemctl enable --now snapd.socket

printf "Installing User Applications...\n"
for i in "${USER_APPLICATIONS[@]}"
do
    printf "Installing $i...\n"
    yay --needed --noconfirm -S "$i"
done

printf "Installing Development Tools...\n"
for i in "${DEVELOPMENT_TOOLS[@]}"
do
    printf "Installing $i...\n"
    yay --needed --noconfirm -S "$i"
done

printf "Installing 'snap' Applicatons...\n"
for i in "${SNAP_APPLICATIONS[@]}"
do
    printf "Installing $i...\n"
    snap install "$i"
done

printf "Copying Files from config/ to ~/.config/...\n"
shopt -s dotglob
for f in $(find config/* -type f)
do
    file=$(basename "$f")
    fileDirectory=$(dirname "$f")
    targetFile=${CONFIG_DIRECTORY}${f}
    targetDirectory=${CONFIG_DIRECTORY}${fileDirectory}
    if [ ! -e $targetFile ]
    then
        if [ ! -d $targetDirectory ]
        then
            mkdir -p $targetDirectory
        fi
        touch $targetFile
    fi
    
    # Use /bin/cp to prevent removing the 'cp -i alias' from bashrc
    printf "Copying $f...\n"
    /bin/cp -R $f $targetFile
done

printf "Cleaning Cached Packages...\n"
yay --noconfirm -Sc

printf "Removing /tmp directory...\n"
sudo rm -rf /tmp

printf "Setup Complete!"
