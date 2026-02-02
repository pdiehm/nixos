{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };

    impermanence = {
      url = "github:nix-community/impermanence";

      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };

    lanzaboote = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/lanzaboote";
    };

    nixvim = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nixvim";
    };

    sops-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/sops-nix";
    };

    stylix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/stylix";
    };
  };

  outputs = inputs: let
    lib = inputs.nixpkgs.lib.extend (import extra/lib.nix) |> (lib: lib.extend (lib: prev: inputs.home-manager.lib));
    pkgs = lib.foldl (pkgs: pkgs.extend) inputs.nixpkgs.legacyPackages.x86_64-linux (import ./overlay);

    mkScript = name: runtimeInputs: pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = lib.readFile apps/${name}.sh;
    };

    mkSystem = name: cfg: lib.nixosSystem {
      modules = [
        ./modules
        base/common
        base/${cfg.type}
        machines/${name}
      ]
      ++ lib.optional (lib.pathExists /etc/nixos/hardware.nix) /etc/nixos/hardware.nix;

      specialArgs = {
        inherit inputs lib;
        machine = cfg // { inherit name; };
      };
    };
  in rec {
    legacyPackages.x86_64-linux = pkgs;

    nixosConfigurations = lib.importJSON ./machines.json
      |> lib.mapAttrs mkSystem
      |> lib.mergeAttrs { installer = lib.nixosSystem { modules = [ extra/installer.nix ]; }; };

    packages.x86_64-linux = lib.mapAttrs mkScript {
      nixvim = [ nixosConfigurations.pascal-pc.config.home-manager.users.pascal.programs.nixvim.build.package ];
      upgrade = [ ];
      verify = [ pkgs.colorized-logs pkgs.nil pkgs.shellcheck ];

      install = [
        pkgs.btrfs-progs
        pkgs.cryptsetup
        pkgs.curl
        pkgs.dosfstools
        pkgs.git
        pkgs.gnupg
        pkgs.iproute2
        pkgs.jq
        pkgs.parted
        pkgs.pinentry-tty
        pkgs.sbctl
        (pkgs.writeShellScriptBin "machines" "cat ${./machines.json}")
      ];
    };
  };
}
