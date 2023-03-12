# Path: install.sh
# check if zsh is installed
if ! [ -x "$(command -v zsh)" ]; then
	echo 'Error: zsh is not installed.' >&2
	exit 1
fi

# check if .zshenv exists and move it to .zshenv.bak
if [ -f ~/.zshenv ]; then
	mv ~/.zshenv ~/.zshenv.bak
fi

# check if .zprofile exists and move it to .zprofile.bak
if [ -f ~/.zprofile ]; then
	mv ~/.zprofile ~/.zprofile.bak
fi

# check if .zshrc exists and move it to .zshrc.bak
if [ -f ~/.zshrc ]; then
	mv ~/.zshrc ~/.zshrc.bak
fi

# check if .gitconfig exists and move it to .gitconfig.bak
if [ -f ~/.gitconfig ]; then
	mv ~/.gitconfig ~/.gitconfig.bak
fi

# check if .bashrc exists and move it to .bashrc.bak
if [ -f ~/.bashrc ]; then
	mv ~/.bashrc ~/.bashrc.bak
fi

# install starship
curl -sS https://starship.rs/install.sh | sh

# check if .config/starship.toml exists and move it to .config/starship.toml.bak
if [ -f ~/.config/starship.toml ]; then
	mv ~/.config/starship.toml ~/.config/starship.toml.bak
fi


# create symlinks
ln -s ~/oxy-config/.zshenv ~/.zshenv
ln -s ~/oxy-config/.zprofile ~/.zprofile
ln -s ~/oxy-config/.zshrc ~/.zshrc
ln -s ~/oxy-config/.gitconfig ~/.gitconfig
ln -s ~/oxy-config/.bashrc ~/.bashrc
ln -s ~/oxy-config/.config/starship.toml ~/.config/starship.toml
