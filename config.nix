_: {
  plugins = {
    web-devicons.enable = true; # disable warn

    lz-n.enable = true;
    telescope.enable = true;
    conform-nvim = {
      enable = true;
      lazyLoad.settings = {
        keys = ["gq"];
      };
    };
  };

  performance = {
    byteCompileLua = {
      enable = true;
      plugins = true;

      configs = false;
      luaLib = false;
      initLua = false;
      nvimRuntime = false;
    };
  };
}
