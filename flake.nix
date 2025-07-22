{
  inputs = {
    nixvim = {
      url = "github:nix-community/nixvim";
    };
  };
  outputs = {
    nixvim,
    systems,
    ...
  } @ inputs: let
    inherit (nixvim.inputs.nixpkgs) lib;
    eachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs (import systems) (system:
      import nixvim.inputs.nixpkgs {
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
