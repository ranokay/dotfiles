#!/usr/bin/env bash

source "./scripts/utils.sh"

# Config from https://mths.be/macos

# Wrap configurations in functions for better organization
configure_general() {
    print_info "Configuring general UI/UX settings..."
    
    # Set computer name (as done via System Preferences → Sharing)
    sudo scutil --set ComputerName "mbp"
    sudo scutil --set HostName "mbp"
    sudo scutil --set LocalHostName "mbp"

    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" "

    # Disable the over-the-top focus ring animation
    defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

    # Disable automatic capitalization as it's annoying when typing code
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

    # Disable smart dashes as they're annoying when typing code
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    # Disable automatic period substitution as it's annoying when typing code
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

    # Disable smart quotes as they're annoying when typing code
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    # Double click to fill
    defaults write NSGlobalDomain AppleActionOnDoubleClick -string "Fill"

    # Click wallpaper to reveal desktop only in state manager
    defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -int 0

    # Remove margins from tiled windows
    defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
}

configure_input() {
    print_info "Configuring input devices..."
    
    # Trackpad: enable tap to click for this user and for the login screen
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

    # Disable "natural" scrolling
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    # Set a blazingly fast keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    # Configure Music Decoy to launch another app when the Play button is pressed
    defaults write com.apple.MusicDecoy mediaAppPath /Applications/Spotify.app
}

###############################################################################
# Screen                                                                      #
###############################################################################

configure_screen() {
    print_info "Configuring screen settings..."
    
    # Require password immediately after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0

    # Save screenshots to the desktop
    defaults write com.apple.screencapture location -string "${HOME}/Desktop"

    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "png"

    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true
}

###############################################################################
# Finder                                                                      #
###############################################################################

configure_finder() {
    print_info "Configuring Finder settings..."
    
    # Finder: disable window animations and Get Info animations
    defaults write com.apple.finder DisableAllAnimations -bool true

    # Set User as the default location for new Finder windows
    defaults write com.apple.finder NewWindowTarget -string "PfHm"

    # Show icons for hard drives, servers, and removable media on the desktop
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

    # Finder: show hidden files by default
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Finder: show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Finder: show status bar
    defaults write com.apple.finder ShowStatusBar -bool true

    # Finder: show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Display full POSIX path as Finder window title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Enable spring loading for directories
    defaults write NSGlobalDomain com.apple.springing.enabled -bool true

    # Remove the spring loading delay for directories
    defaults write NSGlobalDomain com.apple.springing.delay -float 0

    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Use list view in all Finder windows by default
    # Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    # Disable the warning before emptying the Trash
    defaults write com.apple.finder WarnOnEmptyTrash -bool false

    # Show the ~/Library folder
    chflags nohidden ~/Library

    # Show the /Volumes folder
    sudo chflags nohidden /Volumes

    # Expand the following File Info panes:
    # "General", "Open with", and "Sharing & Permissions"
    defaults write com.apple.finder FXInfoPanesExpanded -dict \
        General -bool true \
        OpenWith -bool true \
        Privileges -bool true
}

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

configure_dock() {
    print_info "Configuring Dock settings..."
    
    # Automatically hide and show the Dock
    defaults write com.apple.dock autohide -bool true
    # Remove the auto-hiding Dock delay
    defaults write com.apple.dock autohide-delay -float 0
    # Remove the animation when hiding/showing the Dock
    defaults write com.apple.dock autohide-time-modifier -float 0.4

    # Set the Launchpad columns and rows
    defaults write com.apple.dock springboard-columns -int 10
    defaults write com.apple.dock springboard-rows -int 6

    # Enable magnification
    defaults write com.apple.dock magnification -bool true

    # Set the icon size of Dock items to 32 pixels
    defaults write com.apple.dock tilesize -int 32

    # Set the icon size of magnified Dock items to 52 pixels
    defaults write com.apple.dock largesize -int 52

    # Change minimize/maximize window effect
    defaults write com.apple.dock mineffect -string "scale"

    # Minimize windows into their application's icon
    defaults write com.apple.dock minimize-to-application -bool true

    # Enable spring loading for all Dock items
    defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

    # Show indicator lights for open applications in the Dock
    defaults write com.apple.dock show-process-indicators -bool true

    # Wipe all (default) app icons from the Dock
    # This is only really useful when setting up a new Mac, or if you don't use
    # the Dock to launch apps.
    defaults write com.apple.dock persistent-apps -array

    # Show only open applications in the Dock
    defaults write com.apple.dock static-only -bool true

    # Don't animate opening applications from the Dock
    defaults write com.apple.dock launchanim -bool false

    # Speed up Mission Control animations
    defaults write com.apple.dock expose-animation-duration -float 0.1

    # Don't group windows by application in Mission Control
    # (i.e. use the old Exposé behavior instead)
    defaults write com.apple.dock expose-group-by-app -bool false

    # Don't automatically rearrange Spaces based on most recent use
    defaults write com.apple.dock mru-spaces -bool false

    # Make Dock icons of hidden applications translucent
    defaults write com.apple.dock showhidden -bool true

    # Don't show recent applications in Dock
    defaults write com.apple.dock show-recents -bool false

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
    defaults write com.apple.dock wvous-tl-corner -int 11
    defaults write com.apple.dock wvous-tl-modifier -int 0
    # Top right screen corner → Mission Control
    defaults write com.apple.dock wvous-tr-corner -int 2
    defaults write com.apple.dock wvous-tr-modifier -int 0
    # Bottom left screen corner → Desktop
    defaults write com.apple.dock wvous-bl-corner -int 4
    defaults write com.apple.dock wvous-bl-modifier -int 0
    # Bottom right screen corner → Application Windows
    defaults write com.apple.dock wvous-br-corner -int 2
    defaults write com.apple.dock wvous-br-modifier -int 0
}

###############################################################################
# Time Machine                                                                #
###############################################################################

configure_time_machine() {
    print_info "Configuring Time Machine settings..."
    
    # Prevent Time Machine from prompting to use new hard drives as backup volume
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
}

###############################################################################
# Activity Monitor                                                            #
###############################################################################

configure_activity_monitor() {
    print_info "Configuring Activity Monitor settings..."
    
    # Show the main window when launching Activity Monitor
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

    # Show all processes in Activity Monitor
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    # Sort Activity Monitor results by CPU usage
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0
}

###############################################################################
# Dashboard, TextEdit, and Disk Utility                   #
###############################################################################

configure_textedit() {
    print_info "Configuring TextEdit settings..."
    
    # Use plain text mode for new TextEdit documents
    defaults write com.apple.TextEdit RichText -int 0
    # Open and save files as UTF-8 in TextEdit
    defaults write com.apple.TextEdit PlainTextEncoding -int 4
    defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4
}

configure_quicktime() {
    print_info "Configuring QuickTime Player settings..."
    
    # Auto-play videos when opened with QuickTime Player
    defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true
}

###############################################################################
# Photos                                                                      #
###############################################################################

configure_photos() {
    print_info "Configuring Photos settings..."
    
    # Prevent Photos from opening automatically when devices are plugged in
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
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