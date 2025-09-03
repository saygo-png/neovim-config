_: {
  plugins.rainbow = {
    enable = true;
    settings = {
      active = 1;
      conf.guifgs = [
        "#fabd2f"
        "#8ec07c"
        "#d3869b"
        "#b8bb26"
        "#fe8019"
        "#83a598"
      ];
    };
  };
  highlightOverride = {
    "@punctuation.bracket".link = "";
    "@variable.parameter.haskell".link = "";
  };
}
