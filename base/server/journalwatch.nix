{ lib, pkgs, ... }: {
  systemd.services.journalwatch = {
    after = [ "network-online.target" ];
    description = "Watch journalctl and report security-relevant events to ntfy";
    path = [ pkgs.scripts.ntfy ];
    preStart = "until ${lib.getExe pkgs.netcat} -z ntfy.pdiehm.dev 80; do sleep 1; done";
    requires = [ "network-online.target" ];
    restartIfChanged = false;
    script = lib.readFile ../../resources/scripts/journalwatch.sh;
    serviceConfig.TimeoutStartSec = "infinity";
    wantedBy = [ "multi-user.target" ];
  };
}
