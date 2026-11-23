{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (config) k wk toLazyKeys;
  inherit (lib.nixvim) mkRaw;
in {
  # Use conform-nvim for gq formatting.
  opts.formatexpr = "v:lua.require'conform'.formatexpr()";

  performance.byteCompileLua.excludedPlugins = ["conform.nvim"];

  my.which-keys = {
    "<leader>c" = wk "Format" " ";
    "<leader>ct".icon = " ";
    "<leader>cn".icon = " ";
  };

  plugins = {
    conform-nvim = {
      enable = true;
      autoInstall = {
        enable = true;
        overrides = {
          treefmt = null; # I want treefmt provided by devshells
          fourmolu = null;
        };
      };

      lazyLoad.settings = {
        cmd = "Conform";
        keys = toLazyKeys {
          "<leader>cc" = k (mkRaw "function() require('conform').format({ timeout_ms = 5000}) end") "[c]onform";
          "<leader>ct" = k (mkRaw "function() require('conform').format({ timeout_ms = 5000, formatters = { 'my-treefmt' } }) end") "[t]reefmt";
          "<leader>cn" = k (mkRaw "function() require('conform').format({ timeout_ms = 20000, formatters = { 'flakeformat' } }) end") "[n]ix fmt";
        };
      };

      settings = {
        default_format_opts.lsp_format = "never";
        formatters_by_ft = {
          "*" = ["squeeze_blanks" "trim_whitespace" "trim_newlines"];
          json = ["jq"];
          sh = ["shfmt"];
          lua = ["stylua"];
          python = ["yapf"];
          css = ["biome"];
          nix = ["alejandra"];
          html = ["biome"];
          scss = ["biome"];
          jsonc = ["biome"];
          cabal = ["my-cabal-gild"];
          haskell = ["fourmolu"];
          graphql = ["biome"];
          markdown = ["biome"];
          javascript = ["biome"];
          typescript = ["biome"];
          javascriptreact = ["biome"];
          typescriptreact = ["biome"];
        };
        formatters = {
          shfmt.args = lib.mkOptionDefault ["-i" "2"];
          squeeze_blanks.command = pkgs.lib.getExe' pkgs.coreutils "cat";
          my-treefmt = {
            command = "treefmt";
            args = ["$FILENAME"];
            stdin = false;
          };
          my-cabal-gild = {
            command = "cabal-gild";
            args = ["--stdin=$FILENAME"];
            stdin = true;
          };
          flakeformat = {
            command = "nix";
            args = ["fmt" "$FILENAME"];
            stdin = false;
          };
        };
      };
    };
  };

  extraPackages = [
    pkgs.haskellPackages.cabal-gild
  ];

  userCommands.Conform = {
    command.__raw = "function() require('conform').format({ timeout_ms = 5000 }) end";
    desc = "Format using Conform with a 5s timeout";
  };
}
