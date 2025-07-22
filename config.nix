_: {
  plugins = {
    lz-n.enable = true;
    telescope = {
      enable = true;
      lazyLoad.settings.cmd = ["Telescope"];
      extensions.fzf-native.enable = true;
    };
    web-devicons.enable = true; # Not needed for reproduction, simply removes a warning
  };
}
