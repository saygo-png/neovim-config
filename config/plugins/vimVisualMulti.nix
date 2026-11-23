{
  plugins.visual-multi = {
    enable = true;
    lazyLoad.settings.keys = [
      {
        __unkeyed-1 = "<C-n>";
        mode = ["n" "x"];
        desc = "Multi-cursor: find word";
      }
      {
        __unkeyed-1 = "<M-j>";
        desc = "Multi-cursor: add cursor down";
      }
      {
        __unkeyed-1 = "<M-k>";
        desc = "Multi-cursor: add cursor up";
      }
      {
        __unkeyed-1 = "\\";
        mode = ["n" "x"];
        desc = "Multi-cursor leader";
      }
    ];
    settings = {
      leader = ''\'';
      silent_exit = 1;
      skip_empty_lines = 1;
      maps = {
        # "Find Subword Under" = "<C-d>";
        "Add Cursor Down" = "<M-j>";
        "Add Cursor Up" = "<M-k>";
      };
    };
  };
}
