{lib, ...}: let
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
  };
}
