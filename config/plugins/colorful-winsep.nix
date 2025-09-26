_: {
  plugins = {
    colorful-winsep = {
      enable = true;
      settings = {
        highlight = "#b8bb26";
        excluded_ft = [ "NvimTree" ];
        border = [
          "━"
          "┃"
          "┏"
          "┓"
          "┗"
          "┛"
        ];
        # highlight = "#7d8618";
        # border = ["─" "│" "┌" "┐" "└" "┘"];
      };
      lazyLoad.settings.event = "WinLeave";
    };
  };
}
