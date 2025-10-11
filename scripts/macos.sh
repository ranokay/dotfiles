#!/usr/bin/env bash

source "./scripts/utils.sh"

# Config from https://mths.be/macos

# Helper functions for checking and setting defaults
check_default() {
    local domain="$1"
    local key="$2"
    local expected_value="$3"
    local value_type="$4"  # bool, int, float, string

    local current_value
    current_value=$(defaults read "$domain" "$key" 2>/dev/null)

    # Handle different value types for comparison
    case "$value_type" in
        "bool")
            # Convert to lowercase for comparison
            current_value=$(echo "$current_value" | tr '[:upper:]' '[:lower:]')
            expected_value=$(echo "$expected_value" | tr '[:upper:]' '[:lower:]')
            ;;
        "int"|"float")
            # Numeric comparison
            ;;
        "string")
            # String comparison (default)
            ;;
    esac

    if [[ "$current_value" == "$expected_value" ]]; then
        return 0  # Value matches
    else
        return 1  # Value doesn't match or doesn't exist
    fi
}

set_default() {
    local domain="$1"
    local key="$2"
    local value="$3"
    local value_type="$4"
    local description="$5"

    if ! check_default "$domain" "$key" "$value" "$value_type"; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_dry_run "Would update $description (${domain} ${key} = ${value})"
        else
            # Store current value for rollback
            local current_value
            current_value=$(defaults read "$domain" "$key" 2>/dev/null || echo "NOT_SET")

            # Create rollback command
            local rollback_cmd
            if [[ "$current_value" == "NOT_SET" ]]; then
                rollback_cmd="defaults delete '$domain' '$key'"
            else
                # Determine current value type for proper restoration
                local current_type="string"
                if [[ "$current_value" =~ ^[0-9]+$ ]]; then
                    current_type="int"
                elif [[ "$current_value" =~ ^[0-9]+\.[0-9]+$ ]]; then
                    current_type="float"
                elif [[ "$current_value" == "1" ]] || [[ "$current_value" == "0" ]]; then
                    current_type="bool"
                    current_value=$([[ $current_value == "1" ]] && echo "true" || echo "false")
                fi
                rollback_cmd="defaults write '$domain' '$key' -$current_type '$current_value'"
            fi

            add_to_rollback "defaults" "$description" "$rollback_cmd"

            # Apply the change
            if ! defaults write "$domain" "$key" -"$value_type" "$value" 2>/dev/null; then
                handle_error 1 "Failed to update $description" "true"
                return 1
            fi

            print_success "Updated $description"
        fi
    fi
}

# Special function for system configuration that requires sudo
check_system_config() {
    local config_type="$1"
    local expected_value="$2"

    local current_value
    case "$config_type" in
        "ComputerName")
            current_value=$(sudo scutil --get ComputerName 2>/dev/null)
            ;;
        "HostName")
            current_value=$(sudo scutil --get HostName 2>/dev/null)
            ;;
        "LocalHostName")
            current_value=$(sudo scutil --get LocalHostName 2>/dev/null)
            ;;
    esac

    if [[ "$current_value" == "$expected_value" ]]; then
        return 0
    else
        return 1
    fi
}

set_system_config() {
    local config_type="$1"
    local value="$2"
    local description="$3"

    if ! check_system_config "$config_type" "$value"; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_dry_run "Would update $description ($config_type = $value)"
        else
            sudo scutil --set "$config_type" "$value"
            print_success "Updated $description"
        fi
    fi
}

