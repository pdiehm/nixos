{ inputs, pkgs, ... }: {
  imports = [ inputs.stylix.nixosModules.stylix ];

  home-manager.users.pascal.stylix.targets = {
    firefox.profileNames = [ "default" ];
    hyprlock.enable = false;
    nixvim.enable = false;
    waybar.enable = false;
  };

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/colors.yaml";
    image = ../../resources/wallpaper.jpg;
    opacity.terminal = 0.5;
    polarity = "dark";

    cursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 32;
    };

    fonts = {
      monospace = {
        name = "FiraCode Nerd Font Mono";
        package = pkgs.nerd-fonts.fira-code;
      };

      sansSerif = {
        name = "NotoSans Nerd Font";
        package = pkgs.nerd-fonts.noto;
      };

      serif = {
        name = "NotoSerif Nerd Font";
        package = pkgs.nerd-fonts.noto;
      };
    };

    icons = {
      enable = true;
      dark = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };
}
