{
  networking.networkmanager = {
    settings.main.no-auto-default = "eth0";

    ensureProfiles.profiles = {
      wg-main = {
        wireguard.private-key = "$WIREGUARD_KEY_PASCAL_PC";

        connection = {
          autoconnect-priority = 100;
          id = "@main";
          interface-name = "wg-main";
          type = "wireguard";
        };

        ipv6 = {
          addr-gen-mode = "stable-privacy";
          addresses = "fd42:5041:5343:414c::1001/112";
          method = "manual";
        };

        "wireguard-peer.$WIREGUARD_PEER_GOOMBA" = {
          allowed-ips = "fd42:5041:5343:414c::/112";
          endpoint = "goomba:51820";
          preshared-key = "$WIREGUARD_NETWORK_MAIN";
          preshared-key-flags = 0;
        };
      };

      wired = {
        connection = {
          autoconnect-priority = 100;
          id = "wired";
          interface-name = "eth0";
          type = "ethernet";
        };

        ipv4 = {
          addresses = "192.168.1.90/16";
          gateway = "192.168.1.1";
          method = "manual";
        };
      };
    };
  };
}
