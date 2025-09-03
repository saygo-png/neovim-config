_: {
  # Plugins without any config beyond lazyloading go here.
  plugins = {
    direnv.enable = true;
    fugitive.enable = true;
    persistence.enable = true;
    vim-surround.enable = true;
    friendly-snippets.enable = true;

    fidget = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        notification.window = {
          winblend = 0;
          border = "single";
        };
      };
    };

    comment = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
    };

    web-devicons = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
    };

    lz-n.enable = true;
    lzn-auto-require.enable = true;
  };
}
