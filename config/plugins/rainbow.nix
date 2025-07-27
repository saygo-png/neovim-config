{pkgs, ...}: {
  extraPlugins = [pkgs.vimPlugins.rainbow];
  globals = {
    rainbow_active = 1;
    rainbow_conf = {
      guifgs = [
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
