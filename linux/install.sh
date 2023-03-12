# Path: install.sh
# check if zsh is installed and install it if not
if ! [ -x "$(command -v zsh)" ]; then
	echo 'Installing zsh'
	sudo apt install zsh
fi

# check if oh-my-zsh is installed  and install it if not
if ! [ -d ~/.oh-my-zsh ]; then
	echo 'Installing oh-my-zsh'
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# check if zsh-autosuggestions is installed and install it if not
if ! [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]; then
	echo 'Installing zsh-autosuggestions'
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# check if zsh-syntax-highlighting is installed and install it if not
if ! [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]; then
	echo 'Installing zsh-syntax-highlighting'
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Check if starship is installed and install it if not
if ! [ -x "$(command -v starship)" ]; then
	echo 'Installing starship'
	curl -fsSL https://starship.rs/install.sh | bash
fi

# create symlinks
ln -sf ~/*dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/*dotfiles/linux/.bashrc ~/.bashrc
ln -sf ~/*dotfiles/linux/.zprofile ~/.zprofile
ln -sf ~/*dotfiles/linux/.zshrc ~/.zshrc
ln -sf ~/*dotfiles/.config/starship.toml ~/.config/starship.toml

# Echo success message
echo 'Successfully installed dotfiles'
