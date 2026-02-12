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
    inherit (nixvim.inputs.nixpkgs) lib;
    eachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs (import systems) (system:
      import nixvim.inputs.nixpkgs {
        inherit system;
      });
    treefmtEval = eachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
  in {
    formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
    packages = eachSystem (pkgs: let
      nixvimModule = {
        inherit pkgs;
        module = import ./config;
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
