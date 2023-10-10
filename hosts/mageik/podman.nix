{ config, lib, pkgs, modulesPath, ... }:

{
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
  };

  environment.systemPackages = [
    pkgs.podman-tui
  ];

}
