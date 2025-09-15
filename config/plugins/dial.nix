{
  config,
  lib,
  ...
}: let
  inherit (config) k;
  inherit (lib.nixvim) mkRaw;
in {
  plugins.dial = {
    enable = true;
    lazyLoad.settings.event = "DeferredUIEnter";
    luaConfig.post = ''
      local augend = require("dial.augend")
      require("dial.config").augends:register_group{
        default = {
          augend.constant.alias.alpha,
          augend.constant.alias.Alpha,
          augend.constant.alias.bool,
          augend.date.alias["%-d.%-m."],
          augend.date.alias["%d.%m."],
          augend.date.alias["%d/%m/%y"],
          augend.date.alias["%d/%m/%Y"],
          augend.date.alias["%H:%M"],
          augend.date.alias["%H:%M:%S"],
          augend.date.alias["%-m/%-d"],
          augend.date.alias["%m/%d"],
          augend.date.alias["%m/%d/%y"],
          augend.date.alias["%m/%d/%Y"],
          augend.date.alias["%Y/%m/%d"],
          augend.integer.alias.binary,
          augend.integer.alias.decimal,
          augend.integer.alias.decimal_int,
          augend.integer.alias.hex,
          augend.integer.alias.octal,
          augend.semver.alias.semver,
        },
        typescript = {
          augend.constant.new{ elements = {"let", "const"} },
        },
      }
    '';
  };
  my.keymaps = {
    normal = {
      "<C-a>" = k (mkRaw "function() require('dial.map').manipulate('increment', 'normal') end") "Increment";
      "<C-x>" = k (mkRaw "function() require('dial.map').manipulate('decrement', 'normal') end") "Decrement";
      "g<C-a>" = k (mkRaw "function() require('dial.map').manipulate('increment', 'gnormal') end") "Increment";
      "g<C-x>" = k (mkRaw "function() require('dial.map').manipulate('decrement', 'gnormal') end") "Decrement";
    };
    visual = {
      "<C-a>" = k (mkRaw "function() require('dial.map').manipulate('increment', 'visual') end") "Increment";
      "<C-x>" = k (mkRaw "function() require('dial.map').manipulate('decrement', 'visual') end") "Decrement";
      "g<C-a>" = k (mkRaw "function() require('dial.map').manipulate('increment', 'gvisual') end") "Increment";
      "g<C-x>" = k (mkRaw "function() require('dial.map').manipulate('decrement', 'gvisual') end") "Decrement";
    };
  };
}
