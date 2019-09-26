#!/bin/bash

# Global Variables
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
    xclip
)
SNAP_APPLICATIONS=(
    spotify
)
VS_CODE_EXTENSIONS=(
    dracula-theme.theme-dracula
    esbenp.prettier-vscode
    octref.vetur
    eamodio.gitlens
)

printf "Updating System & Packages...\n"
sudo pacman -Syu

printf "Installing 'git' and 'zsh'...\n"
sudo pacman --needed --noconfirm -S git zsh

printf "Changing Default Shell to 'zsh'...\n"
chsh -s /usr/bin/zsh

printf "Installing 'oh-my-zsh'...\n"
yay --needed --noconfirm -S oh-my-zsh-git

printf "Installing 'yay'...\n"
git clone $YAY_GIT_REPO
cd /yay
makepkg -si --needed --noconfirm
cd ..
rm -rf yay/

printf "Installing 'snap'...\n"
git clone $SNAP_GIT_REPO
cd /snapd
makepkg -si --needed --noconfirm
sudo systemctl enable --now snapd.socket
cd ..
rm -rf snapd/

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

printf "Installing VS Code Extensions...\n"
for i in "${VS_CODE_EXTENSIONS[@]}"
do
    printf "Installing VS Code Extension $i...\n"
    code --install-extension "$i"
done

printf "Cleaning Cached Packages...\n"
yay --noconfirm -Sc

printf "Setup Complete!"
