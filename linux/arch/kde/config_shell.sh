# Install configuration files for zsh and starship on Arch Linux

# Define colors for output
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Get the script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Define the relative ARCH_PATH
ARCH_PATH="$SCRIPT_DIR"
COMMON_PATH=~/dotfiles/common

# Install zsh if not already installed
if ! [ -x "$(command -v zsh)" ]; then
	echo -e "${YELLOW}Installing zsh...${NC}"
	sudo apt install zsh
fi

# Install oh-my-zsh if not already installed
if ! [ -d ~/.oh-my-zsh ]; then
	echo -e "${YELLOW}Installing oh-my-zsh...${NC}"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install zsh-autosuggestions if not already installed
if ! [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]; then
	echo -e "${YELLOW}Installing zsh-autosuggestions...${NC}"
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# Install zsh-syntax-highlighting if not already installed
if ! [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]; then
	echo -e "${YELLOW}Installing zsh-syntax-highlighting...${NC}"
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Install starship if not already installed
if ! [ -x "$(command -v starship)" ]; then
	echo -e "${YELLOW}Installing starship...${NC}"
	curl -sS https://starship.rs/install.sh | sh
fi

# Install exa if not already installed
if ! [ -x "$(command -v exa)" ]; then
	echo -e "${YELLOW}Installing exa...${NC}"
	sudo apt install exa
fi

# Create symlinks to the dotfiles
ln -sf "$ARCH_PATH/.bashrc" ~/.bashrc
ln -sf "$ARCH_PATH/.zprofile" ~/.zprofile
ln -sf "$ARCH_PATH/.zshrc" ~/.zshrc
ln -sf "$COMMON_PATH/.config/starship.toml" ~/.config/starship.toml
ln -sf "$COMMON_PATH/.aliases" ~/.aliases

# Echo success message colorized in green
echo -e "${GREEN}Successfully installed dotfiles${NC}"
