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

# Check if exa is installed and install it if not
if ! [ -x "$(command -v exa)" ]; then
	echo 'Installing exa'
	sudo apt install exa
fi

# Define the path to the dotfiles
DOTFILES_PATH="oxy-dotfiles"

# create symlinks to the dotfiles
ln -sf ~/$DOTFILES_PATH/.gitconfig ~/.gitconfig
ln -sf ~/$DOTFILES_PATH/linux/.bashrc ~/.bashrc
ln -sf ~/$DOTFILES_PATH/linux/.zprofile ~/.zprofile
ln -sf ~/$DOTFILES_PATH/linux/.zshrc ~/.zshrc
ln -sf ~/$DOTFILES_PATH/.config/starship.toml ~/.config/starship.toml

# Echo success message colorized in green
echo "\e[32mSuccessfully installed dotfiles\e[0m"
