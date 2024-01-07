{ config, lib, inputs, pkgs, ... }:

{
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
  };

  environment.etc."systemd/user-generators/podman-user-generator" = {
    source = "${pkgs.podman}/lib/systemd/user-generators/podman-user-generator";
    target = "systemd/user-generators/podman-user-generator";
  };

 # environment.systemPackages = [
 #   inputs.nixpkgs-unstable.podman-tui
 # ];
}
