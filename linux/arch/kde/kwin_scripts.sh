# Copy kwin scripts from dotfiles to .local directory

# Get the script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Define the relative DOTFILES_PATH
DOTFILES_PATH="$SCRIPT_DIR/.local/share/kwin/scripts"
LOCAL_PATH=".local/share/kwin/scripts"

# Define colors for output
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Check if the target directory exists, create it if not
if [ ! -d ~/$LOCAL_PATH ]; then
	mkdir -p ~/$LOCAL_PATH
fi

# List kwin scripts
scripts=($(ls "$DOTFILES_PATH"))

echo -e "${YELLOW}Please choose which kwin scripts to copy (separate choices with a space):${NC}"
for i in "${!scripts[@]}"; do
	echo -e "${GREEN}$((i + 1)))${NC} ${scripts[i]}"
done
echo -e "${BLUE}a) All scripts${NC}"
echo -e "${RED}q) Exit${NC}"

read -p "Enter your choices (e.g., '1 2' or 'a'): " choices

# Convert the choices string into an array
IFS=' ' read -ra choice_array <<<"$choices"

copy_kwin_script() {
	script_name=${scripts[$1]}
	cp -r "$DOTFILES_PATH/$script_name" ~/$LOCAL_PATH/"$script_name"
	echo -e "${GREEN}Copied kwin script: $script_name${NC}"
}

for choice in "${choice_array[@]}"; do
	case $choice in
	a | A)
		for i in "${!scripts[@]}"; do
			copy_kwin_script "$i"
		done
		;;

	q | Q)
		echo -e "${GREEN}Exiting without copying any scripts.${NC}"
		exit 0
		;;

	*)
		if [[ $choice -ge 1 && $choice -le ${#scripts[@]} ]]; then
			copy_kwin_script "$((choice - 1))"
		else
			echo -e "${RED}Invalid choice. Exiting.${NC}"
			exit 1
		fi
		;;
	esac
done
