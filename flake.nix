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

  outputs = inputs@{ nixpkgs, ... }: let
    lib = nixpkgs.lib.foldl (lib: lib.extend) nixpkgs.lib [ (import extra/lib.nix) (lib: prev: inputs.home-manager.lib) ];
    overlay = pkgs: pkgs.extend (import ./overlay);
    eachSystem = fn: lib.genAttrs lib.systems.flakeExposed (sys: overlay nixpkgs.legacyPackages.${sys} |> fn);

    installer = lib.genAttrs lib.systems.flakeExposed (
      system: lib.nixosSystem {
        modules = [ extra/installer.nix ];
        specialArgs = { inherit system; };
      }
    );

    mkApp = pkgs: name: runtimeInputs: pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = lib.readFile apps/${name}.sh;
    };

    mkSystem = machine: lib.nixosSystem {
      specialArgs = { inherit inputs lib machine; };

      modules = [
        ./modules
        base/common
        base/${machine.type}
        machines/${machine.name}
      ]
      ++ lib.optional (lib.pathExists /etc/nixos/hardware.nix) /etc/nixos/hardware.nix;
    };
  in {
    legacyPackages = eachSystem (pkgs: pkgs);

    nixosConfigurations = lib.importCSV ./machines.csv
      |> lib.map (machine: lib.nameValuePair machine.name (mkSystem machine))
      |> lib.listToAttrs
      |> lib.mergeAttrs { inherit installer; };

    packages = eachSystem (
      pkgs: lib.mapAttrs (mkApp pkgs) {
        upgrade = [ pkgs.cargo-edit pkgs.neovim ];
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
          (pkgs.writeShellScriptBin "machines" "cat ${./machines.csv}")
        ];
      }
    );
  };
}
