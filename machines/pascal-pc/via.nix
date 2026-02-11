{ pkgs, ... }: {
  hardware.keyboard.qmk.enable = true;
  home-manager.users.pascal.home.packages = [ pkgs.via ];
  services.udev.packages = [ pkgs.via ];
}
