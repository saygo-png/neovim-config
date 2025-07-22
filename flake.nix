{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixvim,
    systems,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    eachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs (import systems) (system:
      import nixpkgs {
        inherit system;
      });
  in {
    packages = eachSystem (pkgs: let
      nixvimModule = {
        inherit pkgs;
        module = import ./config.nix;
        extraSpecialArgs = {
          inherit inputs;
        };
      };
    in rec {
      neovim = nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule nixvimModule;
      default = neovim;
    });
  };
}
