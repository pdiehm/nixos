{ config, ... }: {
  home-manager.users.pascal.services.network-manager-applet.enable = true;
  sops.secrets.network = { };
  users.users.pascal.extraGroups = [ "networkmanager" ];

  networking.networkmanager = {
    enable = true;
    ensureProfiles.environmentFiles = [ config.sops.secrets.network.path ];
  };
}
