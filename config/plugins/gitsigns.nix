_: {
  plugins = {
    gitsigns = {
      lazyLoad.settings.event = "DeferredUIEnter";
      enable = true;
      settings = {
        current_line_blame = false;
        signcolumn = true;
      };
    };
    which-key = {
      settings = {
        spec = let
          nRegister = key: text: icon: {
            __unkeyed = key;
            group = text;
            inherit icon;
          };
        in [
          (nRegister "<leader>gs" "Gitsigns" " ")
        ];
      };
    };
  };

  extraConfigLua = ''
    vim.keymap.set("n", "<leader>gsc", "<cmd>Gitsigns toggle_signs<CR>", {desc = "[g]it[s]igns [c]olumn"})
    vim.keymap.set("n", "<leader>gsb", "<cmd>Gitsigns toggle_current_line_blame<CR>", {desc = "[g]it[s]igns [b]lame"})
  '';
}
