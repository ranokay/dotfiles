_: {
  system.defaults = {
    # Customize dock
    dock = {
      autohide = true;
      show-recents = false; # disable recent apps

      # Customize Hot Corners (mouse triggers when moved to screen corners)
      wvous-tl-corner = 2; # top-left - Mission Control
      wvous-tr-corner = 13; # top-right - Lock Screen
      wvous-bl-corner = 3; # bottom-left - Application Windows
      wvous-br-corner = 4; # bottom-right - Desktop
    };

    # Customize finder
    finder = {
      _FXShowPosixPathInTitle = true; # show full path in finder title
      AppleShowAllExtensions = true; # show all file extensions
      FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
      QuitMenuItem = true; # enable quit menu item
      ShowPathbar = true; # show path bar
      ShowStatusBar = true; # show status bar
    };

    # Customize trackpad
    trackpad = {
      # tap - light touch on trackpad, click - press trackpad
      Clicking = true; # enable tap to click
      TrackpadRightClick = true; # enable two finger right click
      TrackpadThreeFingerDrag = true; # enable three finger drag
    };

    # Global system preferences
    NSGlobalDomain = {
      "com.apple.swipescrolldirection" = true; # enable natural scrolling (default to true)
      "com.apple.sound.beep.feedback" = 0; # disable beep sound when pressing volume up/down key
      AppleInterfaceStyle = "Dark"; # dark mode
      AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control
      ApplePressAndHoldEnabled = true; # enable press and hold

      # Keyboard repeat settings - useful for vim users
      InitialKeyRepeat = 15; # how long before key starts repeating (225 ms)
      KeyRepeat = 3; # how fast it repeats once started (30 ms)

      # Disable auto-corrections
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;

      # Expand save panels by default
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
    };

    # Additional system preferences
    CustomUserPreferences = {
      ".GlobalPreferences" = {
        # Automatically switch to a new space when switching to the application
        AppleSpacesSwitchOnActivate = true;
      };
      NSGlobalDomain = {
        # Add a context menu item for showing the Web Inspector in web views
        WebKitDeveloperExtras = true;
      };
      "com.apple.finder" = {
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;
        _FXSortFoldersFirst = true;
        # When performing a search, search the current folder by default
        FXDefaultSearchScope = "SCcf";
      };
      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network or USB volumes
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.spaces" = {
        "spans-displays" = 0; # Display have separate spaces
      };
      "com.apple.WindowManager" = {
        EnableStandardClickToShowDesktop = 0; # Click wallpaper to reveal desktop
        StandardHideDesktopIcons = 0; # Show items on desktop
        HideDesktop = 0; # Do not hide items on desktop & stage manager
        StageManagerHideWidgets = 0;
        StandardHideWidgets = 0;
      };
      "com.apple.screensaver" = {
        # Require password immediately after sleep or screen saver begins
        askForPassword = 1;
        askForPasswordDelay = 0;
      };
      "com.apple.screencapture" = {
        location = "~/Desktop";
        type = "png";
      };
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };
      # Prevent Photos from opening automatically when devices are plugged in
      "com.apple.ImageCapture".disableHotPlug = true;
    };

    # Login window settings
    loginwindow = {
      GuestEnabled = false; # disable guest user
      LoginwindowText = "contact@ranokay.com";
    };

    # Keyboard settings
    keyboard = {
      enableKeyMapping = true; # enable key mapping

      # Remap caps lock (choose one)
      remapCapsLockToControl = false; # useful for emacs users
      remapCapsLockToEscape = true; # useful for vim users

      # Swap command and alt (disabled by default as it can cause issues)
      swapLeftCommandAndLeftAlt = false;
    };
  };
}
