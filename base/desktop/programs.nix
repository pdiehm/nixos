{ config, lib, pkgs, ... }: {
  services.speechd.enable = false;
  sops.secrets.home-assistant-token.owner = "pascal";
  users.users.pascal.extraGroups = [ "ydotool" ];

  home-manager.users.pascal = {
    home.packages = [
      pkgs.brightnessctl
      pkgs.clinfo
      pkgs.cloc
      pkgs.clock-rs
      pkgs.cryptsetup
      pkgs.dmidecode
      pkgs.exfat
      pkgs.ffmpeg-full
      pkgs.hardinfo2
      pkgs.hexedit
      pkgs.imagemagickBig
      pkgs.nmap
      pkgs.poppler-utils
      pkgs.rsync
      pkgs.scripts.ha
      pkgs.scripts.mk
      pkgs.scripts.mnt
      pkgs.scripts.repo
      pkgs.scripts.wp-toggle
      pkgs.steam-run-free
      pkgs.vhs
      pkgs.wf-recorder
      pkgs.wl-clipboard
      pkgs.wl-mirror
      pkgs.yt-dlp
    ];

    programs = {
      rofi.enable = true;

      kitty = {
        enable = true;
        settings.scrollback_pager_history_size = 1024;
      };
    };

    services = {
      playerctld.enable = true;

      mako = {
        enable = true;
        settings.default-timeout = 5000;
      };
    };
  };

  programs = {
    ydotool.enable = true;

    scripts = {
      mk.text = lib.readFile ../../resources/scripts/mk.sh |> lib.templateString { DIR = "${../../resources/mk}"; };
      repo.text = lib.readFile ../../resources/scripts/repo.sh;
      wp-toggle.text = lib.readFile ../../resources/scripts/wp-toggle.sh;

      ha.text = lib.readFile ../../resources/scripts/ha.sh
        |> lib.templateString { TOKEN = config.sops.secrets.home-assistant-token.path; };

      mnt = {
        deps = [ pkgs.android-file-transfer pkgs.curlftpfs pkgs.sshfs ];
        text = lib.readFile ../../resources/scripts/mnt.sh;
      };
    };
  };
}
