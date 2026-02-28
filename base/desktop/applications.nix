{ pkgs, ... }: {
  programs.wireshark.enable = true;
  users.users.pascal.extraGroups = [ "wireshark" ];

  home-manager.users.pascal = {
    home = {
      file = {
        ".config/dolphinrc".source = ../../resources/kde/dolphin.toml;
        ".config/gwenviewrc".source = ../../resources/kde/gwenview.toml;
        ".local/share/user-places.xbel".source = ../../resources/kde/user-places.xml;

        ".config/menus/applications.menu" = {
          source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
        };
      };

      packages = [
        pkgs.gimp
        pkgs.inkscape
        pkgs.kdePackages.ark
        pkgs.kdePackages.dolphin
        pkgs.kdePackages.ffmpegthumbs
        pkgs.kdePackages.gwenview
        pkgs.kdePackages.k3b
        pkgs.kdePackages.kdegraphics-thumbnailers
        pkgs.networkmanagerapplet
        pkgs.pdfpc
        pkgs.pwvucontrol
        pkgs.tenacity
        pkgs.wireshark
      ];
    };

    programs.mpv = {
      enable = true;
      scripts = [ pkgs.mpvScripts.mpris ];
    };
  };
}
