# This flake collates all my host flakes together for convenienc0
{
  inputs = {
    # Essentials
    nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets
    sops-nix.url = "github:Mic92/sops-nix";
    # Ephemeral File System
    impermanence.url = "github:nix-community/impermanence";

    # My Flakes
    # Useful command line toold
    cli.url = "github:xvrqt/cli-flake";
    # Websites I'm hosting
    websites.url = "github:xvrqt/website-flake";
    # websites.url = "/home/crow/dev/website-flake";
    conduwuit.url = "github:girlbossceo/conduwuit";
    identities.url = "github:xvrqt/identities-flake";
    wireguard.url = "github:xvrqt/wireguard-flake";
    secrets.url = "github:xvrqt/secrets-flake";
  };

  outputs =
    { nixpkgs
    , secrets
    , identities
    , conduwuit
    , wireguard
    , home-manager
    , sops-nix
    , impermanence
    , cli
    , websites
    , ...
    } @ inputs:
    let
      machine = "archive";
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [
          "dotnet-sdk-6.0.428"
          "olm-3.2.16"
        ];
      };
    in
    {
      nixosConfigurations.${machine} = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        specialArgs = { inherit inputs machine; };
        modules = [
          wireguard.nixosModules.default
          wireguard.nixosModules.archive
          identities.nixosModules.default
          identities.nixosModules.users.crow
          secrets.nixosModules.default
          # Needed for secret management
          sops-nix.nixosModules.sops
          # Used to persist data across reboots
          impermanence.nixosModules.impermanence
          # Websites Hosted by this server
          websites.nixosModules.${system}.default
          # Commandline Utilities
          cli.nixosModules.${system}.default
          # Main configuration file
          ./nixos
          # Home Manager as a NixOS Modules (contains sub-modules)
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs machine; };
              backupFileExtension = ".hmbkup";
              users.crow = { ... }: {
                imports = [
                  # Shell Customization & Useful Command Programs
                  cli.homeManagerModules.${system}.default
                  # Main Home Manager Module - pulls in sub-modules from ./home
                  ./home
                ];
              };
            };
          }
        ];
      };
    };
}
