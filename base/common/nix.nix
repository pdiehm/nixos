{ pkgs, ... }: {
  home-manager.users.pascal.home.packages = [ pkgs.nix-output-monitor ];

  nix = {
    channel.enable = false;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "flakes" "nix-command" "pipe-operators" ];
      trusted-users = [ "pascal" ];
      use-xdg-base-directories = true;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
  };
}
