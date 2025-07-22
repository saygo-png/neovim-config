_: {
  plugins.flash = {
    enable = true;
    settings.autojump = true;
    lazyLoad.settings.keys = ["s" "S" "gs"];
  };

  keymaps = let
    nWrapFunc = s: "function() ${s} end";
  in [
    {
      key = "s";
      action.__raw = nWrapFunc ''require("flash").remote()'';
      options.desc = "Flash";
    }
    {
      key = "S";
      action.__raw = nWrapFunc ''require("flash").treesitter_search()'';
      options.desc = "Flash treesitter";
    }
    {
      key = "gs";
      action.__raw = nWrapFunc ''require("flash").treesitter()'';
      options.desc = "Flash treesitter";
    }
  ];
}
