{ inputs, machine, ... }: {
  hardware.enableRedistributableFirmware = true;
  networking.hostName = machine.name;
  services.fwupd.enable = true;

  environment.variables = {
    NIXOS_MACHINE_NAME = machine.name;
    NIXOS_MACHINE_TYPE = machine.type;
  };

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    overlays = import ../../overlay;
  };

  system = {
    configurationRevision = inputs.self.rev or "<dirty>";
    stateVersion = "24.11";
  };
}
