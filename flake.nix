{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, darwin, home-manager-unstable }@inputs: {
    nixosConfigurations = let
      system = "x86_64-linux";
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
    in
    {
      glacier = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = { inherit pkgs-unstable; };
        modules = [ ./hosts/glacier/configuration.nix ];
      };
      mageik = nixpkgs-unstable.lib.nixosSystem {
        system = system;
        specialArgs = {inherit inputs;};
        modules = [ ./hosts/mageik/configuration.nix ];
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
          user = "greatpigeon";
        };

        modules = [ ./hosts/etna/greatpigeon/home.nix ];
      };
      "greatpigeon@katmai" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit pkgs-unstable;
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
