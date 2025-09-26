{pkgs, ...}: {
  # Plugins without any config beyond lazyloading go here.

  extraPlugins = [
    pkgs.vimPlugins.vim-qf
  ];

  plugins = {
    direnv.enable = true;
    fugitive.enable = true;
    persistence.enable = true;
    vim-surround.enable = true;

    lz-n.enable = true;
    lzn-auto-require.enable = true;

    comment = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
    };

    nvim-bqf = {
      enable = true;
      extraOptions = {
        preview.winblend = 0;
      };
    };

    quicker = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
    };

    web-devicons = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
    };
  };
}
