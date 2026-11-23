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

  my.which-keys."<leader>h".group = "Haskell";

  performance.byteCompileLua.excludedPlugins = ["haskell-tools.nvim"];

  my.keymaps.normal = let
    ht = "require('haskell-tools')";
  in {
    "<leader>hs" = k (mkRaw "function() ${ht}.hoogle.hoogle_signature() end") "Search signature";
    "<leader>he" = k (mkRaw "function() ${ht}.lsp.buf_eval_all() end") "Eval snippets";
    "<leader>hr" = k (mkRaw "function() ${ht}.repl.toggle() end") "Toggle repl";
  };
}
