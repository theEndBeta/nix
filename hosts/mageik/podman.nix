{ config, lib, pkgs, pkgs-unstable, modulesPath, ... }:

let
  podmanModule = "virtualisation/podman/default.nix";
in
{
  # swap to podman from unstable
  disabledModules = [ podmanModule ];
  imports = [ "<nixos-unstable/nixos/modules/${podmanModule}>" ];

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
  };

  environment.systemPackages = [
    pkgs-unstable.podman-tui
  ];

}
