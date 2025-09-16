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
        ''
        ${pkgs.rclone}/bin/rclone \
          --config /etc/rclone.conf \
          --sftp-ssh "${pkgs-unstable.tailscale}/bin/tailscale ssh vesu@azuma" \
          sync \
          --progress \
          --fix-case \
          --track-renames \
          --delete-excluded \
          --filter '- .snapshots/**' \
          --filter '+ *.backup.sqlite3' \
          --filter '+ config.json' \
          --filter '+ rsa_key*' \
          --filter '+ attachments/**' \
          --filter '- *' \
          azuma:/data/appdata/vaultwarden \
          /mnt/dpool/backups/vaultwarden
        ''
        "${pkgs.bash}/bin/bash -c \"${pkgs.zfs}/bin/zfs snapshot dpool/backups/vaultwarden@$$(date +%%Y%%m%%d)\""
      ];
    };
  };
}
