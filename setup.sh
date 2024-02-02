#!/bin/bash

echo WARNING:
echo "Run 'sudo apt update && sudo apt upgrade -y && reboot' manually before running this script."
echo "Failing to do so may result in undefined behavior."
echo
echo "Staring in 5 seconds..."
sleep 4;
echo "Initial Setup"
sudo apt update && sudo apt upgrade -y

echo
echo "Installing Tools/Dependencies"
sudo apt install neovim zsh curl make gcc g++ cmake pkg-config libfontconfig-dev git flameshot -y

echo
echo "Installing Rust/Cargo"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

echo
echo "Installing alacritty"
cargo install alacritty
sudo ln -1 $HOME/.cargo/bin/alacritty /usr/bin/alacritty
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
sudo cp extra/alacritty.desktop /usr/share/applications/

echo
echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo
echo "Installing Fonts"
mkdir -p $HOME/.local/share/fonts && cp -r fonts/ $HOME/.local/share/
fc-cache -f -v
sudo cp local.conf /etc/fonts/

echo
echo "Installing Powerlevel10k"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's@ZSH_THEME="robbyrussell"@ZSH_THEME="powerlevel10k/powerlevl10k"@g' ~/.zshrc

echo
echo "Installing zsh-autosuggestions and autocomplete fallback"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/3v1n0/zsh-bash-completions-fallback ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-bash-completions-fallback
sed -i 's@plugins=(git)@plugins=(git zsh-autosuggestions zsh-bash-completions-fallback)@g' ~/.zshrc

echo
echo "Installing Sway + Utilities"
sudo apt install sway waybar wdisplays lxpolkit kanshi wofi rofi dunst neofetch zathura brightnessctl pavucontrol -y
sudo usermod -aG video ${USER}
sudo systemctl disable polkit
sudo systemctl mask polkit

git clone https://github.com/mortie/swaylock-effects.git
cd swaylock-effects
meson build
ninja -C build
sudo ninja -C build install
sudo chmod +s /usr/local/bin/swaylock

echo
echo "Installing dotfiles"
cp -r config/* $HOME/.config/

echo
echo "Installing wallpapers"
cp -r wallpapers $HOME

echo "Installing Wireshark"
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt install wireshark -y
sudo usermod -aG wireshark ${USER}

echo
echo "Installing Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

echo
echo "Installing LibreOffice"
sudo apt install libreoffice -y

echo
echo "Installing Obsidian"
curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep -e "amd64.deb" | grep "browser_download_url" | cut -d : -f 2,3 | tr -d \" | wget --show-progress -qi -
sudo dpkg -i obsidian*.deb

echo
echo "Installing VSCode"
wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -O code.deb
sudo dpkg -i code.deb

echo
echo "Updating Desktop Database"
sudo update-desktop-database

sudo sed -i 's:\[daemon\]:\[daemon\]\nDefaultSession=sway.desktop:g' /etc/gdm3/custom.conf

echo
echo "Setting up aliases"
echo "alias vim='nvim'" >> $HOME/.zshrc
echo "alias svim='sudo nvim'" >> $HOME/.zshrc

echo "COMPLETE!"
echo '#### SCRIPT WILL REBOOT IN 5 SECONDS ####'
sleep 1
echo '#### SCRIPT WILL REBOOT IN 4 SECONDS ####'
sleep 1
echo '#### SCRIPT WILL REBOOT IN 3 SECONDS ####'
sleep 1
echo '#### SCRIPT WILL REBOOT IN 2 SECONDS ####'
sleep 1
echo '#### SCRIPT WILL REBOOT IN 1 SECONDS ####'
sleep 1
reboot
