# Path: install.sh
# check if zsh is installed and install it if not
if ! [ -x "$(command -v zsh)" ]; then
	echo 'Installing zsh'
	sudo apt install zsh
fi

# check if .gitconfig exists and remove it
if [ -f ~/.gitconfig ]; then
	echo 'Removing .gitconfig'
	rm ~/.gitconfig
fi

# check if .zprofile exists and remove it
if [ -f ~/.zprofile ]; then
	echo 'Removing .zprofile'
	rm ~/.zprofile
fi

# check if .zshrc exists and remove it
if [ -f ~/.zshrc ]; then
	echo 'Removing .zshrc'
	rm ~/.zshrc
fi

# check if .bashrc exists and remove it
if [ -f ~/.bashrc ]; then
	echo 'Removing .bashrc'
	rm ~/.bashrc
fi

# Check if starship is installed and install it if not
if ! [ -x "$(command -v starship)" ]; then
	echo 'Installing starship'
	curl -fsSL https://starship.rs/install.sh | bash
fi

# check if .config/starship.toml exists and remove it
if [ -f ~/.config/starship.toml ]; then
	echo 'Removing .config/starship.toml'
	rm ~/.config/starship.toml
fi

# create symlinks
ln -s ~/oxy-dotfiles/.gitconfig ~/.gitconfig
ln -s ~/oxy-dotfiles/linux/.zprofile ~/.zprofile
ln -s ~/oxy-dotfiles/linux/.zshrc ~/.zshrc
ln -s ~/oxy-dotfiles/linux/.bashrc ~/.bashrc
ln -s ~/oxy-dotfiles/linux/.config/starship.toml ~/.config/starship.toml

# Echo success message
echo 'Successfully installed dotfiles'
