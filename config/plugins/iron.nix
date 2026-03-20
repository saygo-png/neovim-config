{
  plugins.iron = {
    enable = true;
    settings = {
      keymaps = {
        toggle_repl = "<space>rr";
        send_line = "<space>rsl";
        send_motion = "<space>rsc";
        visual_send = "<space>rsc";
      };
      repl_open_cmd.__raw = ''require("iron.view").bottom(20)'';
      repl_definition.haskell = {
        command.__raw = ''
          function(meta)
            local file = vim.api.nvim_buf_get_name(meta.current_bufnr)
            -- call `require` in case iron is set up before haskell-tools
            return require('haskell-tools').repl.mk_repl_cmd(file)
          end
        '';
      };
    };
  };
}
