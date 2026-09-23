{
  plugins = {
    colorizer = {
      lazyLoad.settings.event = "DeferredUIEnter";
      enable = true;
      settings = {
        user_default_options.names = false;
        buftypes = ["*" "!prompt" "!popup"];

        filetypes = [
          "*"
          "!css"
          "!scss"
          "!less"
          "!sass"
          "!stylus"
          "!typst"
        ];
      };
    };
  };
}
