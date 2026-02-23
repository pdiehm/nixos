{ lib, modulesPath, pkgs, ... }: {
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
  console.keyMap = "de";
  environment.systemPackages = [ (pkgs.writeShellScriptBin "nixinstall" "nix run github:pdiehm/nixos#install") ];

  nix.settings = {
    experimental-features = [ "flakes" "nix-command" "pipe-operators" ];
    substituters = lib.mkForce [ "http://127.0.0.1:5777" ];
    trusted-public-keys = [ "private:Gj04okCf2KAYVNSQ5vwXCgOLRz+ESUGi/YlvT1rsnpQ=" ];
  };

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    overlays = [ (import ../overlay) ];
  };

  services = {
    getty.helpLine = lib.mkAfter "Run 'nixinstall' to install NixOS.";

    avahi = {
      enable = true;
      hostName = "nixos-installer";

      publish = {
        enable = true;
        addresses = true;
      };
    };

    nginx = {
      enable = true;
      proxyResolveWhileRunning = true;
      resolver.addresses = [ "1.1.1.1" ];

      virtualHosts.nix-cache = {
        extraConfig = "recursive_error_pages on;";

        locations = {
          "/" = {
            proxyPass = "http://192.168.1.88:5779";

            extraConfig = ''
              error_page 502 504 = @fallback;
              proxy_connect_timeout 100ms;
              proxy_intercept_errors on;
            '';
          };

          "@fallback" = {
            proxyPass = "https://cache.nixos.org";

            extraConfig = ''
              proxy_ssl_server_name on;
              proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
              proxy_ssl_verify on;
            '';
          };
        };

        listen = lib.singleton {
          addr = "127.0.0.1";
          port = 5777;
        };
      };
    };
  };

  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVpBDeuHacnZcYsM06F+ktipogjcLNZrL6rjYwZIV51 pascal"
  ];
}
