{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (config) k wk;
  inherit (lib.nixvim) mkRaw;
in {
  extraPackages = [
    pkgs.stylua # Lua formatter
    pkgs.shfmt # Shell formatter
    pkgs.yapf # Python formatter
    pkgs.isort # Python import sorter
    pkgs.prettierd # Javascript formatter
    pkgs.haskellPackages.fourmolu # Haskell formatter
    pkgs.haskellPackages.cabal-fmt # Haskell .cabal formatter
    pkgs.nodePackages.prettier # Javascript formatter
  ];

  # Use conform-nvim for gq formatting.
  opts.formatexpr = "v:lua.require'conform'.formatexpr()";

  plugins = {
    conform-nvim = {
      enable = true;
      lazyLoad.settings.cmd = "Conform";
      settings = {
        lsp_fallback = false;
        formatters_by_ft = let
          addTreefmt = v: lib.nixvim.utils.listToUnkeyedAttrs (["treefmt"] ++ v);
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
            haskell = ["fourmolu"];
            graphql = ["prettierd"];
            markdown = ["prettierd"];
            javascript = ["prettierd"];
            typescript = ["prettierd"];
            javascriptreact = ["prettierd"];
            typescriptreact = ["prettierd"];
          };
        in
          (builtins.mapAttrs (_: v: {stop_after_first = true;} // addTreefmt v) fmts)
          // {"*" = ["squeeze_blanks" "trim_whitespace" "trim_newlines"];};
        formatters = {
          flakeformat = {
            command = "nix";
            args = ["fmt" "$FILENAME"];
            stdin = false;
          };
          cljfmt = {
            command = "${lib.getExe pkgs.cljfmt}";
            args = ["fix" "-"];
          };
          shfmt.args = lib.mkOptionDefault ["-i" "2"];
          squeeze_blanks.command = pkgs.lib.getExe' pkgs.coreutils "cat";
        };
      };
    };
  };

  my = {
    which-keys."<leader>c" = wk "Conform" " ";
    keymaps.normal = {
      "<leader>nc" = k (mkRaw "function()
          require('conform').format({ timeout_ms = 20000, formatters = { 'flakeformat' } })
        end") "[n]ix [c]onform";

      "<leader>c" = k (mkRaw "function()
          require('conform').format({ timeout_ms = 500 })
        end") "[c]onform";
    };
  };

  userCommands = {
    Conform = {
      command.__raw = "function() require('conform').format({ timeout_ms = 500 }) end";
      desc = "Format using Conform with a 500ms timeout";
    };
  };
}
