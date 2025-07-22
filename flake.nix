{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    nixpkgs,
    ...
  } @ inputs: let
    forEachSystem = function:
      nixpkgs.lib.genAttrs ["x86_64-linux"] (system: function nixpkgs.legacyPackages.${system});
  in {
    packages = forEachSystem (pkgs: let
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
