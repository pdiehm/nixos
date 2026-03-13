{ lib, pkgs, ... }: {
  systemd.services.nixos-upgrade.serviceConfig.ExecStartPost = "${lib.getExe' pkgs.systemd "systemctl"} reboot";

  system.autoUpgrade = {
    enable = true;
    dates = "Sun 03:00";
    flags = [ "--impure" ];
    flake = "github:pdiehm/nixos";
    operation = "boot";
    upgrade = false;
  };
}
