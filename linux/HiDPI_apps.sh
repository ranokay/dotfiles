# Apply HiDPI scaling settings for KDE Plasma apps

DOTFILES_PATH="dotfiles/linux/.local/share/applications"
LOCAL_PATH=".local/share/applications"

# Check if the target directory exists, create it if not
if [ ! -d ~/$LOCAL_PATH ]; then
	mkdir -p ~/$LOCAL_PATH
fi

echo "Please choose which settings to apply (separate choices with a space):"
echo "a) All apps"
echo "q) Exit"
echo "1) Brave Browser"
echo "2) VS Code"
echo "3) Spotify"

read -p "Enter your choices (e.g., '1 2' or 'a'): " choices

# Convert the choices string into an array
IFS=' ' read -ra choice_array <<<"$choices"

# 1. Brave Browser
apply_brave_browser() {
	ln -sf ~/$DOTFILES_PATH/brave-browser.desktop ~/$LOCAL_PATH/brave-browser.desktop
	sudo chmod +x ~/$LOCAL_PATH/brave-browser.desktop
	echo "Brave Browser settings applied."
}

# 2. VS Code
apply_vs_code() {
	ln -sf ~/$DOTFILES_PATH/code.desktop ~/$LOCAL_PATH/code.desktop
	sudo chmod +x ~/$LOCAL_PATH/code.desktop
	echo "VS Code settings applied."
}

# 3. Spotify
apply_spotify() {
	ln -sf ~/$DOTFILES_PATH/spotify.desktop ~/$LOCAL_PATH/spotify.desktop
	sudo chmod +x ~/$LOCAL_PATH/spotify.desktop
	echo "Spotify settings applied."
}

# All apps
apply_all_apps() {
	for file in ~/$DOTFILES_PATH/*.desktop; do
		filename=$(basename "$file")
		ln -sf "$file" ~/$LOCAL_PATH/"$filename"
		sudo chmod +x ~/$LOCAL_PATH/"$filename"
	done
	echo "All app settings applied."
}

for choice in "${choice_array[@]}"; do
	case $choice in
	1)
		apply_brave_browser
		;;

	2)
		apply_vs_code
		;;

	3)
		apply_spotify
		;;

	a | A)
		apply_all_apps
		;;

	q | Q)
		echo "Exiting without applying any settings."
		exit 0
		;;

	*)
		echo "Invalid choice. Exiting."
		exit 1
		;;
	esac
done
