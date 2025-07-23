{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim-plugin-telescope-git-file-history = {
      url = "github:isak102/telescope-git-file-history.nvim";
      flake = false;
    };

    nvim-plugin-cutlass = {
      url = "github:gbprod/cutlass.nvim";
      flake = false;
    };

    nvim-plugin-faster = {
      url = "github:pteroctopus/faster.nvim";
      flake = false;
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
