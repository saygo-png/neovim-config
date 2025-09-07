_: {
  highlightOverride = {
    WinBar.bg = "NONE";
    WinBarNC.bg = "NONE"; # not focused;
    NormalFloat.bg = "NONE";

    Normal.fg = "#d5c4a1";
    TSString.link = "Green";
    TelescopeSelection.link = "CursorLine";
    TelescopeSelectionCaret.link = "TelescopePromptPrefix";
    TelescopePromptCounter.fg = "#504945";
    LineNr.fg = "#7c6f64";
  };

  colorschemes.gruvbox-material = {
    enable = true;
    settings = {
      foreground = "original";
      background = "soft";
      transparent_background = 2;
      enable_bold = 0;
      enable_italic = 1;
      statusline_style = "original";
      better_performance = 1;
    };
  };
}
