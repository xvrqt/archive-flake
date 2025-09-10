# This flake collates all my host flakes together for convenienc0
{
  inputs = {
    # Essentials
    nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Sensible NixOS defaults (enables flakes, garbage collection, sets timezone, etc...)
    defaults.url = "git+https://git.irlqt.net/crow/defaults-flake";
    defaults.inputs.nixpkgs.follows = "nixpkgs";

    # Setup secret management used by other flakes
    secrets.url = "git+https://git.irlqt.net/crow/secrets-flake";

    # Crow user login and setup
    identities.url = "git+https://git.irlqt.net/crow/identities-flake";
    identities.inputs.secrets.follows = "secrets";

    # Connect to the amy-net and irlqt-net, network security and services
    networking.url = "git+https://git.irlqt.net/crow/networking-flake";
    # networking.url = "/home/crow/dev/networking-flake";
    networking.inputs.secrets.follows = "secrets";

    # Ephemeral File System
    impermanence.url = "github:nix-community/impermanence";

    # CopyParty Module
    copyparty.url = "/home/crow/dev/copyparty";
    # copyparty.url = "github:xvrqt/copyparty";
    # copyparty.url = "github:9001/copyparty";

    # Useful command line tools
    cli.url = "git+https://git.irlqt.net/crow/cli-flake";
    cli.inputs.nixpkgs.follows = "nixpkgs";

    # Sets up a reverse proxy and websites that are hosted here
    websites.url = "git+https://git.irlqt.net/crow/website-flake";
  };

  outputs =
    { cli
    , copyparty
    , defaults
    , home-manager
    , identities
    , impermanence
    , networking
    , nixpkgs
    , secrets
    , websites
    , ...
    } @ inputs:
    let
      machine = "archive";
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ copyparty.overlays.default ];
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.${machine} = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        specialArgs = { inherit inputs machine; };
        modules = [
          copyparty.nixosModules.default
          defaults.nixosModules.default
          secrets.nixosModules.default
          identities.nixosModules.users.crow
          networking.nixosModules.archive
          impermanence.nixosModules.impermanence
          websites.nixosModules.${system}.default
          cli.nixosModules.${system}.default
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
                  cli.homeManagerModules.${system}.default
                  ./home
                ];
              };
            };
          }
        ];
      };
    };
}
