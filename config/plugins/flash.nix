{
  config,
  lib,
  ...
}: let
  inherit (config) k;
  inherit (lib.nixvim) mkRaw;
in {
  plugins.flash = {
    enable = true;
    settings = {
      autojump = true;
      prompt.enabled = false;
    };
    lazyLoad.settings.keys = map (b: b // {mode = ["v" "n"];}) (config.toLazyKeys
      {
        "s" = k (mkRaw "function() require('flash').remote() end") "Flash";
        "S" = k (mkRaw "function() require('flash').treesitter_search() end") "Flash treesitter search";
        "gs" = k (mkRaw "function() require('flash').treesitter() end") "Flash treesitter";
      });
  };
}
