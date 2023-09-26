{ config, lib, pkgs, modulesPath, ... }:

{
  environment.systemPackages = with pkgs; [
    (callPackage ../../pkgs/urbackup-server { })
  ];

  users = {
    users.urbackup = {
      isSystemUser = true;
      group = "urbackup";
      createHome = false;
    };
  };
}
