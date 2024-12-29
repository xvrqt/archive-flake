# This flake collates all my host flakes together for convenience
{
  inputs = {
    #nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:NixOs/nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    cli.url = "github:xvrqt/cli-flake";
    websites.url = "github:xvrqt/website-flake";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    sops-nix,
    impermanence,
    home-manager,
    cli,
    websites,
    ... } @ inputs: let
    machine = "archive";
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.permittedInsecurePackages = [
	"dotnet-sdk-6.0.428"
	 "aspnetcore-runtime-6.0.36"
      ];
    };
  in {
    nixosConfigurations.${machine} = nixpkgs.lib.nixosSystem {
      inherit pkgs;
      specialArgs = {inherit inputs;};
      modules = [
        sops-nix.nixosModules.sops
        impermanence.nixosModules.impermanence
        cli.nixosModules.${system}.default
	websites.nixosModules.${system}.default
        ./archive.nix
	# Home Manager as a NixOS Modules (contains sub-modules)
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            extraSpecialArgs = {inherit inputs machine;};
	    backupFileExtension = ".hmbkup";
            useGlobalPkgs = true;
            useUserPackages = true;
            users.crow = {...}: {
              imports = [
                # Shell Customization & Useful Command Programs
                cli.homeManagerModules.${system}.default
                # Main Home Manager Module - pulls in sub-modules from ./home
                ./home.nix
              ];
            };
            users.archivist = {...}: {
              imports = [
                # Shell Customization & Useful Command Programs
                cli.homeManagerModules.${system}.default
                # Main Home Manager Module - pulls in sub-modules from ./home
                ./home2.nix
              ];
            };
          };
        }
      ];
    };
  };
}
