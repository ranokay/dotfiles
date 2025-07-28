{
  pkgs,
  hostname,
  ...
}: {
  imports = [
    ./system-defaults.nix
    ./homebrew.nix
  ];

  # Darwin-specific system settings
  system = {
    stateVersion = 6;

    # activationScripts are executed every time you boot the system or run `darwin-rebuild`.
    activationScripts.postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
  };

  # Set NetBIOS name for SMB
  system.defaults.smb.NetBIOSName = hostname;

  # Add ability to use TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;
  environment.shells = [pkgs.zsh];

  # Essential system packages
  environment.systemPackages = with pkgs; [
    git
    just
  ];

  # Fonts
  fonts.packages = with pkgs; [
    # Icon fonts
    material-design-icons
    font-awesome
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];
}
