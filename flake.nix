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

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, impermanence, home-manager, evict, sops-nix, zen-browser, ... }@inputs: {
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
      
      sirocco = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          ./hosts/sirocco
          {
            # broadcom-sta (ASUS PCE-AC68) is marked insecure/broken in nixpkgs.
            # These must be set at the flake level so they apply during evaluation,
            # not just in the built system's closure.
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.allowBroken = true;
            nixpkgs.config.permittedInsecurePackages = [ "broadcom-sta-6.30.223.271" ];
          }
        ];
      };

      mistral = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          ./hosts/mistral
        ];
      };
      
      installer-iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/installer-iso
        ];
      };
    };
  };
}
