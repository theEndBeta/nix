{pkgs, lib, pkgs-unstable, ...}:

{
  programs.zsh = {
    enable = true;

    # I add to fpath myself
    enableCompletion = false;
    enableBashCompletion = false;
  };

  services.nix-daemon.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  nix.extraOptions = ''
    # from determinate systems installer
    build-users-group = nixbld
    experimental-features = nix-command flakes repl-flake
    bash-prompt-prefix = (nix:$name)\040
    max-jobs = auto
    extra-nix-path = nixpkgs=flake:nixpkgs
  '';

#  launchd.agents = {
#    homebrewSSHAgent = {
#      serviceConfig = {
#        Label = "com.homebrew.openssh.ssh-agent";
#        EnableTransactions = true;
#        ProgramArguments = ["/opt/homebrew/bin/ssh-agent" "-D"];
#        Sockets.Listeners = {
#            SecureSocketWithKey = "SSH_AUTH_SOCK";
#          };
#        };
#      };
#    };
  launchd.agents = {
    homebrewSSHd = {
      serviceConfig = {
        Label = "com.homebrew.sshd";
        KeepAlive = true;
        ProgramArguments = ["/opt/homebrew/sbin/sshd" "-D"];
      };
    };
  };

  system.stateVersion = 4;
  system.defaults = {
    dock = {
      autohide = true;
      tilesize = 32;
    };

    menuExtraClock.Show24Hour = true;
  };

  networking = {
    hostName = "fuji";
  };

  environment.systemPackages = with pkgs; [
    tmux
    neovim
    chezmoi
    curl
    wget
    git
    just
    bitwarden-cli

    ripgrep
    eza
    fd
    bat
    difftastic
    jq
    bottom

    fzf
    tree-sitter

    python311Packages.argcomplete

    podman-tui
  ];

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "Hack" ]; })
    ];
  };

  users.users.aidanstein = {
    home = "/Users/aidanstein";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.aidanstein = { pkgs, ... }: {
      imports = [
        ../../shared/emp.nix
      ];
      home = {
        stateVersion = "23.11";
        packages = with pkgs; [
          nodePackages.bash-language-server
          nodePackages.yaml-language-server
          nodePackages.pyright
          nodePackages.yarn
          nil
          marksman
          pipx
          hadolint
        ];
      };
    };
  };

  # still needs to be installed manually
  # https://brew.sh/
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    brews = [
      "libfido2"
      "openssh"
      "pyenv"
      "awscli"
      "gcc"

      # etxlib requirements
      "gfortran"
      "cython"
      "lapack"
      "openblas"
      "podman"
      "qemu"
      "viddy"
      "docker"
      "docker-buildx"
    ];
    casks = [
      "warp"
      "podman-desktop"
    ];
    taps = [
      "pantsbuild/tap"
      "dagger/tap"
    ];
  };
}

# vim: set expandtab ts=2 sw=2:
