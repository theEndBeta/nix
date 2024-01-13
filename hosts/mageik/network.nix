{ config, lib, inputs, pkgs, ... }:

{
  networking = {
    nftables.enable = true;

    firewall.allowedTCPPorts = [ 22 ];

    nat = {
      enable = true;
      externalInterface = "enp1s0";
      forwardPorts = [
        {
          destination = "127.0.0.1:8080";
          proto       = "tcp";
          sourcePort  = 80;
        }
        {
          destination = "127.0.0.1:8443";
          proto       = "tcp";
          sourcePort  = 443;
        }
      ];
    };
  };

  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--ssh" ];
  };
}
