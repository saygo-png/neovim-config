{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (config) kr;
in {
  plugins.mini = {
    enable = true;
    lazyLoad.settings.event = "DeferredUIEnter";
    modules = {
      # Same keys as vim-surround: ys{motion}{char}, cs, ds, yss.
      surround.mappings = {
        add = "ys";
        delete = "ds";
        replace = "cs";
        find = "";
        find_left = "";
        highlight = "";
        update_n_lines = "";
      };

      indentscope = {
        symbol = "│";
        draw = {
          delay = 0;
          priority = 2;
          animation.__raw = "require('mini.indentscope').gen_animation.none()";
        };
        options = {
          border = "top";
          try_as_border = true;
          indent_at_cursor = true;
        };
      };
    };
  };

  # mini also maps `ys` in visual mode, which turns `y` into a prefix and makes
  # a plain visual yank wait for 'timeoutlen'. Move that mapping to `gS`
  # (`S` belongs to flash).
  plugins.mini.luaConfig.content = lib.mkAfter ''
    vim.keymap.del("x", "ys")
    vim.keymap.set("x", "gS", [[:<C-u>lua MiniSurround.add("visual")<CR>]], { silent = true, desc = "Surround selection" })
  '';

  # vim-surround's `yss`; mini only maps `ys` itself.
  my.keymaps.normal."yss" = kr "ys_" "Surround line";

  performance.combinePlugins.standalonePlugins = [
    pkgs.vimPlugins.mini-nvim
  ];
}
