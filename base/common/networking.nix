{ lib, pkgs, ... }: {
  environment.etc = {
    hosts.mode = "0644";

    dynhosts.text = ''
      bowser        192.168.1.88 fd42:5041:5343:414c::2
      pascal-pc     192.168.1.90 fd42:5041:5343:414c::1001
      pascal-laptop 192.168.1.91 fd42:5041:5343:414c::1002
    '';
  };

  networking = {
    firewall.allowedTCPPorts = [ 1234 ];
    nftables.enable = true;
    useDHCP = false;
    usePredictableInterfaceNames = false;

    extraHosts = ''
      192.168.1.89 homeassistant
      192.168.1.99 pascal-phone
      91.99.52.233 goomba
      2a01:4f8:c0c:988b::1 goomba
    '';

    nameservers = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
      "2606:4700:4700::1111#one.one.one.one"
      "2606:4700:4700::1001#one.one.one.one"
      "8.8.8.8#dns.google"
      "8.8.4.4#dns.google"
      "2001:4860:4860::8888#dns.google"
      "2001:4860:4860::8844#dns.google"
    ];
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;

      publish = {
        enable = true;
        addresses = true;
      };
    };

    resolved = {
      enable = true;

      settings.Resolve = {
        Domains = "~.";
        LLMNR = false;
        MulticastDNS = false;
      };
    };
  };

  systemd.services.dynhostmgr = {
    after = [ "network.target" "NetworkManager-wait-online.service" "systemd-networkd-wait-online.service" ];
    before = [ "network-online.target" ];
    description = "Dynamically update /etc/hosts with reachable addresses";
    postStart = "until grep -q '### DYNAMIC HOSTS START ###' /etc/hosts; do sleep 1; done";
    serviceConfig.ExecStart = lib.getExe pkgs.dynhostmgr;
    wantedBy = [ "multi-user.target" ];
  };
}