# Wrap configurations in functions for better organization
configure_general() {
    print_info "Configuring general UI/UX settings..."

    # Set computer name (as done via System Preferences → Sharing)
    set_system_config "ComputerName" "mbp" "Computer name"
    set_system_config "HostName" "mbp" "Host name"
    set_system_config "LocalHostName" "mbp" "Local host name"

    # Disable the sound effects on boot (always set since nvram doesn't have easy checking)
    sudo nvram SystemAudioVolume=" "

    # Disable the over-the-top focus ring animation
    set_default "NSGlobalDomain" "NSUseAnimatedFocusRing" "false" "bool" "focus ring animation"

    # Disable automatic capitalization as it's annoying when typing code
    set_default "NSGlobalDomain" "NSAutomaticCapitalizationEnabled" "false" "bool" "automatic capitalization"

    # Disable smart dashes as they're annoying when typing code
    set_default "NSGlobalDomain" "NSAutomaticDashSubstitutionEnabled" "false" "bool" "smart dashes"

    # Disable automatic period substitution as it's annoying when typing code
    set_default "NSGlobalDomain" "NSAutomaticPeriodSubstitutionEnabled" "false" "bool" "automatic period substitution"

    # Disable smart quotes as they're annoying when typing code
    set_default "NSGlobalDomain" "NSAutomaticQuoteSubstitutionEnabled" "false" "bool" "smart quotes"

    # Disable auto-correct
    set_default "NSGlobalDomain" "NSAutomaticSpellingCorrectionEnabled" "false" "bool" "auto-correct"

    # Double click to fill
    set_default "NSGlobalDomain" "AppleActionOnDoubleClick" "Fill" "string" "double click action"

    # Click wallpaper to reveal desktop only in state manager
    set_default "com.apple.WindowManager" "EnableStandardClickToShowDesktop" "0" "int" "click wallpaper to show desktop"

    # Remove margins from tiled windows
    set_default "com.apple.WindowManager" "EnableTiledWindowMargins" "false" "bool" "tiled window margins"

    print_success "General UI/UX configuration completed"
}

configure_input() {
    print_info "Configuring input devices..."

    # Trackpad: enable tap to click for this user and for the login screen
    set_default "com.apple.AppleMultitouchTrackpad" "Clicking" "true" "bool" "trackpad tap to click"
    set_default "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" "true" "bool" "bluetooth trackpad tap to click"

    # Disable "natural" scrolling
    set_default "NSGlobalDomain" "com.apple.swipescrolldirection" "false" "bool" "natural scrolling"

    # Disable press-and-hold for keys in favor of key repeat
    set_default "NSGlobalDomain" "ApplePressAndHoldEnabled" "false" "bool" "press-and-hold keys"

    # Set a blazingly fast keyboard repeat rate
    set_default "NSGlobalDomain" "KeyRepeat" "2" "int" "key repeat rate"
    set_default "NSGlobalDomain" "InitialKeyRepeat" "15" "int" "initial key repeat delay"

    # Configure Music Decoy to launch another app when the Play button is pressed
    set_default "com.apple.MusicDecoy" "mediaAppPath" "/Applications/Spotify.app" "string" "Music Decoy media app path"

    print_success "Input device configuration completed"
}

###############################################################################
# Screen                                                                      #
###############################################################################

configure_screen() {
    print_info "Configuring screen settings..."

    # Require password immediately after sleep or screen saver begins
    set_default "com.apple.screensaver" "askForPassword" "1" "int" "password required after screensaver"
    set_default "com.apple.screensaver" "askForPasswordDelay" "0" "int" "password delay after screensaver"

    # Save screenshots to the desktop
    set_default "com.apple.screencapture" "location" "${HOME}/Desktop" "string" "screenshot location"

    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    set_default "com.apple.screencapture" "type" "png" "string" "screenshot format"

    # Disable shadow in screenshots
    set_default "com.apple.screencapture" "disable-shadow" "true" "bool" "screenshot shadow"

    print_success "Screen configuration completed"
}

###############################################################################
# Finder                                                                      #
###############################################################################

