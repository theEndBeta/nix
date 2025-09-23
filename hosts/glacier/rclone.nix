{ config, pkgs, pkgs-unstable, ... }:
{
  environment.systemPackages = [pkgs.rclone];

  environment.etc."rclone.conf".source = ./rclone.conf;


  systemd.user.services.vaultwarden-db-backup = {
    unitConfig.ConditionUser = ["|backup" "|vesu"];
    requires = ["mnt-dpool-backups-vaultwarden.mount"];
    wantedBy = ["default.target"];
    path = [pkgs.openssh pkgs-unstable.tailscale];
    environment = {
      SSH_AUTH_SOCK = "/run/user/%U/ssh-agent";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        ''
        ${pkgs.rclone}/bin/rclone \
          --config /etc/rclone.conf \
          sync \
          --stats-log-level INFO \
          --fix-case \
          --track-renames \
          --delete-excluded \
          --filter '- .snapshots/**' \
          --filter '+ *.backup.sqlite3' \
          --filter '+ config.json' \
          --filter '+ rsa_key*' \
          --filter '+ attachments/**' \
          --filter '- *' \
          -vv \
          azuma:/var/appdata/vaultwarden \
          /mnt/dpool/backups/vaultwarden
        ''
        "${pkgs.bash}/bin/bash -c \"${pkgs.zfs}/bin/zfs snapshot dpool/backups/vaultwarden@$$(date +%%Y%%m%%d)\""
      ];
    };
  };
}
