{config, ...}: let
  inherit (config) wk;
in {
  plugins = {
    which-key = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        delay = 1000;
        win.border = "single";
      };
    };
  };
  my.which-keys = {
    "<leader>r" = wk "Re" " ";
    "<leader>q" = wk "Quit" "󰩈 ";
    "<leader>S" = wk "Sort by length" "󰒼 ";
  };
}