configure_finder() {
    print_info "Configuring Finder settings..."

    # Finder: disable window animations and Get Info animations
    set_default "com.apple.finder" "DisableAllAnimations" "true" "bool" "Finder animations"

    # Set User as the default location for new Finder windows
    set_default "com.apple.finder" "NewWindowTarget" "PfHm" "string" "new Finder window location"

    # Show icons for hard drives, servers, and removable media on the desktop
    set_default "com.apple.finder" "ShowExternalHardDrivesOnDesktop" "false" "bool" "external drives on desktop"
    set_default "com.apple.finder" "ShowHardDrivesOnDesktop" "false" "bool" "hard drives on desktop"
    set_default "com.apple.finder" "ShowMountedServersOnDesktop" "false" "bool" "mounted servers on desktop"
    set_default "com.apple.finder" "ShowRemovableMediaOnDesktop" "false" "bool" "removable media on desktop"

    # Finder: show hidden files by default
    set_default "com.apple.finder" "AppleShowAllFiles" "true" "bool" "show hidden files"

    # Finder: show all filename extensions
    set_default "NSGlobalDomain" "AppleShowAllExtensions" "true" "bool" "show all file extensions"

    # Finder: show status bar
    set_default "com.apple.finder" "ShowStatusBar" "true" "bool" "Finder status bar"

    # Finder: show path bar
    set_default "com.apple.finder" "ShowPathbar" "true" "bool" "Finder path bar"

    # Display full POSIX path as Finder window title
    set_default "com.apple.finder" "_FXShowPosixPathInTitle" "true" "bool" "POSIX path in Finder title"

    # Keep folders on top when sorting by name
    set_default "com.apple.finder" "_FXSortFoldersFirst" "true" "bool" "folders first in sort order"

    # When performing a search, search the current folder by default
    set_default "com.apple.finder" "FXDefaultSearchScope" "SCcf" "string" "default search scope"

    # Disable the warning when changing a file extension
    set_default "com.apple.finder" "FXEnableExtensionChangeWarning" "false" "bool" "file extension change warning"

    # Enable spring loading for directories
    set_default "NSGlobalDomain" "com.apple.springing.enabled" "true" "bool" "spring loading for directories"

    # Remove the spring loading delay for directories
    set_default "NSGlobalDomain" "com.apple.springing.delay" "0" "float" "spring loading delay"

    # Avoid creating .DS_Store files on network or USB volumes
    set_default "com.apple.desktopservices" "DSDontWriteNetworkStores" "true" "bool" ".DS_Store on network volumes"
    set_default "com.apple.desktopservices" "DSDontWriteUSBStores" "true" "bool" ".DS_Store on USB volumes"

    # Use list view in all Finder windows by default
    # Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
    set_default "com.apple.finder" "FXPreferredViewStyle" "Nlsv" "string" "Finder view style"

    # Disable the warning before emptying the Trash
    set_default "com.apple.finder" "WarnOnEmptyTrash" "false" "bool" "empty trash warning"

    # Show the ~/Library folder (always run since chflags doesn't have easy checking)
    chflags nohidden ~/Library 2>/dev/null || true

    # Show the /Volumes folder (always run since chflags doesn't have easy checking)
    sudo chflags nohidden /Volumes 2>/dev/null || true

    # Expand the following File Info panes (always run since dict checking is complex)
    # "General", "Open with", and "Sharing & Permissions"
    defaults write com.apple.finder FXInfoPanesExpanded -dict \
        General -bool true \
        OpenWith -bool true \
        Privileges -bool true 2>/dev/null || true

    print_success "Finder configuration completed"
}

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

