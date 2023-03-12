# Path: install.sh
# check if zsh is installed and install it if not
if ! [ -x "$(command -v zsh)" ]; then
	echo 'Installing zsh'
	sudo apt install zsh
fi

# check if oh-my-zsh is installed and install it if not
if ! [ -x "$(command -v oh-my-zsh)" ]; then
	echo 'Installing oh-my-zsh'
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# check if zsh-autosuggestions is installed and install it if not
if ! [ -x "$(command -v zsh-autosuggestions)" ]; then
	echo 'Installing zsh-autosuggestions'
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

	# add zsh-autosuggestions to plugins in .zshrc
	sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/g' ~/.zshrc
fi

# check if zsh-syntax-highlighting is installed and install it if not
if ! [ -x "$(command -v zsh-syntax-highlighting)" ]; then
	echo 'Installing zsh-syntax-highlighting'
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

	# add zsh-syntax-highlighting to plugins in .zshrc
	sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting)/g' ~/.zshrc
fi

# check if zsh-completions is installed and install it if not
if ! [ -x "$(command -v zsh-completions)" ]; then
	echo 'Installing zsh-completions'
	git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions

	# add zsh-completions to FPATH in .zshrc before sourcing oh-my-zsh
	sed -i 's/source $ZSH\/oh-my-zsh.sh/source $ZSH\/oh-my-zsh.sh\n\n fpath=($ZSH_CUSTOM\/plugins\/zsh-completions\/src $fpath)/g' ~/.zshrc

# check if .gitconfig exists and remove it
if [ -f ~/.gitconfig ]; then
	echo 'Removing .gitconfig'
	rm ~/.gitconfig
fi

# check if .bashrc exists and remove it
if [ -f ~/.bashrc ]; then
	echo 'Removing .bashrc'
	rm ~/.bashrc
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
ln -s ~/*dotfiles/.gitconfig ~/.gitconfig
ln -s ~/*dotfiles/linux/.bashrc ~/.bashrc
ln -s ~/*dotfiles/linux/.zprofile ~/.zprofile
ln -s ~/*dotfiles/linux/.zshrc ~/.zshrc
ln -s ~/*dotfiles/.config/starship.toml ~/.config/starship.toml

# Echo success message
echo 'Successfully installed dotfiles'
