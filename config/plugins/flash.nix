{
  config,
  lib,
  ...
}: {
  plugins.flash = {
    enable = true;
    settings = {
      autojump = true;
      prompt.enabled = false;
    };
    lazyLoad.settings.keys = ["s" "S" "gs"];
  };

  my.keymaps = let
    luaFunc = f: d: config.k (lib.nixvim.mkRaw "function() ${f} end") d;
    keys = {
      "s" = luaFunc "require('flash').remote()" "Flash";
      "S" = luaFunc "require('flash').treesitter_search()" "Flash treesitter search";
      "gs" = luaFunc "require('flash').treesitter()" "Flash treesitter";
    };
  in {
    visual = keys;
    normal = keys;
  };
}
