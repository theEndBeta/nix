{pkgs, lib, ...}:

{
  programs.zsh.enable = true;

  services.nix-daemon.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

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
    git
  ];

  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      recursive
      (nerdFonts.override { fonts = ["Hack"]; })
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    userUserPackages = true;
    users.aidanstein = { pkgs }: {
      stateVersion = "23.05";
    };
  };

  # still needs to be installed manually
  # https://brew.sh/
  homebrew = {
    enable = true;
    autoUpdate = true;
    casks = [
      "warp"
    ];
  };
}
