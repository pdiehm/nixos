{ lib, pkgs, ... }: {
  home-manager.users.pascal = {
    home = {
      file = {
        ".clang-format".source = ../../resources/clang/format.yaml;
        ".clang-tidy".source = ../../resources/clang/tidy.yaml;
        ".config/clangd/config.yaml".source = ../../resources/clang/clangd.yaml;
      };

      packages = [
        pkgs.cargo
        pkgs.clippy
        pkgs.cmake
        pkgs.gcc
        pkgs.gdb
        pkgs.gnumake
        pkgs.gradle
        pkgs.ninja
        pkgs.nodePackages_latest.nodejs
        pkgs.php
        pkgs.python3
        pkgs.rustc
        pkgs.sqlite-interactive
      ];

      sessionVariables = {
        CMAKE_EXPORT_COMPILE_COMMANDS = "ON";
        CMAKE_GENERATOR = "Ninja";
      };
    };

    programs = {
      java.enable = true;

      godot = {
        enable = true;

        externalEditor = {
          enable = true;
          args = "{project} {file} {line}";
          path = lib.readFile ../../resources/scripts/godot-editor.sh |> pkgs.writeShellScriptBin "godot-editor" |> lib.getExe;
        };

        projects = {
          autoscan = true;
          path = "/home/pascal/Repos";
        };

        settings = {
          "network/tls/editor_tls_certificates" = "/etc/ssl/certs/ca-certificates.crt"; # HACK: https://github.com/NixOS/nixpkgs/issues/454608
          "run/window_placement/game_embed_mode" = 1;
        };
      };

      texlive = {
        enable = true;

        extraPackages = tpkgs: {
          inherit (tpkgs) collection-fontsrecommended collection-langgerman collection-latexextra latexmk;
        };
      };
    };
  };

  security.bwrap = {
    cargo = {
      bind = [ "/home/pascal/.cargo" ];
      pwd = true;
    };

    npm = {
      bind = [ "/home/pascal/.npm" ];
      pwd = true;
    };

    npx = {
      bind = [ "/home/pascal/.npm" ];
      pwd = true;
    };
  };
}
