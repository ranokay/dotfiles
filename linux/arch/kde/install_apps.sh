# Install Brave Browser
paru -S brave-bin

# Install Microsoft Teams
paru -S teams

# Install MEGASync
paru -S megasync-bin

# Install GitHub CLI
sudo pacman -S github-cli

# Install VLC
sudo pacman -S vlc

# Install Visual Studio Code
paru -S visual-studio-code-bin

# Install Spotify
paru -S spotify

# Install 1Password
paru -S 1password

# Install Docker
sudo pacman -S docker

# Install Telegram
sudo pacman -S telegram-desktop

# Install Unison
sudo pacman -S unison

# Add the current user to the docker group
sudo usermod -aG docker $USER

echo "Installation complete. You may need to restart your system for some changes to take effect."
