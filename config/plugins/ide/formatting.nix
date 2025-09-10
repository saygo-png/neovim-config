{
  lib,
  pkgs,
  ...
}: {
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
  opts = {
    # Use conform-nvim for gq formatting. ('formatexpr' is set to vim.lsp.formatexpr(),
    # so you can format lines via gq if the language server supports it).
    formatexpr = "v:lua.require'conform'.formatexpr()";
  };

  plugins = {
    conform-nvim = {
      enable = true;
      lazyLoad.settings.cmd = "Conform";
      settings = {
        lsp_fallback = false;
        formatters_by_ft = let
          stopAfterFirst = {stop_after_first = true;};
          addTreefmt = v: listToUnkeyedAttrs (["treefmt"] ++ v);
          inherit (lib.nixvim.utils) listToUnkeyedAttrs;
          inherit (builtins) mapAttrs;

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
          (mapAttrs (_: v: stopAfterFirst // addTreefmt v) fmts)
          // {
            "*" = [
              "squeeze_blanks"
              "trim_whitespace"
              "trim_newlines"
            ];
          };
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

    which-key.settings.spec = [
      {
        __unkeyed = "<leader>c";
        group = "Conform";
        icon = " ";
      }
      {
        __unkeyed = "<leader>nc";
        group = "Nix";
        icon = " ";
      }
    ];
  };

  keymaps = [
    {
      key = "<leader>nc";
      action.__raw = "function()
          require('conform').format({ timeout_ms = 20000, formatters = { 'flakeformat' } })
        end";
      options.desc = "nix [c]onform";
    }
    {
      key = "<leader>c";
      action.__raw = "function()
          require('conform').format({ timeout_ms = 500 })
        end";
      options.desc = "[c]onform";
    }
  ];

  userCommands = {
    Conform = {
      command.__raw = "function()
          require('conform').format({ timeout_ms = 500 })
        end";
      desc = "Format using Conform with a 500ms timeout";
    };
  };
}
