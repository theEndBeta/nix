{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager }: {
    nixosConfigurations = {
      glacier = nixpkgs.lib.nixosSystem {
        system = "x86-64-linux";
        modules = [ ./hosts/glacier/configuration.nix ];
      };
    };
  };
}
