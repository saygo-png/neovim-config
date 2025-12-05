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

  opts = {
    lazyredraw = true;
    regexpengine = 1;
  };

  extraConfigLua = "vim.cmd('syntax sync minlines=256')";
}
