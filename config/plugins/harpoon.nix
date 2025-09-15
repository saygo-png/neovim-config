{
  config,
  lib,
  ...
}: {
  plugins = {
    harpoon = {
      enable = true;
      luaConfig.post = ''
        local harpoon = require("harpoon")
        local harpoon_extensions = require("harpoon.extensions")
        harpoon:extend(harpoon_extensions.builtins.highlight_current_file())
      '';
    };
  };

  my = let
    inherit (config) k wk;
    hFunc = f: d: k (lib.nixvim.mkRaw "function() require'harpoon'${f} end") d;
  in {
    keymaps.normal = {
      "<leader>ha" = hFunc ":list():add()" "Add file to harpoon list";
      "<leader>hm" = hFunc ".ui:toggle_quick_menu(require'harpoon':list())" "Harpoon menu";
      "<leader>hn" = hFunc ":list():next()" "Harpoon next";
      "<leader>hp" = hFunc ":list():prev()" "Harpoon previous";
      "<C-h>" = hFunc ":list():select(1)" "Harpoon 1";
      "<C-j>" = hFunc ":list():select(2)" "Harpoon 2";
      "<C-k>" = hFunc ":list():select(3)" "Harpoon 3";
      "<C-l>" = hFunc ":list():select(4)" "Harpoon 4";
    };

    which-keys = {
      "<leader>h" = wk "Harpoon" "󱢓";
      "<leader>ha" = wk "Add file" "󱢓";
      "<leader>hm" = wk "File menu" "󱢓";
      "<leader>hc" = wk "Command menu" "󱢓";
      "<leader>hn" = wk "Next file" "󱢓";
      "<leader>hp" = wk "Previous file" "󱢓";
    };
  };
}
