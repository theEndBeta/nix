{ config, inputs, ... }:

{
  imports = [ inputs.home-manager-unstable.nixosModules.home-manager ];

  config = {
    home-manager.users.vesu = {
      home.stateVersion = "24.11";
      programs = {
        git = {
          enable = true;
          userName = "vesu@mageik";
          userEmail = "2302239+theEndBeta@users.noreply.github.com.";
          extraConfig = {
            commit.gpgsign = true;
            gpg.format = "ssh";
            user.signingkey = "~/.ssh/id_ed25519.pub";
          };
        };
      };
    };
  };
}
