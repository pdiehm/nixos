{ config, lib, ... }: {
  sops.secrets = {
    "bowser/wireguard/key".owner = "systemd-network";
    "bowser/wireguard/network/main".owner = "systemd-network";
    "bowser/wireguard/peer/goomba".owner = "systemd-network";
  };

  systemd.network = {
    netdevs.wg-main = {
      wireguardConfig.PrivateKeyFile = config.sops.secrets."bowser/wireguard/key".path;

      netdevConfig = {
        Kind = "wireguard";
        Name = "wg-main";
      };

      wireguardPeers = lib.singleton {
        AllowedIPs = [ "fd42:5041:5343:414c::/112" ];
        Endpoint = "goomba:51820";
        PersistentKeepalive = 25;
        PresharedKeyFile = config.sops.secrets."bowser/wireguard/network/main".path;
        PublicKeyFile = config.sops.secrets."bowser/wireguard/peer/goomba".path;
      };
    };

    networks = {
      wg-main = {
        address = [ "fd42:5041:5343:414c::2/112" ];
        name = "wg-main";
      };

      wired = {
        address = [ "192.168.1.88/16" ];
        gateway = [ "192.168.1.1" ];
        name = "eth0";
      };
    };
  };
}
