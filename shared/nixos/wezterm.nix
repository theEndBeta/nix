{
  inputs,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  wezterm.url = "github:wezterm/wezterm?dir=nix";
in

  {
    environment.systemPackages = [wezterm.packages.${pkgs.system}.default];

    nix.settings = {
        substituters = ["https://wezterm.cachix.org"];
        trusted-public-keys = ["wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="];
    };
  }
