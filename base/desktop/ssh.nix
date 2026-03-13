{ config, lib, pkgs, ... }: {
  home-manager.users.pascal = {
    services.ssh-agent.enable = true;

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks = {
        "github.com".identityFile = config.sops.secrets."ssh/github".path;

        "*" = {
          controlMaster = "auto";
          controlPath = "~/.ssh/.%C";
          controlPersist = "300";
          identitiesOnly = true;
          setEnv.TERM = "xterm-256color";
        };

        bowser = {
          forwardAgent = true;
          identityFile = config.sops.secrets."ssh/bowser".path;
          port = 1970;
        };

        goomba = {
          forwardAgent = true;
          identityFile = config.sops.secrets."ssh/goomba".path;
          port = 1970;
        };

        installer = {
          hostname = "nixos-installer.local";
          identityFile = config.sops.secrets."ssh/installer".path;
          user = "nixos";

          extraOptions = {
            StrictHostKeyChecking = "no";
            UserKnownHostsFile = "/dev/null";
          };
        };

        pascal-laptop = {
          identityFile = config.sops.secrets."ssh/pascal-laptop".path;
          port = 1970;
        };

        pascal-pc = {
          identityFile = config.sops.secrets."ssh/pascal-pc".path;
          port = 1970;
        };
      };
    };

    systemd.user.services.ssh-agent.Service = {
      Environment = "SSH_AUTH_SOCK=%t/ssh-agent";

      ExecStartPost = pkgs.writeShellScript "add-ssh-keys" ''
        ${lib.getExe' pkgs.openssh "ssh-add"} ${config.sops.secrets."ssh/github".path}
      '';
    };
  };

  sops.secrets = {
    "ssh/bowser".owner = "pascal";
    "ssh/github".owner = "pascal";
    "ssh/goomba".owner = "pascal";
    "ssh/installer".owner = "pascal";
    "ssh/pascal-laptop".owner = "pascal";
    "ssh/pascal-pc".owner = "pascal";
  };
}
