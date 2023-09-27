{ config, lib, pkgs, modulesPath, ... }:

{
  environment.systemPackages = with pkgs; [
    (callPackage ../../pkgs/urbackup-server { })
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
        source = "${pkgs.urbackup}/urbackup_snapshot_helper";
      };
      urbackup_mount_helper = {
        setuid = true;
        owner = "urbackup";
        group = "urbackup";
        source = "${pkgs.urbackup}/urbackup_snapshot_helper";
      };
    };
  };
}
