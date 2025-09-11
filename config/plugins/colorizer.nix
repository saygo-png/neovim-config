_: {
  plugins = {
    colorizer = {
      lazyLoad.settings.event = "DeferredUIEnter";
      enable = true;
      settings = {
        user_default_options.names = false;
        buftypes = ["*" "!prompt" "!popup"];
        fileTypes =
          map (x: {language = x;} // {css = true;}) [
            "css"
            "less"
            "sass"
            "scss"
            "stylus"
          ]
          ++ ["*"];
      };
    };
  };
}
