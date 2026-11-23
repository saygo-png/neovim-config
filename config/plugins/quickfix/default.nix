{
  pkgs,
  config,
  lib,
  ...
}: {
  extraPlugins = [pkgs.vimPlugins.vim-qf];

  my.keymaps.normal."<leader>x" =
    config.k (lib.nixvim.mkRaw ''function() require("quicker").toggle() end '')
    "Toggle quickfi[x]";

  plugins = {
    quicker = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
    };

    nvim-bqf = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings.preview.winblend = 0;
    };
  };
}
