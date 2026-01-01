{ config, lib, inputs, pkgs, ... }:

{
  networking = {
    nftables.enable = true;

    dhcpcd.extraConfig = "
      noipv6
      noipv6rs
    ";

    firewall = {
      # setting to "loose" fails in one case with wpan (thread)
      # and hasn't been fully debugged yet
      checkReversePath = false;

      logRefusedPackets = true;
      logRefusedUnicastsOnly = false;
      logReversePathDrops = true;
    };

    firewall.allowedUDPPorts = [
      53

      # govee local api
      4001
      4002
      4003
      5353

      # thread
      19788
    ];

    firewall.allowedTCPPorts = [
      22
      80
      443
      1883
      1884

      53
      853

      # otbr web
      7586

      # matter server
      5580

      # govee local api
      4001
      4002
      4003

      8080
      8081
      8443
      8888
      18083
    ];

    nat = {
      enable = true;
      enableIPv6 = false;
      externalInterface = "enp2s0";
      forwardPorts = [
        {
          destination = "10.20.1.41:8080";
          proto       = "tcp";
          sourcePort  = 80;
        }
        {
          destination = "10.20.1.41:8443";
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
