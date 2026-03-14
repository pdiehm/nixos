{ inputs, machine, ... }: {
  networking.hostName = machine.name;
  nixpkgs.overlays = [ (import ../../overlay) ];
  services.fwupd.enable = true;

  environment.variables = {
    NIXOS_MACHINE_BOOT = machine.boot;
    NIXOS_MACHINE_NAME = machine.name;
    NIXOS_MACHINE_TYPE = machine.type;
  };

  system = {
    configurationRevision = inputs.self.rev or "<dirty>";
    stateVersion = "24.11";
  };
}
