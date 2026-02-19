{
  inputs = {
    nixvim = {
      # url = "git+file:///home/samsepi0l/builds/nixvim?ref=lazy-nuscht";
      url = "github:nix-community/nixvim";
      inputs = {
        systems.follows = "systems";
        flake-parts.inputs.nixpkgs-lib.inputs.nixpkgs.follows = "nixvim";
      };
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixvim";
    };

    systems = {
      url = "path:./systems.nix";
      flake = false;
    };

    nvim-plugin-telescope-git-file-history = {
      url = "github:isak102/telescope-git-file-history.nvim";
      flake = false;
    };

    nvim-plugin-treesitter-modules = {
      url = "github:MeanderingProgrammer/treesitter-modules.nvim";
      flake = false;
    };
  };
  outputs = {
    nixvim,
    systems,
    ...
  } @ inputs: let
    inherit (nixvim.inputs) nixpkgs;
    pkgsFor = nixpkgs.lib.genAttrs (import systems) (system: import nixpkgs {inherit system;});
    eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f system pkgsFor.${system});
    treefmtEval = eachSystem (_: pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
  in {
    formatter = eachSystem (system: _: treefmtEval.${system}.config.build.wrapper);
    packages = eachSystem (_system: pkgs: let
      nixvimModule = {
        inherit pkgs;
        module = import ./config;
        extraSpecialArgs = {inherit inputs;};
      };
    in rec {
      neovim = nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system}.makeNixvimWithModule nixvimModule;
      default = neovim;
    });
  };
}
