{
  config,
  lib,
  ...
}: let
  inherit (lib) mapAttrs;
  inherit (lib.nixvim) mkRaw listToUnkeyedAttrs;
in {
  # Needed for blink to access friendly-snippets
  performance.combinePlugins.standalonePlugins = ["friendly-snippets"];

  my.keymaps.insertAndCommand = {
    "<C-x>" = config.k "<C-x><C-o>" "Autocomplete";
    "<Tab>" = config.k "" "";
  };

  plugins = {
    friendly-snippets.enable = true;

    lspkind = {
      enable = true;
      cmp.enable = false;
      lazyLoad.settings.event = ["InsertEnter" "CmdlineEnter"];
    };

    blink-cmp = {
      enable = true;
      lazyLoad.settings.event = ["InsertEnter" "CmdlineEnter"];
      settings = {
        cmdline.keymap.preset = "inherit";
        sources.default = ["lsp" "snippets" "path"];
        keymap =
          {
            preset = "super-tab";
            "<Tab>" = listToUnkeyedAttrs [
              (mkRaw ''
                function(cmp)
                  cmp.show()
                  if cmp.snippet_active() then return cmp.accept()
                  else return cmp.select_and_accept() end
                end
              '')
              "fallback"
            ];
          }
          // mapAttrs (_: v: [v] ++ ["fallback"]) {
            "<C-j>" = "select_next";
            "<C-k>" = "select_prev";
            "<CR>" = "accept";
          };
        completion = {
          documentation.auto_show = true;
          menu = {
            auto_show = false;
            border = "none";
            draw.components.kind_icon.text = mkRaw ''
              function(ctx)
                return require('lspkind').symbolic(ctx.kind, { mode = 'symbol' })
              end,
            '';
          };
        };
      };
    };
  };
}
