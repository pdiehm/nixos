{
  boot.initrd.luks.devices.nixos.device = "/dev/disk/by-partlabel/nixos";

  services.getty = {
    autologinOnce = true;
    autologinUser = "pascal";
  };
}
