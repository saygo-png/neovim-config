{
  lib,
  inputs,
  config,
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

  extraPlugins =
    lib.singleton
    ((pkgs.vimUtils.buildVimPlugin {
        name = "treesitter-modules";
        src = inputs.nvim-plugin-treesitter-modules;
      }).overrideAttrs
      {dependencies = [config.plugins.treesitter.package];});

  extraConfigLua = ''
    require('treesitter-modules').setup({
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<Enter>",
                node_incremental = "<Enter>",
                scope_incremental = "gsi",
                node_decremental = "<BS>",
            },
        },
    })
  '';

  plugins = {
    treesitter = {
      enable = true;
      folding.enable = true;
      nixvimInjections = true;
      indent.enable = true;
      highlight.enable = true;
    };
  };
}
