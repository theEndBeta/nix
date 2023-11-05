{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager }@inputs: {
    nixosConfigurations = {
      glacier = nixpkgs.lib.nixosSystem {
        system = "x86-64-linux";
        modules = [ ./hosts/glacier/configuration.nix ];
      };
      mageik = nixpkgs.lib.nixosSystem {
        system = "x86-64-linux";
        specialArgs = {inherit inputs;};
        modules = [ ./hosts/mageik/configuration.nix ];
      };
    };

    homeConfigurations = let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      "greatpigeon@etna" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          user = "greatpigeon";
        };

        modules = [ ./hosts/etna/greatpigeon/home.nix ];
      };
      "greatpigeon@katmai" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          user = "greatpigeon";
        };

        modules = [ ./hosts/katmai/greatpigeon/home.nix ];
      };
    };
  };
}
