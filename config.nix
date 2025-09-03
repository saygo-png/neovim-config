_: {
  plugins = {
    web-devicons.enable = true; # disable warn

    telescope.enable = true;
    faster.enable = true;
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
