{config, ...}: let
  inherit (config) k;
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

  my.keymaps.normal = {
    "<leader>gsc" = k "<cmd>Gitsigns toggle_signs<CR>" "[g]it[s]igns [c]olumn";
    "<leader>gsb" = k "<cmd>Gitsigns toggle_current_line_blame<CR>" "[g]it[s]igns [b]lame";
  };
}
