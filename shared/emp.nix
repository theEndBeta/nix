{ config, pkgs, pkgs-unstable, ... }:

let
  goDevTools = [
    pkgs-unstable.go
    pkgs-unstable.gopls
    pkgs-unstable.golangci-lint
    pkgs-unstable.golangci-lint-langserver
    pkgs-unstable.gofumpt
  ];
  empPkgs = with pkgs; [
    git
    pkgs-unstable.gh
    pkgs-unstable.uv

    awscli2

    nodePackages.pyright
    nodePackages.yaml-language-server
    nodePackages.bash-language-server
    ruff-lsp

    shellcheck

    pipx

    # dagger + pants need the docker cli tools
    docker-client
    docker-buildx

    nodePackages.aws-cdk
  ];
in
  {
    home.packages = empPkgs ++ goDevTools;
  }
