{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config) k;
  inherit (lib.nixvim) mkRaw;
in {
  extraPackages = [
    pkgs.haskellPackages.fast-tags
  ];

  plugins.haskell-tools = {
    enable = true;
    hlsPackageFallback = true;
    settings = {
      tools.repl.prefer = "cabal";
      hls.default_settings.haskell.plugin = {
        importLens.codeLensOn = false;
        class.codeLensOn = false;
        # Off by default in HLS.
        semanticTokens.globalOn = true;
      };
    };
  };

  my.keymaps = let
    ht = "require('haskell-tools')";
  in {
    normal = {
      "<space>hs" = k (mkRaw "${ht}.hoogle.hoogle_signature") "Search signature";
      "<space>he" = k (mkRaw "${ht}.lsp.buf_eval_all") "Eval snippets";
      "<space>hr" = k (mkRaw "${ht}.repl.toggle") "Toggle repl";

      # Replaces haskell-tools' own `ghc` map, which has no description.
      # `:Telescope keymaps` crashes on undescribed maps from byte-compiled
      # plugins. Reading `.repl` loads the module (and its map) first.
      "ghc" = k (mkRaw "${ht}.repl.operator") "Send motion to GHCi repl";
    };
  };
}
