# Apply HiDPI scaling settings for KDE Plasma apps

DOTFILES_PATH="dotfiles/linux/.local/share/applications"
LOCAL_PATH=".local/share/applications"

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

# List apps
apps=($(ls ~/$DOTFILES_PATH))

echo -e "${YELLOW}Please choose which settings to apply (separate choices with a space):${NC}"
for i in "${!apps[@]}"; do
	app_name=${apps[i]%.*}
	echo -e "${GREEN}$((i + 1))) ${app_name^}${NC}"
done
echo -e "${BLUE}a) All apps${NC}"
echo -e "${RED}q) Exit${NC}"

read -p "Enter your choices (e.g., '1 2' or 'a'): " choices

# Convert the choices string into an array
IFS=' ' read -ra choice_array <<<"$choices"

apply_app_settings() {
	app=${apps[$1]}
	ln -sf ~/$DOTFILES_PATH/"$app" ~/$LOCAL_PATH/"$app"
	sudo chmod +x ~/$LOCAL_PATH/"$app"
	app_name=${app%.*}
	echo -e "${GREEN}${app_name^} settings applied.${NC}"
}

for choice in "${choice_array[@]}"; do
	case $choice in
	a | A)
		for i in "${!apps[@]}"; do
			apply_app_settings "$i"
		done
		;;

	q | Q)
		echo -e "${RED}Exiting without applying any settings.${NC}"
		exit 0
		;;

	*)
		if [[ $choice -ge 1 && $choice -le ${#apps[@]} ]]; then
			apply_app_settings "$((choice - 1))"
		else
			echo -e "${RED}Invalid choice. Exiting.${NC}"
			exit 1
		fi
		;;
	esac
done
