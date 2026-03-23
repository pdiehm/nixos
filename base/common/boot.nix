{ inputs, lib, machine, pkgs, ... }: {
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub.device = lib.mkDefault "/dev/null" |> lib.mkIf (machine.boot == "BIOS");
    systemd-boot.enable = machine.boot == "EFI";
  };

  fileSystems = {
    "/" = {
      fsType = "btrfs";
      label = "nixos";
      options = [ "compress=zstd" "subvol=root" ];
    };

    "/boot" = {
      fsType = "vfat";
      label = "BOOT";
      options = [ "dmask=0077" "fmask=0077" ];
    };

    "/nix" = {
      fsType = "btrfs";
      label = "nixos";
      options = [ "compress=zstd" "noatime" "subvol=nix" ];
    };

    "/perm" = {
      fsType = "btrfs";
      label = "nixos";
      neededForBoot = true;
      options = [ "compress=zstd" "subvol=perm" ];
    };
  };
}
|> lib.recursiveUpdate (
  lib.optionalAttrs (machine.boot == "SB") {
    imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];
    environment.persistence."/perm".directories = [ "/var/lib/sbctl" ];
    home-manager.users.pascal.home.packages = [ pkgs.sbctl ];

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/perm/var/lib/sbctl";
    };
  }
)