configure_dock() {
    print_info "Configuring Dock settings..."

    # Automatically hide and show the Dock
    set_default "com.apple.dock" "autohide" "true" "bool" "Dock autohide"
    # Remove the auto-hiding Dock delay
    set_default "com.apple.dock" "autohide-delay" "0" "float" "Dock autohide delay"
    # Remove the animation when hiding/showing the Dock
    set_default "com.apple.dock" "autohide-time-modifier" "0.4" "float" "Dock autohide animation speed"

    # Set the Launchpad columns and rows
    set_default "com.apple.dock" "springboard-columns" "10" "int" "Launchpad columns"
    set_default "com.apple.dock" "springboard-rows" "6" "int" "Launchpad rows"

    # Enable magnification
    set_default "com.apple.dock" "magnification" "true" "bool" "Dock magnification"

    # Set the icon size of Dock items to 32 pixels
    set_default "com.apple.dock" "tilesize" "32" "int" "Dock icon size"

    # Set the icon size of magnified Dock items to 52 pixels
    set_default "com.apple.dock" "largesize" "52" "int" "Dock magnified icon size"

    # Change minimize/maximize window effect
    set_default "com.apple.dock" "mineffect" "scale" "string" "window minimize effect"

    # Minimize windows into their application's icon
    set_default "com.apple.dock" "minimize-to-application" "true" "bool" "minimize to application icon"

    # Enable spring loading for all Dock items
    set_default "com.apple.dock" "enable-spring-load-actions-on-all-items" "true" "bool" "Dock spring loading"

    # Show indicator lights for open applications in the Dock
    set_default "com.apple.dock" "show-process-indicators" "true" "bool" "Dock process indicators"

    # Wipe all (default) app icons from the Dock (always run since array checking is complex)
    # This is only really useful when setting up a new Mac, or if you don't use
    # the Dock to launch apps.
    defaults write com.apple.dock persistent-apps -array

    # Show only open applications in the Dock
    set_default "com.apple.dock" "static-only" "true" "bool" "show only open apps in Dock"

    # Don't animate opening applications from the Dock
    set_default "com.apple.dock" "launchanim" "false" "bool" "Dock launch animations"

    # Speed up Mission Control animations
    set_default "com.apple.dock" "expose-animation-duration" "0.1" "float" "Mission Control animation speed"

    # Don't group windows by application in Mission Control
    # (i.e. use the old Exposé behavior instead)
    set_default "com.apple.dock" "expose-group-by-app" "false" "bool" "Mission Control app grouping"

    # Don't automatically rearrange Spaces based on most recent use
    set_default "com.apple.dock" "mru-spaces" "false" "bool" "automatic Spaces rearrangement"

    # Make Dock icons of hidden applications translucent
    set_default "com.apple.dock" "showhidden" "true" "bool" "translucent hidden app icons"

    # Don't show recent applications in Dock
    set_default "com.apple.dock" "show-recents" "false" "bool" "recent applications in Dock"

    # Hot corners
    # Possible values:
    #  0: no-op
    #  2: Mission Control
    #  3: Show application windows
    #  4: Desktop
    #  5: Start screen saver
    #  6: Disable screen saver
    #  7: Dashboard
    # 10: Put display to sleep
    # 11: Launchpad
    # 12: Notification Center
    # 13: Lock Screen
    # Top left screen corner → Launchpad
    set_default "com.apple.dock" "wvous-tl-corner" "11" "int" "top-left hot corner"
    set_default "com.apple.dock" "wvous-tl-modifier" "0" "int" "top-left hot corner modifier"
    # Top right screen corner → Mission Control
    set_default "com.apple.dock" "wvous-tr-corner" "2" "int" "top-right hot corner"
    set_default "com.apple.dock" "wvous-tr-modifier" "0" "int" "top-right hot corner modifier"
    # Bottom left screen corner → Desktop
    set_default "com.apple.dock" "wvous-bl-corner" "4" "int" "bottom-left hot corner"
    set_default "com.apple.dock" "wvous-bl-modifier" "0" "int" "bottom-left hot corner modifier"
    # Bottom right screen corner → Application Windows
    set_default "com.apple.dock" "wvous-br-corner" "2" "int" "bottom-right hot corner"
    set_default "com.apple.dock" "wvous-br-modifier" "0" "int" "bottom-right hot corner modifier"

    print_success "Dock and hot corners configuration completed"
}

###############################################################################
# Time Machine                                                                #
###############################################################################

