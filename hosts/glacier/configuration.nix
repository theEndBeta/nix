# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, pkgs-unstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./syncoid.nix
      #./urbackup.nix
    ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  time.timeZone = "America/New_York";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    supportedFilesystems = ["zfs"];
    zfs.forceImportRoot = false;
    zfs.extraPools = [ "dpool" ];
  };
  
  networking = {
    hostId = "3792e26b"; # `head -c 8 /etc/machine-id`

    hostName = "glacier"; # Define your hostname.

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      # allowedUDPPorts = [ ... ];
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell = pkgs.zsh;

    groups = {
      backup = {};
    };

    users.vesu = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkManager" ]; # Enable ‘sudo’ for the user.
      home = "/home/vesu";
      createHome = true;
      packages = with pkgs; [
        tree
        just
      ];
      openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJK6ko9hE8IV2s9IHvbNI+/JhIWSZ61JgnlR+xyYar+UAAAACXNzaDpnaXQtYQ== a@greatpigeon@etna"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGgJyHXOgNR+k98laa6c5LfrEhZbO7fhc8Xf9DutnWQFAAAABHNzaDo= greatpigeon@etna@cubic5c"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDkzb2zsRCU+LwKHEvnEMTxh9MBOSbAAyUz+aRFK450OAAAABHNzaDo= greatpieon@katmai@cubic5c"
      ];
    };
    users.backup = {
      isSystemUser = true;
      group = "backup";
      extraGroups = [ "users" ];
      home = "/home/backup";
      createHome = true;
      packages = [
        pkgs.sanoid
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
    vim
    wget
    tmux
    zsh
    chezmoi
    git
    sanoid
    ripgrep
    eza
    fd
    rclone

    pkgs-unstable.wezterm

    nftables

    neovim
    tree-sitter
    nil
    bash-language-server
    shellcheck
    neovim-node-client
    python311Packages.pynvim
    python311Packages.argcomplete
  ];

  environment.shells = with pkgs; [ zsh ];
  programs.zsh.enable = true;

  environment.variables.EDITOR = "nvim";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.PermitRootLogin = "yes";
  };

  services.zfs = {
    autoScrub.enable = true;
  };

  services.tailscale = {
    enable = true;
    package = pkgs-unstable.tailscale;
    extraUpFlags = [ "-ssh" ];
  };
}

# vim: set expandtab ts=2 sw=2:
