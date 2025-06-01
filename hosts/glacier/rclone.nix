{ config, options, pkgs, ... }:
{
  environment.systemPackages = [pkgs.rclone];

  environment.etc."rclone.conf".source = ./rclone.conf;
}
