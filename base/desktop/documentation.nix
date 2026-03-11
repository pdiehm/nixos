{ pkgs, ... }: {
  documentation.dev.enable = true;
  environment.persistence."/perm".users.pascal.directories = [ ".cache/tlrc" ];

  home-manager.users.pascal = {
    home.packages = [ pkgs.man-pages pkgs.man-pages-posix pkgs.tlrc ];

    services.tldr-update = {
      enable = true;
      package = pkgs.tlrc;
    };
  };
}
