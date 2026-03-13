{ pkgs, ... }: {
  virtualisation.spiceUSBRedirection.enable = true;

  features = {
    amdgpu.enable = true;
    bluetooth.enable = true;
  };

  home-manager.users.pascal = {
    home.packages = [ pkgs.blender pkgs.freecad pkgs.qemu pkgs.qucs-s pkgs.quickemu ];
    programs.godot.android.enable = true;

    wayland.windowManager.hyprland.settings.bindl = [
      "SUPER ALT, f, exec, ha fan toggle fan_desk"
      "SUPER ALT, l, exec, ha light toggle lamp_desk"
    ];
  };
}
