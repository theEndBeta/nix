{ config, lib, inputs, pkgs, ... }:

{
  networking = {
    nftables.enable = true;

    firewall.allowedUDPPorts = [
      # govee local api
      4001
      4002
      4003
    ];

    firewall.allowedTCPPorts = [
      22
      80
      443
      1883
      1884

      # govee local api
      4001
      4002
      4003

      8080
      8443
      8888
      18083
    ];

    nat = {
      enable = true;
      externalInterface = "enp1s0";
      forwardPorts = [
        {
          destination = "10.10.0.142:8080";
          proto       = "tcp";
          sourcePort  = 80;
        }
        {
          destination = "10.10.0.142:8443";
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
