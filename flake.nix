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
    pkgsFor = nixpkgs.legacyPackages;
    eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f system pkgsFor.${system});
    treefmtEval = eachSystem (_: pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

    # Built from the given nixpkgs instead of one nixvim imports itself, so a
    # system can share its own.
    mkNixvimConfig = pkgs:
      nixvim.lib.evalNixvim
      {
        modules = [./config {nixpkgs.pkgs = pkgs;}];
        extraSpecialArgs = {inherit inputs;};
      };
  in {
    lib.mkNeovim = pkgs: (mkNixvimConfig pkgs).config.build.package;
    formatter = eachSystem (system: _: treefmtEval.${system}.config.build.wrapper);
    checks = eachSystem (_: pkgs: {
      configCheck = (mkNixvimConfig pkgs).config.build.test;
    });
    packages = eachSystem (_: pkgs: rec {
      neovim = (mkNixvimConfig pkgs).config.build.package;
      default = neovim;
    });
  };
}
