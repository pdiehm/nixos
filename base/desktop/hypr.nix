{ lib, pkgs, ... }: {
  programs.hyprland.enable = true;

  home-manager.users.pascal = {
    programs = {
      zsh.profileExtra = ''test "$(tty)" = "/dev/tty1" && exec systemd-cat --identifier Hyprland start-hyprland'';

      hyprlock = {
        enable = true;

        settings = {
          general.hide_cursor = true;

          background = {
            blur_passes = 2;
            blur_size = 4;
            path = "screenshot";
          };

          label = {
            font_size = 64;
            halign = "center";
            position = "0, 20%";
            shadow_passes = 2;
            shadow_size = 4;
            text = "$TIME";
            valign = "center";
          };
        };
      };
    };

    services.hypridle = {
      enable = true;

      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          before_sleep_cmd = "loginctl lock-session";
          lock_cmd = "pidof hyprlock || hyprlock";
          unlock_cmd = "pkill -USR1 hyprlock && hyprctl dispatch dpms on";
        };

        listener = {
          on-resume = "hyprctl dispatch dpms on";
          on-timeout = "hyprctl dispatch dpms off";
          timeout = 300;
        };
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;

      settings = {
        bindm = [ "SUPER, mouse:272, movewindow" "SUPER, mouse:273, resizewindow" ];
        decoration.rounding = 10;
        gesture = "3, horizontal, workspace";
        windowrule = [ "match:workspace w[t1], match:float 0, border_size 0, rounding 0" ];
        workspace = "w[t1], gapsout:0";

        animations = {
          animation = [
            "border, 1, 5.39, easeOutQuint"
            "fade, 1, 3.03, quick"
            "fadeIn, 1, 1.73, almostLinear"
            "fadeLayersIn, 1, 1.79, almostLinear"
            "fadeLayersOut, 1, 1.39, almostLinear"
            "fadeOut, 1, 1.46, almostLinear"
            "global, 1, 10, default"
            "layers, 1, 3.81, easeOutQuint"
            "layersIn, 1, 4, easeOutQuint, fade"
            "layersOut, 1, 1.5, linear, fade"
            "windows, 1, 4.79, easeOutQuint"
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
            "windowsOut, 1, 1.49, linear, popin 87%"
            "workspaces, 1, 1.94, almostLinear, fade"
            "workspacesIn, 1, 1.21, almostLinear, fade"
            "workspacesOut, 1, 1.94, almostLinear, fade"
            "zoomFactor, 1, 7, quick"
          ];

          bezier = [
            "almostLinear, 0.5, 0.5, 0.75, 1"
            "easeInOutCubic, 0.65, 0.05, 0.36, 1"
            "easeOutQuint, 0.23, 1, 0.32, 1"
            "linear, 0, 0, 1, 1"
            "quick, 0.15, 0, 0.1, 1"
          ];
        };

        bind = [
          "SUPER, 1, workspace, 1"
          "SUPER, 2, workspace, 2"
          "SUPER, 3, workspace, 3"
          "SUPER, 4, workspace, 4"
          "SUPER, 5, workspace, 5"
          "SUPER, 6, workspace, 6"
          "SUPER, 7, workspace, 7"
          "SUPER, 8, workspace, 8"
          "SUPER, 9, workspace, 9"

          "SUPER SHIFT, 1, movetoworkspace, 1"
          "SUPER SHIFT, 2, movetoworkspace, 2"
          "SUPER SHIFT, 3, movetoworkspace, 3"
          "SUPER SHIFT, 4, movetoworkspace, 4"
          "SUPER SHIFT, 5, movetoworkspace, 5"
          "SUPER SHIFT, 6, movetoworkspace, 6"
          "SUPER SHIFT, 7, movetoworkspace, 7"
          "SUPER SHIFT, 8, movetoworkspace, 8"
          "SUPER SHIFT, 9, movetoworkspace, 9"

          "CTRL SUPER, 1, movetoworkspacesilent, 1"
          "CTRL SUPER, 2, movetoworkspacesilent, 2"
          "CTRL SUPER, 3, movetoworkspacesilent, 3"
          "CTRL SUPER, 4, movetoworkspacesilent, 4"
          "CTRL SUPER, 5, movetoworkspacesilent, 5"
          "CTRL SUPER, 6, movetoworkspacesilent, 6"
          "CTRL SUPER, 7, movetoworkspacesilent, 7"
          "CTRL SUPER, 8, movetoworkspacesilent, 8"
          "CTRL SUPER, 9, movetoworkspacesilent, 9"

          "SUPER, h, movefocus, l"
          "SUPER, j, movefocus, d"
          "SUPER, k, movefocus, u"
          "SUPER, l, movefocus, r"

          "SUPER SHIFT, h, movewindow, l"
          "SUPER SHIFT, j, movewindow, d"
          "SUPER SHIFT, k, movewindow, u"
          "SUPER SHIFT, l, movewindow, r"

          "CTRL SUPER SHIFT, q, forcekillactive"
          "SUPER SHIFT, f, togglefloating"
          "SUPER SHIFT, q, killactive"
          "SUPER, f, fullscreen"

          "SUPER, Return, exec, kitty"
          "SUPER, Space, exec, rofi -drun-show-actions -show drun"
          "SUPER, e, exec, dolphin"

          ", Print, exec, ${lib.getExe pkgs.hyprshot} --output-folder /home/pascal/Temp --mode active --mode output"
          "ALT, Print, exec, ${lib.getExe pkgs.hyprpicker} --autocopy"
          "SUPER SHIFT, Print, exec, ${lib.getExe pkgs.hyprshot} --output-folder /home/pascal/Temp --mode region"
          "SUPER, Print, exec, ${lib.getExe pkgs.hyprshot} --output-folder /home/pascal/Temp --mode active --mode window"

          ", XF86HomePage, exec, firefox"
          ", XF86Mail, exec, thunderbird"
          "SHIFT, XF86HomePage, exec, firefox --private-window"
        ];

        bindl = [
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
          ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
          "SHIFT, XF86AudioMute, exec, wp-toggle"

          "SUPER ALT, f, exec, ha fan toggle fan_desk"
          "SUPER ALT, l, exec, ha light toggle lamp_desk"
        ];

        ecosystem = {
          no_donation_nag = true;
          no_update_news = true;
        };

        general = {
          border_size = 2;
          "col.active_border" = lib.mkForce "rgb(00dbde) rgb(fc00ff) 45deg";
          no_focus_fallback = true;
        };

        input = {
          kb_layout = "de";
          kb_options = "caps:escape";
          numlock_by_default = true;
          repeat_delay = 200;
        };

        misc = {
          enable_anr_dialog = false;
          key_press_enables_dpms = true;
          middle_click_paste = false;
          mouse_move_enables_dpms = true;
          session_lock_xray = true;
        };
      };
    };
  };
}
