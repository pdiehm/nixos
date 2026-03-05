{ lib, pkgs, ... }: {
  home-manager.users.pascal = {
    home.packages = [ pkgs.yubikey-manager pkgs.yubioath-flutter ];
    programs.gpg.scdaemonSettings.disable-ccid = true;
  };

  security.pam.u2f = {
    enable = true;

    settings = {
      cue = true;
      origin = "pam://pascal";
    };
  };

  services = {
    pcscd.enable = true;

    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ENV{PRODUCT}=="1050/407/543", ENV{ID_SERIAL_SHORT}=="0016869449", RUN+="${pkgs.writeShellScript "yubikey-unlock" ''
        test "$(${lib.getExe pkgs.yubikey-manager} otp calculate 2 50415343414c | sha256sum | cut -d ' ' -f 1)" = "e1cba9fd67f19f28f76b44a2ad5c3f87a7b3bb213d1c39713fe280c1a34769bf" || exit
        ${lib.getExe' pkgs.systemd "loginctl"} unlock-sessions
      ''}"

      ACTION=="remove", SUBSYSTEM=="input", ENV{PRODUCT}=="3/1050/407/110", ENV{ID_SERIAL_SHORT}=="0016869449", RUN+="${pkgs.writeShellScript "yubikey-lock" ''
        for DEVICE in /dev/input/event*; do
          ${lib.getExe pkgs.evtest} --query "$DEVICE" EV_KEY KEY_LEFTCTRL || exit 0
        done

        ${lib.getExe' pkgs.systemd "loginctl"} lock-sessions
      ''}"
    '';
  };

  sops.secrets.u2f_keys = {
    owner = "pascal";
    path = "/home/pascal/.config/Yubico/u2f_keys";
  };
}
