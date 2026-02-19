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
    diskoConfigurations = {
      vm        = import ./hosts/vm/disks.nix;
      sirocco   = import ./hosts/sirocco/disks.nix;
      mistral   = import ./hosts/mistral/disks.nix;
      mistral-vm = import ./hosts/mistral/disks.nix;
    };

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
          ({ lib, ... }: {
            # broadcom-sta (ASUS PCE-AC68) is marked insecure in nixpkgs.
            # Use a predicate so we don't need to hard-code the exact version string.
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.allowInsecurePredicate = pkg:
              lib.getName pkg == "broadcom-sta";
          })
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

      # mistral config with NVIDIA overridden for VM testing
      mistral-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          ./hosts/mistral
          ({ lib, ... }: {
            # No NVIDIA hardware in a VM — use the generic modesetting driver
            services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];
            hardware.nvidia.modesetting.enable = lib.mkForce false;
            hardware.nvidia.powerManagement.enable = lib.mkForce false;
            hardware.nvidia.powerManagement.finegrained = lib.mkForce false;
            hardware.nvidia.prime.offload.enable = lib.mkForce false;
            hardware.nvidia.prime.offload.enableOffloadCmd = lib.mkForce false;
            # Re-enable power-profiles-daemon since TLP is for real hardware
            services.power-profiles-daemon.enable = lib.mkForce true;
            services.tlp.enable = lib.mkForce false;
            services.thermald.enable = lib.mkForce false;
          })
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
