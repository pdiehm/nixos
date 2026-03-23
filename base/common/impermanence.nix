{ config, inputs, lib, ... }: {
  imports = [ inputs.impermanence.nixosModules.impermanence ];
  boot.initrd.postDeviceCommands = lib.readFile ../../resources/scripts/wipe-root.sh |> lib.mkAfter;

  environment.persistence."/perm" = {
    directories = [ "/etc/nixos" "/var/lib/nixos" "/var/lib/systemd" ];
    files = [ "/etc/machine-id" ];
    users.pascal.directories = [ ".config/nixos" ".local/share/systemd" ];
  };

  system.activationScripts.clean-perm = let
    cfg = config.environment.persistence."/perm";
    usr = cfg.users.pascal;
    dirs = lib.map (dir: [ "/perm${dir.dirPath}" "/perm${dir.dirPath}/*" ]) (cfg.directories ++ usr.directories);
    files = lib.map (file: [ "/perm${file.filePath}" ]) (cfg.files ++ usr.files);
    paths = lib.flatten (dirs ++ files) |> lib.concatMapStringsSep " -o " (loc: "-path ${lib.escapeShellArg loc}");
  in ''
    find /perm -not \( ${paths} \) -not -type d -exec rm "{}" +
    find /perm -depth -not \( ${paths} \) -type d -exec rmdir --ignore-fail-on-non-empty "{}" +
  '';
}
