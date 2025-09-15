{config, ...}: let
  inherit (config) k wk;
in {
  plugins = {
    gitsigns = {
      lazyLoad.settings.event = "DeferredUIEnter";
      enable = true;
      settings = {
        current_line_blame = false;
        signcolumn = true;
      };
    };
  };

  my = {
    which-keys."<leader>gs" = wk "Gitsigns" " ";
    keymaps.normal = {
      "<leader>gsc" = k "<cmd>Gitsigns toggle_signs<CR>" "[g]it[s]igns [c]olumn";
      "<leader>gsb" = k "<cmd>Gitsigns toggle_current_line_blame<CR>" "[g]it[s]igns [b]lame";
    };
  };
}
