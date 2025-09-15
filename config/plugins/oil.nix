{config, ...}: let
  inherit (config) k wk;
in {
  plugins = {
    oil = {
      enable = true;
      settings.defaultFileExplorer = true;
      lazyLoad.settings = {
        cmd = "Oil";
        event = "VimEnter";
      };
    };
  };

  performance.combinePlugins.standalonePlugins = ["oil.nvim"];

  my = {
    which-keys."<leader>f" = wk "File browser" " ";
    keymaps.normal."<leader>f" = k "<cmd>Oil<CR>" "[f]ile browser";
  };
}
