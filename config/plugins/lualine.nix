_: {
  plugins.lualine = {
    enable = true;
    settings = {
      options = let
        transparent.a.fg = "none";
        transparent.c.bg = "none";
        separators.left = " ";
        separators.right = " ";
      in {
        globalstatus = true;
        icons_enable = false;
        theme = {
          normal = transparent;
          insert = transparent;
          visual = transparent;
          replace = transparent;
          command = transparent;
          inactive = transparent;
        };
        component_separators = separators;
        section_separators = separators;
      };

      # ---------------------------------------------------
      # | A | B | C                             X | Y | Z |
      # ---------------------------------------------------
      sections = let
        padding = {
          left = 0;
          right = 0;
        };
      in {
        lualine_a = [
          {
            __unkeyed = "diagnostics";
            symbols = {
              error = "ERROR ";
              warn = "WARN ";
              info = "INFO ";
              hint = "HINT ";
            };
            inherit padding;
          }
          {
            __unkeyed = "%t";
            inherit padding;
          }
        ];
        lualine_b = [
          {
            __unkeyed = "branch";
            icon = " branch";
            color = {fg = "#b8bb26";};
            inherit padding;
          }
          {
            __unkeyed = "diff";
            inherit padding;
          }
        ];
        lualine_c.__empty = [];

        lualine_x.__empty = [];
        lualine_y = [
          {
            __unkeyed = "progress";
            inherit padding;
          }
        ];
        lualine_z.__empty = [];
      };
    };
  };

  highlightOverride = {
    statusline.bg = "NONE";
    statusline.fg = "#7d8618";
  };
}
