{ config, lib, pkgs, modulesPath, ... }:

let
  mkSyncoidServiceName = {user, addr}: dataset: "syncoid-${builtins.replaceStrings ["/"] ["-"] dataset}-${addr}";
  mkSyncoidService = {user, addr}: rootPool: dataset: {
    enable = true;
    description = "syncoid for ${dataset.name} from ${rootPool} on ${addr}";
    after = [
      "network.service"
      "zfs.target"
      "zfs-mount.service"
    ];
    wants = [ "default.target" ];

    path = [ pkgs.sanoid ];

    serviceConfig = {
      Type = "simple";
      User = "backup";
    };
    script = ''
      syncoid \
      --no-privilege-elevation \
      --no-sync-snap \
      --recursive \
      ${dataset.syncoidExtraArgs or ""} \
      --sshkey /home/backup/.ssh/id_ed25519 \
      ${user}@${addr}:${rootPool + "/" + dataset.name} \
      ${"dpool/backups/" + dataset.name}
      '';
  };
  mkSyncoidTimer = serviceName: {
    enable = true;
    description = "Timer for ${serviceName}";
    after = [
      "network.service"
      "zfs.target"
      "zfs-mount.service"
    ];
    timerConfig = {
      Unit = serviceName;
      OnCalendar = "*-*-* 2:00:00";
      RandomizedDelaySec = "1h";
    };
  };
  vesuvius = {
    serviceName = mkSyncoidServiceName vesuvius.host.addr;
    host = {
      user = "vesuvius";
      addr = "vesuvius.lan";
    };
    zpoolSrc = "pool0";
    zpoolDest = "dpool/backups";
    datasets = [
      #{ name = "appdata/vaultwarden"; }
      #{ name = "Users";  sanoidOverrides = {processChildrenOnly = true;}; syncoidExtraArgs = "--skip-parent"; }
    ];
  };
in {
  services.sanoid = {
    enable = true;
    interval = "hourly";

    templates.backup = {
      hourly = 10;
      daily = 14;
      monthly = 4;
      yearly = 1;
      autosnap = false;
      autoprune = true;
    };
  };

  #services.sanoid.datasets = let
  #  vesuvius_sanoid_configs = builtins.listToAttrs (
  #    builtins.map
  #      (
  #        {name, sanoidOverrides ? {}, ... }: {
  #          name = "${vesuvius.zpoolDest}/${name}";
  #          value = {recursive = true; useTemplate = ["backup"];} // sanoidOverrides ;
  #        }
  #      )
  #      vesuvius.datasets
  #    );
  #in
  #  vesuvius_sanoid_configs
  #;


  #systemd.services = let
  #  vesuvius_backup_services = builtins.listToAttrs (
  #    builtins.map
  #      (
  #        dset: {
  #          name = mkSyncoidServiceName vesuvius.host dset.name;
  #          value = mkSyncoidService vesuvius.host vesuvius.zpoolSrc dset;
  #        }
  #      )
  #      vesuvius.datasets
  #  );
  #in 
  #  vesuvius_backup_services
  #;

  #systemd.timers = let
  #  vesuvius_backup_timers = builtins.listToAttrs (
  #    builtins.map
  #      (
  #        dset: {
  #          name = mkSyncoidServiceName vesuvius.host dset.name;
  #          value = mkSyncoidTimer (mkSyncoidServiceName vesuvius.host dset.name);
  #        }
  #      )
  #      vesuvius.datasets
  #  );
  #in 
  #  vesuvius_backup_timers
  #;
}

# vim: set expandtab ts=2 sw=2:
