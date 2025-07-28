{
  pkgs,
  hostname,
  ...
}: {
  # Example server configuration
  # This file shows how easy it is to add a new NixOS server

  # Import hardware configuration (you would generate this with nixos-generate-config)
  imports = [
    # ./hardware-configuration.nix  # Uncomment when setting up real hardware
  ];

  # Server-specific settings
  networking = {
    hostName = hostname;
    # networkmanager.enable = false; # Often disabled on servers
    # Use systemd-networkd for servers instead
    useNetworkd = true;
  };

  # Server-specific services
  services = {
    # Enable SSH with stricter security
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        Port = 22;
      };
      # Add your public keys here
      authorizedKeysFiles = [
        "/etc/ssh/authorized_keys.d/%u"
      ];
    };

    # Enable fail2ban for security
    fail2ban = {
      enable = true;
      maxretry = 3;
      bantime = "1h";
    };

    # Example: Enable nginx
    nginx = {
      enable = false; # Set to true if needed
      # Add nginx configuration here
    };

    # Example: Enable docker
    docker = {
      enable = false; # Set to true if needed
      enableOnBoot = true;
    };
  };

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22]; # SSH
    # allowedTCPPorts = [ 22 80 443 ]; # Add HTTP/HTTPS if running web server
  };

  # Server-specific environment variables
  environment.variables = {
    # Add server-specific variables here
  };

  # Disable GUI components (already handled by base profile, but shown for clarity)
  services.xserver.enable = false;

  # Server-specific system packages
  environment.systemPackages = with pkgs; [
    # Add server-specific packages here
    tmux
    screen
    lsof
    netcat
    tcpdump
  ];
}
