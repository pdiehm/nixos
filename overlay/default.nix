pkgs: prev: {
  mpv = prev.mpv.override { scripts = [ ]; };
  nixfmt = prev.nixfmt.overrideAttrs (prev: { patches = (prev.patches or [ ]) ++ [ patches/nixfmt.patch ]; });

  dynhostmgr = pkgs.rustPlatform.buildRustPackage {
    name = "dynhostmgr";
    src = ./dynhostmgr;
    cargoLock.lockFile = dynhostmgr/Cargo.lock;
    meta.mainProgram = "dynhostmgr";
  };

  neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (prev: {
    patches = (prev.patches or [ ]) ++ [ patches/nvim.patch ];
  });

  prettier = let
    modules = pkgs.importNpmLock.buildNodeModules {
      inherit (pkgs) nodejs;
      npmRoot = ./prettier;
    };
  in pkgs.writeShellScriptBin "prettier" ''
    exec -a "$0" ${pkgs.lib.getExe pkgs.bubblewrap} \
      --new-session --die-with-parent --unshare-all \
      --ro-bind /nix/store /nix/store --bind "$PWD" "$PWD" \
      ${pkgs.lib.getExe pkgs.nodejs} "${modules}/node_modules/prettier/bin/prettier.cjs" \
      --plugin "${modules}/node_modules/@prettier/plugin-php/standalone.js" \
      --plugin "${modules}/node_modules/@prettier/plugin-xml/src/plugin.js" \
      --plugin "${modules}/node_modules/prettier-plugin-css-order/src/main.mjs" \
      --plugin "${modules}/node_modules/prettier-plugin-organize-imports/index.js" \
      "$@"
  '';

  vimPlugins = prev.vimPlugins // {
    autoclose-nvim = prev.vimPlugins.autoclose-nvim.overrideAttrs (prev: {
      patches = (prev.patches or [ ]) ++ [ patches/nvim-autoclose.patch ];
    });

    conform-nvim = prev.vimPlugins.conform-nvim.overrideAttrs (prev: {
      postPatch = ''
        ${prev.postPatch or ""}
        rm doc/recipes.md
      '';
    });

    oil-nvim = prev.vimPlugins.oil-nvim.overrideAttrs (prev: {
      postPatch = ''
        ${prev.postPatch or ""}
        rm doc/recipes.md
      '';
    });
  };

  waybar-ups = pkgs.rustPlatform.buildRustPackage {
    name = "waybar-ups";
    src = ./waybar-ups;
    cargoLock.lockFile = waybar-ups/Cargo.lock;
    meta.mainProgram = "waybar-ups";
  };
}
