{ config, lib, pkgs, ... }: let
  defaultFlags = [
    "--new-session"
    "--die-with-parent"
    "--unshare-all"
    "--share-net"
    "--dev /dev"
    "--proc /proc"
    "--tmpfs /tmp"
    "--ro-bind /bin /bin"
    "--ro-bind /etc /etc"
    "--ro-bind /usr /usr"
    "--ro-bind /nix/store /nix/store"
    "--ro-bind /run/current-system /run/current-system"
    "--ro-bind-try /run/systemd/resolve/stub-resolv.conf /run/systemd/resolve/stub-resolv.conf"
  ];

  mkBwrap = name: cfg: {
    group = "root";
    owner = "root";

    source = pkgs.writeShellScript "${name}-bwrapped" ''
      export PATH="$(sed -E "s|${lib.escapeRegex config.security.wrapperDir}|/dev/null|" <<<"$PATH")"
      ${lib.optionalString (cfg.bind != [ ]) "mkdir -p ${lib.escapeShellArgs cfg.bind}"}

      exec -a "$0" ${lib.getExe pkgs.bubblewrap} \
        ${toString (defaultFlags ++ cfg.flags)} \
        ${lib.map (b: lib.escapeShellArgs [ "--bind" b b ]) cfg.bind |> toString} \
        ${lib.optionalString cfg.pwd ''--bind "$PWD" "$PWD"''} \
        ${cfg.cmd} "$@"
    '';
  };
in {
  options.security.bwrap = lib.mkOption {
    default = { };

    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }: {
          options = {
            bind = lib.mkOption {
              default = [ ];
              type = lib.types.listOf lib.types.str;
            };

            cmd = lib.mkOption {
              default = name;
              type = lib.types.str;
            };

            flags = lib.mkOption {
              default = [ ];
              type = lib.types.listOf lib.types.str;
            };

            pwd = lib.mkOption {
              default = false;
              type = lib.types.bool;
            };
          };
        }
      )
    );
  };

  config.security = {
    bwrap.bwrap-shell.cmd = "bash";
    wrappers = lib.mapAttrs mkBwrap config.security.bwrap;
  };
}
