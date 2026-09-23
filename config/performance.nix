{
  performance = {
    combinePlugins.enable = true;
    byteCompileLua = {
      enable = true;
      configs = true;
      luaLib = true;
      initLua = true;
      plugins = true;
      nvimRuntime = true;
    };
  };

  luaLoader.enable = true;

  enableMan = false; # Faster eval
}
