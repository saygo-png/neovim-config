{
  # Plugins without any config beyond lazyloading go here.
  plugins = {
    direnv.enable = true;
    # fugitive.enable = true;
    # persistence.enable = true;
    vim-surround.enable = true;

    lz-n.enable = true;

    comment = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
    };

    web-devicons = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
    };
  };
}
