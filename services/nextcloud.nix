{
  config,
  pkgs,
  lib,
  ...
}: {
  sops.secrets.nextcloud_adminpassfile = {
    owner = "nextcloud";
    group = "nextcloud";
  };

  services = {
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud29;
      hostName = "192.168.0.100:8080";

      https = true;
      maxUploadSize = "50G";
      configureRedis = true;
      database.createLocally = true;
      # As recommended by admin panel
      phpOptions."opcache.interned_strings_buffer" = "24";

      extraAppsEnable = true;
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) previewgenerator;
      };

      config = {
        adminuser = "ranokay";
        adminpassFile = config.sops.secrets.nextcloud_adminpassfile.path;
        dbtype = "pgsql";
      };

      settings = {
        defaultPhoneRegion = "US";
        enabledPreviewProviders = [
          "OC\\Preview\\BMP"
          "OC\\Preview\\GIF"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\Krita"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\MP3"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\PNG"
          "OC\\Preview\\TXT"
          "OC\\Preview\\XBitmap"
          # Not included by default
          "OC\\Preview\\HEIC"
          "OC\\Preview\\Movie"
          "OC\\Preview\\MP4"
        ];
      };
    };
  };

  # Need ffmpeg to handle video thumbnails
  environment.systemPackages = with pkgs; [
    ffmpeg
  ];

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/nextcloud"
      "/var/lib/postgresql"
    ];
  };
}
