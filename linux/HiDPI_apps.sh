# Apply HiDPI scaling settings for KDE Plasma apps

DOTFILES_PATH="dotfiles/linux/.local/share/applications"
LOCAL_PATH=".local/share/applications"

# Brave Browser
# Create symlink
ln -sf ~/$DOTFILES_PATH/brave-browser.desktop ~/$LOCAL_PATH/brave-browser.desktop
# Set the executable permission
# sudo chmod +x ~/.local/share/applications/brave-browser.desktop

# All apps
# Create symlinks
ln -sf ~/$DOTFILES_PATH/*.desktop ~/$LOCAL_PATH/*.desktop
# Set the executable permission for the custom desktop files, which allows them to be launched as an application from the menu
sudo chmod +x ~/$LOCAL_PATH/*.desktop
