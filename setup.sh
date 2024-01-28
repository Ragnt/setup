#!/bin/bash

echo "Initial Setup"
sudo apt update && sudo apt upgrade -y

echo
echo "Installing Tools/Dependencies"
sudo apt install neovim zsh curl make gcc g++ cmake pkg-config libfontconfig-dev git -y

echo
echo "Installing Rust/Cargo"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

echo
echo "Installing alacritty"
cargo install alacritty

echo
echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo
echo "Installing Fonts"
mkdir -p ~/.local/share/fonts && cp -r fonts/ ~/.local/share/
fc-cache -f -v

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
sudo apt install sway swaylock waybar wdisplays lxpolkit kanshi wofi rofi dunst neofetch zathura brightnessctl pavucontrol -y
sudo usermod -aG video ${USER}
sudo systemctl disable polkit
sudo systemctl mask polkit

echo
echo "Installing dotfiles"
cp -r config/ ~/.config/

echo
echo "Installing wallpapers"
cp -r wallpapers ~/

echo "Installing Wireshark"
sudo apt install wireshark -y
sudo usermod -aG wireshark ${USER}

echo
echo "Installing Signal"
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
  sudo tee /etc/apt/sources.list.d/signal-xenial.list

sudo apt update && sudo apt install signal-desktop -y

echo
echo "Installing Steam"
sudo add-apt-repository multiverse -y
sudo apt update
sudo apt install steam -y
# Install mangohud
sudo apt install mangohud -y
# Build gamemode
sudo apt install meson libsystemd-dev pkg-config ninja-build git libdbus-1-dev libinih-dev build-essential
git clone https://github.com/FeralInteractive/gamemode.git
cd gamemode
./bootstrap.sh
sudo apt install linux-tools-common -y
sudo apt install linux-tools-$(uname -r) linux-tools-generic -y

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
echo "Installing nvidia Drivers + CUDA-TOOLKIT"
sudo ubuntu-drivers install
sudo apt install nvidia-cuda-toolkit nvidia-cuda-toolkit-gcc -y
# Patch sway for the new drivers
sudo sed -i "s/Exec=sway/Exec=sway --unsupported-gpu/g" /usr/share/wayland-sessions/sway.desktop

echo
echo "Installing Sublime"
wget "https://download.sublimetext.com/sublime-text_build-3211_amd64.deb" -O sublime.deb
sudo dpkg -i sublime.deb


