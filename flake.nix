{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin-unstable = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wezterm.url = "github:wezterm/wezterm?dir=nix";
  };

  outputs = inputs @ {
      self,
      nixpkgs,
      nixpkgs-unstable,
      darwin,
      darwin-unstable,
      home-manager,
      home-manager-unstable,
      ...
    }: {
    nixosConfigurations = let
      system = "x86_64-linux";
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
    in
    {
      glacier = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = { inherit pkgs-unstable; inherit inputs; };
        modules = [ ./hosts/glacier/configuration.nix ./shared/nixos/wezterm.nix ./shared/nixos/auto-upgrade.nix ];
      };
      mageik = nixpkgs-unstable.lib.nixosSystem {
        system = system;
        specialArgs = {inherit inputs;};
        modules = [ ./hosts/mageik/configuration.nix ./shared/nixos/wezterm.nix ./shared/nixos/auto-upgrade.nix ];
      };
    };

    homeConfigurations = let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
    in
    {
      "greatpigeon@etna" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit pkgs-unstable;
          inherit inputs;
          user = "greatpigeon";
        };

        modules = [ ./hosts/etna/greatpigeon/home.nix ];
      };
      "greatpigeon@katmai" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit pkgs-unstable;
          inherit inputs;
          user = "greatpigeon";
        };

        modules = [
          ./hosts/katmai/greatpigeon/home.nix
          ./shared/emp.nix
          ./shared/nvim.nix
        ];
      };
    };

    darwinConfigurations = let
      system = "aarch64-darwin";
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
    in
    {
      fuji = darwin.lib.darwinSystem {
        system = system;
        specialArgs = {
          inherit pkgs-unstable;
        };
        modules = [ 
          home-manager.darwinModules.home-manager
          ./hosts/fuji/configuration.nix
        ];
      };
    };
  };
}
