{ config, pkgs, pkgs-unstable, ... }:
{
  environment.systemPackages = [pkgs.rclone];

  environment.etc."rclone.conf".source = ./rclone.conf;


  systemd.user.services.vaultwarden-db-backup = {
    unitConfig.ConditionUser = ["|backup" "|vesu"];
    requires = ["mnt-dpool-backups-vaultwarden.mount"];
    wantedBy = ["default.target"];
    path = [pkgs.openssh pkgs-unstable.tailscale];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs-unstable.tailscale}/bin/tailscale ssh vesu@ntfy -- systemctl --user start vaultwarden-db-backup"
        ''
        ${pkgs.rclone}/bin/rclone \
          --config /etc/rclone.conf \
          --sftp-ssh "${pkgs-unstable.tailscale}/bin/tailscale ssh vesu@ntfy" \
          sync \
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
          /mnt/dpool/backups/vaultwarden
        ''
        "${pkgs.bash}/bin/bash -c \"${pkgs.zfs}/bin/zfs snapshot dpool/backups/vaultwarden@$$(date +%%Y%%m%%d)\""
      ];
    };
  };
}
