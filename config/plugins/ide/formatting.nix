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

  my.which-keys."<leader>c" = wk "Conform" " ";
  my.which-keys."<leader>nc" = wk "Nix fmt" " ";
  my.which-keys."<leader>gc" = wk "Treefmt" " ";

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
          "<leader>c" = k (mkRaw "function() require('conform').format({ timeout_ms = 500}) end") "[c]onform";
          "<leader>gc" = k (mkRaw "function() require('conform').format({ timeout_ms = 5000, formatters = { 'my-treefmt' } }) end") "[c]onform";
          "<leader>nc" = k (mkRaw "function() require('conform').format({ timeout_ms = 20000, formatters = { 'flakeformat' } }) end") "[n]ix [c]onform";
        };
      };

      settings = {
        default_format_opts.lsp_format = "never";
        formatters_by_ft = let
          foo = v: lib.nixvim.utils.listToUnkeyedAttrs ([] ++ v);
          fmts = {
            json = ["jq"];
            sh = ["shfmt"];
            lua = ["stylua"];
            python = ["yapf"];
            css = ["prettierd"];
            nix = ["alejandra"];
            html = ["prettierd"];
            scss = ["prettierd"];
            jsonc = ["prettierd"];
            cabal = ["cabal_fmt"];
            haskell = ["fourmolu"];
            graphql = ["prettierd"];
            markdown = ["prettierd"];
            javascript = ["prettierd"];
            typescript = ["prettierd"];
            javascriptreact = ["prettierd"];
            typescriptreact = ["prettierd"];
          };
        in
          (builtins.mapAttrs (_: v: {stop_after_first = true;} // foo v) fmts)
          // {"*" = ["squeeze_blanks" "trim_whitespace" "trim_newlines"];};
        formatters = {
          shfmt.args = lib.mkOptionDefault ["-i" "2"];
          squeeze_blanks.command = pkgs.lib.getExe' pkgs.coreutils "cat";
          my-treefmt = {
            command = "treefmt";
            args = ["$FILENAME"];
            stdin = false;
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

  userCommands.Conform = {
    command.__raw = "function() require('conform').format({ timeout_ms = 500 }) end";
    desc = "Format using Conform with a 500ms timeout";
  };
}
