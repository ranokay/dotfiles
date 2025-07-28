{
  pkgs,
  username,
  ...
}: {
  # Define user account
  users.users."${username}" =
    {
      description = username;
      shell = pkgs.zsh;
    }
    // (
      # Darwin-specific user settings
      if pkgs.stdenv.isDarwin
      then {
        home = "/Users/${username}";
      }
      # NixOS-specific user settings
      else {
        isNormalUser = true;
        home = "/home/${username}";
        extraGroups = ["wheel" "networkmanager" "docker"];
      }
    );
}
