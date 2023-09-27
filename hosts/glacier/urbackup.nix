{ config, lib, pkgs, modulesPath, ... }:

let 
  urbackup-server = (pkgs.callPackage ../../pkgs/urbackup-server { });
in {
  environment.systemPackages = with pkgs; [
    urbackup-server
  ];

  users = {
    groups = {
      urbackup = {};
    };
    users.urbackup = {
      isSystemUser = true;
      group = "urbackup";
      createHome = false;
    };

    security.wrappers = {
      urbackup_snapshot_helper = {
        setuid = true;
        owner = "urbackup";
        group = "urbackup";
        source = "${urbackup-server}/urbackup_snapshot_helper";
      };
      urbackup_mount_helper = {
        setuid = true;
        owner = "urbackup";
        group = "urbackup";
        source = "${urbackup-server}/urbackup_snapshot_helper";
      };
    };
  };
}
