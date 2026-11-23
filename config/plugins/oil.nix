{config, ...}: let
  inherit (config) k;
in {
  plugins = {
    oil = {
      enable = true;
      lazyLoad.settings = {
        cmd = "Oil";
        event = "VimEnter";
      };
    };
  };

  performance.combinePlugins.standalonePlugins = ["oil.nvim"];

  my = {
    which-keys."<leader>f".icon = " ";
    keymaps.normal."<leader>f" = k "<cmd>Oil<CR>" "[f]ile browser";
  };
}
