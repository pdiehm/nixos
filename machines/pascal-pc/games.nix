{ pkgs, ... }: {
  home-manager.users.pascal.home.packages = [ pkgs.prismlauncher pkgs.retroarch-free pkgs.supertuxkart ];

  environment.persistence."/perm".users.pascal.directories = [
    ".config/retroarch"
    ".config/supertuxkart"
    ".local/share/PrismLauncher"
    ".local/share/supertuxkart"
  ];

  services.backup.targets = {
    "/home/pascal/.config/retroarch".include = [ "config" "playlists" "retroarch.cfg" "roms" "saves" ];
    "/home/pascal/.config/supertuxkart" = { };
    "/home/pascal/.local/share/PrismLauncher".include = [ "accounts.json" "icons" "instances" "prismlauncher.cfg" ];
    "/home/pascal/.local/share/supertuxkart".include = [ "grandprix" ];
  };
}
