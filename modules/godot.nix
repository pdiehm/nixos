{ config, lib, pkgs, ... }: let
  cfg = config.programs.godot;
in {
  options.programs.godot = {
    enable = lib.mkEnableOption "Godot";
    package = lib.mkPackageOption pkgs "godot" { };
    online = lib.mkEnableOption "online mode" // { default = true; };

    android = {
      enable = lib.mkEnableOption "android export settings";
      androidPackage = lib.mkPackageOption pkgs "androidsdk" { };
      javaPackage = lib.mkPackageOption pkgs "jdk" { };
    };

    exportTemplates = {
      enable = lib.mkEnableOption "export templates" // { default = true; };
      package = lib.mkPackageOption pkgs "godot-export-templates-bin" { };
    };

    externalEditor = {
      enable = lib.mkEnableOption "external editor";

      args = lib.mkOption {
        default = "{file}";
        type = lib.types.str;
      };

      path = lib.mkOption {
        default = "$VISUAL";
        type = lib.types.str;
      };
    };

    projects = {
      autoscan = lib.mkEnableOption "autoscan project path";

      path = lib.mkOption {
        default = config.home.homeDirectory;
        type = lib.types.str;
      };
    };

    settings = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (lib.types.oneOf [ lib.types.bool lib.types.number lib.types.str ]);
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.dataFile."godot/export_templates".source = "${cfg.exportTemplates.package}/share/godot/export_templates";

    home = {
      packages = [ cfg.package ];

      activation.setupGodot = let
        settings = lib.mapAttrsToList (key: value: ''settings.set("${key}", ${builtins.toJSON value})'') cfg.settings;

        init = pkgs.writeText "init.gd" ''
          extends SceneTree

          func _initialize():
            var settings = EditorInterface.get_editor_settings()
            ${lib.concatStringsSep "\n  " settings}
        '';
      in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${lib.getExe cfg.package} --headless --quit --script ${init}
      '';
    };

    programs.godot.settings = {
      "export/android/android_sdk_path" = lib.mkIf cfg.android.enable "${cfg.android.androidPackage}/libexec/android-sdk";
      "export/android/java_sdk_path" = lib.mkIf cfg.android.enable cfg.android.javaPackage.home;
      "filesystem/directories/autoscan_project_path" = lib.mkIf cfg.projects.autoscan cfg.projects.path;
      "filesystem/directories/default_project_path" = cfg.projects.path;
      "network/connection/check_for_updates" = 0;
      "network/connection/network_mode" = if cfg.online then 1 else 0;
      "text_editor/external/exec_flags" = cfg.externalEditor.args;
      "text_editor/external/exec_path" = cfg.externalEditor.path;
      "text_editor/external/use_external_editor" = cfg.externalEditor.enable;
    };
  };
}
