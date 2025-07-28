{
  email,
  hostname,
  ...
}: {
  # Host-specific configurations for MacBook Pro
  # This file contains settings specific to this machine only

  # System identifier
  networking.hostName = hostname;
  networking.computerName = "MacBook Pro";

  # Host-specific system defaults overrides
  system.defaults = {
    # Dock specific to this machine
    dock = {
      # Add dock-specific apps for this machine
      persistent-apps = [
        "/System/Applications/Finder.app"
        "/Applications/Zen Browser.app"
        "/Applications/Cursor.app"
        "/Applications/Warp.app"
        "/Applications/Raycast.app"
      ];
    };

    # Machine-specific login window text
    loginwindow.LoginwindowText = "MacBook Pro - ${email}";
  };

  # Host-specific homebrew casks (if any)
  homebrew.casks = [
    # Add any machine-specific applications here
  ];

  # Host-specific environment variables
  environment.variables = {
    # Add any machine-specific environment variables
  };
}
