{ config, pkgs, pkgs-unstable, ... }:

let
  langServers = with pkgs; [
    nodePackages.pyright
    ruff-lsp
    nodePackages.yaml-language-server
    nodePackages.bash-language-server
    lua-language-server
  ];
  nvimReqs = with pkgs; [
    pkgs-unstable.neovim
    tree-sitter
  ];
in
  {
    home.packages = langServers ++ nvimReqs;
  }
