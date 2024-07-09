{pkgs, lib, pkgs-unstable, ...}:

{
  programs.zsh = {
    enable = true;

    # I add to fpath myself
    enableCompletion = false;
    enableBashCompletion = false;
  };

  services.nix-daemon.enable = true;
  services.tailscale = {
    enable = true;
    package = pkgs-unstable.tailscale;
  };

  security.pam.enableSudoTouchIdAuth = true;

  nix.extraOptions = ''
    # from determinate systems installer
    build-users-group = nixbld
    experimental-features = nix-command flakes repl-flake
    bash-prompt-prefix = (nix:$name)\040
    max-jobs = auto
    extra-nix-path = nixpkgs=flake:nixpkgs
  '';

#  launchd.user.agents = {
#    homebrewSSHAgent = {
#      serviceConfig = {
#        Label = "com.homebrew.openssh.ssh-agent";
#        EnableTransactions = true;
#        ProgramArguments = [
#          "/opt/homebrew/bin/ssh-agent"
#          "-D"
#        ];
#        Sockets.Listeners = {
#          SecureSocketWithKey = "SSH_AUTH_SOCK";
#        };
#      };
#    };
#  };

  launchd.agents = {
    homebrewSSHd = {
      serviceConfig = {
        Label = "com.homebrew.sshd";
        KeepAlive = true;
        ProgramArguments = ["/opt/homebrew/sbin/sshd" "-D"];
      };
    };
    homebrewSSHAgent = {
      serviceConfig = {
        Label = "com.homebrew.openssh.ssh-agent";
        EnableTransactions = true;
        ProgramArguments = [
          "/opt/homebrew/bin/ssh-agent"
          "-D"
        ];
        Sockets.Listeners = {
          SecureSocketWithKey = "SSH_AUTH_SOCK";
        };
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
    pkgs-unstable.neovim
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

    lima
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
    extraSpecialArgs = { inherit pkgs-unstable; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.aidanstein = { pkgs, home, pkgs-unstable, ... }: {
      imports = [
        ../../shared/emp.nix
        ../../shared/nvim.nix
      ];
      home = {
        stateVersion = "24.05";
        packages = with pkgs; [
          nodePackages.yarn
          nil
          marksman
          hadolint
        ];
      };
    };
  };

  homebrew = let
    aws-brews = [
      "awscli"
      "aws-cdk"
      "cloudformation-cli"
    ];
    containers = [
        "podman"
        "podman-compose"
        "qemu"
        "docker"
        "docker-buildx"
        "vfkit"
    ];
  in
    # still needs to be installed manually
    # https://brew.sh/
    {
      enable = true;
      onActivation.autoUpdate = true;
      brews = [
        "libfido2"
        "openssh"
        "pyenv"
        "gcc"

        "gnu-sed" # gsed
        "findutils" # gxargs

        # etxlib requirements
        "gfortran"
        "cython"
        "lapack"
        "openblas"

        "viddy"
        "databricks"

        "opentofu"
        "tflint"
        "terraform-ls"
        "terragrunt"
      ]
      ++ aws-brews
      ++ containers
      ;
      casks = [
        "podman-desktop"
      ];
      taps = [
        "pantsbuild/tap"
        "dagger/tap"
        "cfergeau/crc"
        "databricks/tap"
      ];
    };
}

# vim: set expandtab ts=2 sw=2:
