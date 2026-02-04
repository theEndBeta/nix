{ config, inputs, ... }:

{
  imports = [ inputs.home-manager-unstable.nixosModules.home-manager ];

  config = {
    home-manager.users.vesu = {
      home.stateVersion = "25.11";
      programs = {
        git = {
          enable = true;
          settings = {
            user= {
              name = "vesu@mageik";
              email = "2302239+theEndBeta@users.noreply.github.com.";
            };
            commit.gpgsign = true;
            gpg.format = "ssh";
            user.signingkey = "~/.ssh/id_ed25519.pub";
          };
        };
      };
    };
  };
}
