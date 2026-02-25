{ lib, pkgs, ... }: {
  security.rtkit.enable = true;
  services.logind.settings.Login.HandlePowerKey = "suspend";

  boot = {
    kernel.sysctl."kernel.sysrq" = 1;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  home-manager.users.pascal.programs.git.signing = {
    key = "E85EB0566C779A2F";
    signByDefault = true;
  };

  systemd.services.docker.preStop = ''
    ${lib.getExe pkgs.docker} container ls --all --quiet | xargs --no-run-if-empty ${lib.getExe pkgs.docker} container rm --force
  '';
}
