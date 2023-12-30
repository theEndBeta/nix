{ config, lib, inputs, ... }:

{
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
  };

 # environment.systemPackages = [
 #   inputs.nixpkgs-unstable.podman-tui
 # ];
}
