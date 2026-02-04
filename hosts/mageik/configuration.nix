# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, inputs, ... }:

{
  # specialArgs = { inherit inputs; };
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./sanoid.nix
      ./home.nix
      ./podman.nix
      ./network.nix
    ];

  time.timeZone = "America/New_York";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 524288000;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    supportedFilesystems = ["zfs"];
    zfs.forceImportRoot = false;
    zfs.extraPools = [ "tank" ];

    kernelModules = [
      "ip_tables"
      "iptable_nat"
      "iptable_mangle"
      "iptable_filter"
      "ip6_tables"
      "ip6table_nat"
      "ip6table_mangle"
      "ip6table_filter"
    ];

    kernel.sysctl = {
      "fs.inotify.max_user_instances" = 8192;
      "fs.inotify.max_user_watches" = 524288;
      "fs.file-max" = 100000;

      # /etc/sysctl.d/60-otbr-accept-ra.conf
      "net.ipv6.conf.enp1s0.accept_ra" = 2;
      "net.ipv6.conf.enp1s0.accept_ra_rt_info_max_plen" = 64;

      "net.ipv6.conf.enp2s0.accept_ra" = 2;
      "net.ipv6.conf.enp2s0.accept_ra_rt_info_max_plen" = 64;

      # /etc/sysctl.d/60-otbr-ip-forward.conf
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv4.ip_forward" = 1;
    };
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = "8192";
    }
  ];

  networking.hostId = "ca804fa7"; # `head -c 8 /etc/machine-id`

  networking.hostName = "mageik";

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Wait for system-level network-online.service
  # https://github.com/systemd/systemd/issues/3312#issuecomment-2185399471
  systemd.user.services.network-online-user = {
    enable = true;
    description = "Wait for system-level network-online.service";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c \'until ${pkgs.systemd}/bin/systemctl is-active network-online.target; do sleep 1; done\'";
      RemainAfterExit = "yes";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell = pkgs.zsh;

    users.vesu = {
      isNormalUser = true;
      linger = true;
      extraGroups = [ "wheel" "networkManager" "dialout" ]; # Enable ‘sudo’ for the user.
      home = "/home/vesu";
      createHome = true;
      packages = [
        pkgs.bitwarden-cli
        pkgs.yaml-language-server
      ];
      subUidRanges = [
        { startUid = 100000; count = 65536; }
      ];
      subGidRanges = [
        { startGid = 100000; count = 65536; }
      ];
      openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJK6ko9hE8IV2s9IHvbNI+/JhIWSZ61JgnlR+xyYar+UAAAACXNzaDpnaXQtYQ== a@greatpigeon@etna"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGgJyHXOgNR+k98laa6c5LfrEhZbO7fhc8Xf9DutnWQFAAAABHNzaDo= greatpigeon@etna@cubic5c"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDkzb2zsRCU+LwKHEvnEMTxh9MBOSbAAyUz+aRFK450OAAAABHNzaDo= greatpieon@katmai@cubic5c"
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    wget
    zsh
    chezmoi
    git
    sanoid
    ripgrep
    eza
    fd
    fzf
    difftastic
    bat
    jq
    unzip
    yazi

    gcc
    gnumake

    just

    python3

    tree-sitter
    nil
    nodePackages.bash-language-server
    shellcheck
    neovim-node-client
    python311Packages.pynvim
    python311Packages.argcomplete
  ];

  environment.shells = with pkgs; [ zsh ];
  programs = {
    zsh.enable = true;
    tmux.enable = true;
  };

  environment.variables.EDITOR = "nvim";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  services.cockpit = {
    enable = true;
    port = 9090;
    allowed-origins = ["https://mageik.larkspur.casa" "https://mageik.larkspur.casa:9090"];
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

  services.zfs = {
    autoScrub.enable = true;
  };
}

# vim: set expandtab ts=2 sw=2:
