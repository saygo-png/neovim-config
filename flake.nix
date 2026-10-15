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
      inputs.nixpkgs.follows = "nixvim/nixpkgs";
    };

    systems = {
      url = "path:./systems.nix";
      flake = false;
    };

    simple-tree-sitter-haskell = {
      url = "github:saygo-png/simple-tree-sitter-haskell";
      inputs = {
        nixpkgs.follows = "nixvim/nixpkgs";
        systems.follows = "systems";
      };
    };

    nvim-plugin-telescope-git-file-history = {
      url = "github:isak102/telescope-git-file-history.nvim";
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

    mkNixvimConfig = system:
      nixvim.lib.evalNixvim
      {
        inherit system;
        modules = [./config];
        extraSpecialArgs = {inherit inputs;};
      };
  in {
    formatter = eachSystem (system: _: treefmtEval.${system}.config.build.wrapper);
    checks = eachSystem (system: _: {
      configCheck = (mkNixvimConfig system).config.build.test;
    });
    packages = eachSystem (system: _: rec {
      neovim = (mkNixvimConfig system).config.build.package;
      default = neovim;
    });
  };
}
