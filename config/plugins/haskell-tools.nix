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
    pkgs.haskellPackages.hoogle
  ];

  plugins.haskell-tools = {
    enable = true;
    hlsPackageFallback = true;
    settings = {
      tools.repl.prefer = "cabal";
    };
  };

  my.keymaps = let
    ht = "require('haskell-tools')";
  in {
    normal = {
      "<space>l" = k (mkRaw "vim.lsp.codelens.run") "Run code lens";
      "<space>hs" = k (mkRaw "${ht}.hoogle.hoogle_signature") "Search signature";
      "<space>he" = k (mkRaw "${ht}.lsp.buf_eval_all") "Eval snippets";
      "<space>hr" = k (mkRaw "${ht}.repl.toggle") "Toggle repl";
    };
  };
}
