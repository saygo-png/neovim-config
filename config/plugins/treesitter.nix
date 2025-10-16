{
  lib,
  pkgs,
  ...
}: {
  performance.combinePlugins.standalonePlugins = ["nvim-treesitter"];

  # https://github.com/nvim-treesitter/nvim-treesitter/issues/7967
  extraFiles."ftplugin/haskell.vim".text = "set nocursorline";

  autoGroups."_cmd_win".clear = true;
  autoCmd = lib.singleton {
    group = "_cmd_win";
    event = ["CmdWinEnter"];
    callback.__raw = ''
      function()
        local ok, _ = pcall(vim.keymap.del, "n", "<CR>", { buffer = true })
        -- Silently ignore error when node increment isn't set like in q/
        if not ok then end
      end
    '';
  };

  plugins.treesitter = let
    inherit (pkgs.vimPlugins.nvim-treesitter.passthru) allGrammars;
    boolMatch = regex: str: (builtins.match regex str) != null && checkPassed;
    checkPassed =
      lib.assertMsg
      (builtins.match "abc" "abc" == [] && builtins.match "foo" "abc" == null)
      "builtins.match must have changed";
    matchCommentGrammar = str: boolMatch ".*comment-grammar.*" str;
    filteredGrammars = builtins.filter (set: !matchCommentGrammar set.name) allGrammars;
  in {
    enable = true;
    folding = true;
    nixvimInjections = true;
    grammarPackages = filteredGrammars;
    nixGrammars = true; # Install grammars with Nix
    settings = {
      auto_install = false;
      indent.enable = true;
      highlight.enable = true;
      ignore_install = ["comment"]; # Comment parser is very slow
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
