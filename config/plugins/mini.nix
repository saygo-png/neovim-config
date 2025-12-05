{pkgs, ...}: {
  plugins.mini = {
    enable = true;
    lazyLoad.settings.event = "DeferredUIEnter";
    modules.indentscope = {
      symbol = "│";
      draw = {
        delay = 0;
        priority = 2;
        animation.__raw = "require('mini.indentscope').gen_animation.none()";
      };
      options = {
        border = "top";
        try_as_border = true;
        indent_at_cursor = true;
      };
    };
  };

  performance.combinePlugins.standalonePlugins = [
    pkgs.vimPlugins.mini-nvim
  ];
}
