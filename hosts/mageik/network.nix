{ config, lib, inputs, pkgs, ... }:

{
  networking = {
    nftables.enable = true;

    firewall.allowedTCPPorts = [
      22
      80
      443
      1883 # mqttv4
      1884 # mqttv5
      8080
      8443
      8888
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
