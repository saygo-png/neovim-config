{
  config,
  lib,
  ...
}: let
  inherit (config) k;
  inherit (lib.nixvim) mkRaw;
in {
  plugins.spider = {
    enable = true;
    lazyLoad.settings.keys = map (b: b // {mode = ["n" "o" "x"];}) (config.toLazyKeys
      {
        "b" = k (mkRaw "function() require('spider').motion('b') end") "Spider b";
        "e" = k (mkRaw "function() require('spider').motion('e') end") "Spider e";
        "ge" = k (mkRaw "function() require('spider').motion('ge') end") "Spider ge";
        "w" = k (mkRaw "function() require('spider').motion('w') end") "Spider w";
      });
    settings = {
      consistentOperatorPending = true;
      skipInsignificantPunctuation = false;
    };
  };
}
