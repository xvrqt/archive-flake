# This flake collates all my host flakes together for convenience
{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    #nixpkgs.url = "github:NixOs/nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    cli.url = "github:xvrqt/cli-flake";
    websites.url = "github:xvrqt/website-flake";
  };

  outputs = {
    nixpkgs,
    sops-nix,
    impermanence,
    cli,
    websites,
    ... } @ inputs: let
    machine = "archive";
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
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
      ];
    };
  };
}
