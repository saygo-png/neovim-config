_: {
  highlightOverride = {
    WinBar.bg = "NONE";
    WinBarNC.bg = "NONE"; # not focused

    Normal.fg = "#d5c4a1";
    "@constructor".link = "GruvboxPurple";
    "@punctuation.special".link = "GruvboxFg1";
    "@punctuation.delimiter".link = "GruvboxFg1";
    DiagnosticDeprecated.link = "GruvboxAquaUnderline";
    DiagnosticUnderlineInfo.underline = false;
    DiagnosticUnderlineHint.underline = false;
    DiagnosticUnderlineWarn.underline = false;
  };

  colorschemes.gruvbox = {
    enable = true;
    lazyLoad.enable = true;
    settings = {
      bold = false;
      undercurl = true;
      underline = true;
      strikethrough = false;
      transparent_mode = true;
    };
  };
}
