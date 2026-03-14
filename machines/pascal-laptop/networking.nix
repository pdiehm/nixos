{
  networking.networkmanager.ensureProfiles.profiles = {
    home-wifi = {
      connection = {
        autoconnect-priority = 50;
        id = "home-wifi";
        type = "wifi";
      };

      ipv4 = {
        addresses = "192.168.1.91/16";
        gateway = "192.168.1.1";
        method = "manual";
      };

      wifi = {
        mode = "infrastructure";
        ssid = "$HOME_WIFI_SSID";
      };

      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "$HOME_WIFI_PSK";
      };
    };

    hotspot = {
      connection = {
        autoconnect-priority = 25;
        id = "hotspot";
        type = "wifi";
      };

      wifi = {
        mode = "infrastructure";
        ssid = "$HOTSPOT_SSID";
      };

      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "$HOTSPOT_PSK";
      };
    };

    wg-main = {
      wireguard.private-key = "$WIREGUARD_KEY_PASCAL_LAPTOP";

      connection = {
        autoconnect-priority = 100;
        id = "@main";
        interface-name = "wg-main";
        type = "wireguard";
      };

      ipv6 = {
        addr-gen-mode = "stable-privacy";
        addresses = "fd42:5041:5343:414c::1002/112";
        method = "manual";
      };

      "wireguard-peer.$WIREGUARD_PEER_GOOMBA" = {
        allowed-ips = "fd42:5041:5343:414c::/112";
        endpoint = "goomba:51820";
        preshared-key = "$WIREGUARD_NETWORK_MAIN";
        preshared-key-flags = 0;
      };
    };
  };
}
