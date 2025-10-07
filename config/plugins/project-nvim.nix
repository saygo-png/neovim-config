{
  plugins = {
    project-nvim = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        silent_chdir = true;
        exclude_dirs = ["~/nixos/resources/haskell/*"];
      };
    };
  };
}
