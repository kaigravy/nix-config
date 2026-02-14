{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    evict = {
      url = "github:TRPB/evict";
      flake = true;
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-doom-emacs = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
    };
  };

  outputs = { self, nixpkgs, disko, impermanence, home-manager, evict, sops-nix, nix-doom-emacs, ... }@inputs: {
    nixosConfigurations = {
      vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          ./hosts/vm
        ];
      };
    };
  };
}
