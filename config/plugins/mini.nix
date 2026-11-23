{
  lib,
  config,
  ...
}: let
  inherit (config) kr;
  inherit (lib.nixvim) mkRaw;
in {
  plugins = {
    mini-indentscope = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        symbol = "│";
        draw = {
          delay = 0;
          priority = 2;
          animation = mkRaw "require('mini.indentscope').gen_animation.none()";
        };
        options = {
          border = "top";
          try_as_border = true;
          indent_at_cursor = true;
        };
      };
    };

    # Cursor restore. Loads on the first file read so the file opened at
    # startup is covered (lz.n replays the event to augroups the load creates).
    mini-misc = {
      enable = true;
      lazyLoad.settings.event = ["BufReadPre" "BufNewFile"];
      luaConfig.content = lib.mkAfter ''
        MiniMisc.setup_restore_cursor()
      '';
    };

    # Same keys as vim-surround: ys{motion}{char}, cs, ds, yss; gS in visual.
    mini-surround = {
      enable = true;
      lazyLoad.settings.keys = [
        {
          __unkeyed-1 = "ys";
          mode = "n";
          desc = "Add surrounding";
        }
        {
          __unkeyed-1 = "ds";
          mode = "n";
          desc = "Delete surrounding";
        }
        {
          __unkeyed-1 = "cs";
          mode = "n";
          desc = "Replace surrounding";
        }
        {
          __unkeyed-1 = "gS";
          mode = "x";
          desc = "Surround selection";
        }
      ];
      settings.mappings = {
        add = "ys";
        delete = "ds";
        replace = "cs";
        find = "";
        find_left = "";
        highlight = "";
        update_n_lines = "";
      };
      luaConfig.content = lib.mkAfter ''
        vim.keymap.del("x", "ys")
        vim.keymap.set("x", "gS", [[:<C-u>lua MiniSurround.add("visual")<CR>]], { silent = true, desc = "Surround selection" })
      '';
    };
  };

  my.keymaps.normal."yss" = kr "ys_" "Surround line";
}
