_: {
  plugins = {
    colorful-winsep = {
      enable = false; # https://github.com/nvim-zh/colorful-winsep.nvim/issues/103
      settings = {
        hi.fg = "#7d8618";
        symbols = ["─" "│" "┌" "┐" "└" "┘"];
      };
      lazyLoad.settings.event = "WinLeave";
    };
  };
}