configure_time_machine() {
    print_info "Configuring Time Machine settings..."

    # Prevent Time Machine from prompting to use new hard drives as backup volume
    set_default "com.apple.TimeMachine" "DoNotOfferNewDisksForBackup" "true" "bool" "Time Machine new disk prompts"

    print_success "Time Machine configuration completed"
}

###############################################################################
# Activity Monitor                                                            #
###############################################################################

configure_activity_monitor() {
    print_info "Configuring Activity Monitor settings..."

    # Show the main window when launching Activity Monitor
    set_default "com.apple.ActivityMonitor" "OpenMainWindow" "true" "bool" "Activity Monitor main window"

    # Show all processes in Activity Monitor
    set_default "com.apple.ActivityMonitor" "ShowCategory" "0" "int" "Activity Monitor process view"

    # Sort Activity Monitor results by CPU usage
    set_default "com.apple.ActivityMonitor" "SortColumn" "CPUUsage" "string" "Activity Monitor sort column"
    set_default "com.apple.ActivityMonitor" "SortDirection" "0" "int" "Activity Monitor sort direction"

    print_success "Activity Monitor configuration completed"
}

###############################################################################
# Dashboard, TextEdit, and Disk Utility                   #
###############################################################################

configure_textedit() {
    print_info "Configuring TextEdit settings..."

    # Use plain text mode for new TextEdit documents
    set_default "com.apple.TextEdit" "RichText" "0" "int" "TextEdit rich text mode"
    # Open and save files as UTF-8 in TextEdit
    set_default "com.apple.TextEdit" "PlainTextEncoding" "4" "int" "TextEdit plain text encoding"
    set_default "com.apple.TextEdit" "PlainTextEncodingForWrite" "4" "int" "TextEdit write encoding"

    print_success "TextEdit configuration completed"
}

configure_quicktime() {
    print_info "Configuring QuickTime Player settings..."

    # Auto-play videos when opened with QuickTime Player
    set_default "com.apple.QuickTimePlayerX" "MGPlayMovieOnOpen" "true" "bool" "QuickTime auto-play"

    print_success "QuickTime configuration completed"
}

###############################################################################
# Photos                                                                      #
###############################################################################

configure_photos() {
    print_info "Configuring Photos settings..."

    # Prevent Photos from opening automatically when devices are plugged in
    # Note: -currentHost requires special handling
    local current_value
    current_value=$(defaults -currentHost read com.apple.ImageCapture disableHotPlug 2>/dev/null)
    if [[ "$current_value" != "1" ]]; then
        defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
        print_success "Updated Photos auto-launch prevention"
    fi

    print_success "Photos configuration completed"
}

# Main configuration function
apply_macos_configuration() {
    # Close System Preferences
    osascript -e 'tell application "System Preferences" to quit'

    # Ask for administrator password
    sudo -v

    # Keep-alive sudo until script is finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    # Apply configurations
    configure_general
    configure_input
    configure_screen
    configure_finder
    configure_dock
    configure_time_machine
    configure_activity_monitor
    configure_textedit
    configure_quicktime
    configure_photos

    # Kill affected applications only if we're not about to restart
    if ! ask_confirmation "Would you like to restart your computer now?"; then
        print_info "Restarting affected applications..."

        local affected_apps=(
            "Activity Monitor"
            "Address Book"
            "Calendar"
            "Contacts"
            "cfprefsd"
            "Dock"
            "Finder"
            "Mail"
            "Messages"
            "Photos"
            "Safari"
            "SystemUIServer"
            "Terminal"
            "TextEdit"
        )

        for app in "${affected_apps[@]}"; do
            killall "${app}" &>/dev/null || true
        done

        print_success "Applications restarted"
        print_info "Note: Some changes may not take effect until you log out/restart"
    else
        print_info "Restarting computer..."
        sudo shutdown -r now
    fi
}

# Run configuration if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    apply_macos_configuration
fi