{ config, options, pkgs, ... }:
{
  environment.systemPackages = [pkgs.rclone];

  environment.etc."rclone.conf".source = ./rclone.conf;


  systemd.user.services.vaultwarden-db-backup = {
    unitConfig.ConditionUser = "backup|vesu";
    requires = ["mnt-dpool-backups-vaultwarden.mount"];
    wantedBy = ["default.target"];
    path = [pkgs.nix];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "tailscale ssh vesu@ntfy -- systemctl --user start vaultwarden-db-backup"
        "rclone sync \
          --config /etc/rclone.conf \
          --progress \
          --fix-case \
          --track-renames \
          --delete-excluded \
          --filter '+ *.backup.sqlite3' \
          --filter '+ config.json' \
          --filter '+ rsa_key*' \
          --filter '+ attachments/**' \
          --filter '+ backups/**' \
          --filter '- *' \
          ntfy:/data/appdata/vaultwarden \
          /mnt/dpool/backups/vaultwarden"
        "zfs snapshot dpool/backups/vaultwarden@$(date +%Y%m%d)"
      ];
    };
  };
}
