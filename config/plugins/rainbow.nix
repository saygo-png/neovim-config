{
  plugins.rainbow = {
    enable = true;
    settings = {
      active = 1;
      conf.guifgs = [
        "#bdae93"
        "#A9B665"
        "#baa16a"
      ];
    };
  };
  highlightOverride = {
    "@punctuation.bracket".link = "";
    "@variable.parameter.haskell".link = "";
  };
}
