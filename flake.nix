{
  inputs.nixvim.url = "github:nix-community/nixvim";
  # inputs.nixvim.url = "github:nix-community/nixvim/nixos-25.05";
  # inputs.nixvim.url = "git+file:///home/samsepi0l/builds/nixvim?ref=fix-jupytext";

  outputs = {nixvim, ...} @ inputs: let
    inherit (nixvim.inputs.nixpkgs) lib;
    systems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    eachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs systems (system:
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
