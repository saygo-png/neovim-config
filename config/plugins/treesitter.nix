{
  lib,
  pkgs,
  ...
}: {
  performance.combinePlugins.standalonePlugins = ["nvim-treesitter"];

  # opts.foldexpr = "nvim_treesitter#foldexpr()";

  # https://github.com/nvim-treesitter/nvim-treesitter/issues/7967
  extraFiles."ftplugin/haskell.vim".text = "set nocursorline";

  autoGroups."_cmd_win".clear = true;
  autoCmd = [
    {
      group = "_cmd_win";
      event = ["CmdWinEnter"];
      callback.__raw = ''
        function()
          local ok, _ = pcall(vim.keymap.del, "n", "<CR>", { buffer = true })
          if not ok then
            -- Silently ignore error when node increment isnt set, like in q/
          end
        end
      '';
    }
  ];

  plugins.treesitter = let
    boolMatch = let
      checkPassed =
        lib.assertMsg
        (builtins.match "abc" "abc" == [] && builtins.match "foo" "abc" == null)
        "builtins.match must have changed";
    in
      regex: str: (builtins.match regex str) != null && checkPassed;

    inherit (pkgs.vimPlugins.nvim-treesitter.passthru) allGrammars;
    matchCommentGrammar = str: boolMatch ".*comment-grammar.*" str;
    filteredGrammars = builtins.filter (set: !matchCommentGrammar set.name) allGrammars;
  in {
    enable = true;
    folding = true;
    nixvimInjections = true;
    nixGrammars = true; # Install grammars with Nix
    grammarPackages = filteredGrammars;
    settings = {
      indent.enable = true;
      ignore_install = ["comment"]; # Comment parser is very slow
      auto_install = false;
      highlight.enable = true;
      incremental_selection = {
        enable = true;
        keymaps = {
          scope_incremental = "gsi";
          node_decremental = "<BS>";
          node_incremental = "<Enter>";
          init_selection = "<Enter>";
        };
      };
    };
  };
}
