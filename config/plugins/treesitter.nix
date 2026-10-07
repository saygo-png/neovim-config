{
  config,
  lib,
  ...
}: let
  inherit (config) k kr;
  inherit (lib.nixvim) mkRaw;
in {
  performance.combinePlugins.standalonePlugins = ["nvim-treesitter"];

  # https://github.com/nvim-treesitter/nvim-treesitter/issues/7967
  extraFiles."ftplugin/haskell.vim".text = "set nocursorline";

  dependencies.tree-sitter.enable = true;

  my.keymaps = {
    normal."<CR>" =
      k (mkRaw ''
        function()
          local selectable = vim.bo.buftype == ""
            and vim.fn.getcmdwintype() == ""
            and vim.treesitter.get_parser(nil, nil, {error = false}) ~= nil

          if selectable then
            vim.api.nvim_feedkeys("van", "m", false)
          else
            vim.api.nvim_feedkeys(vim.keycode("<CR>"), "n", false)
          end
        end
      '')
      "Select node under cursor";

    visual = {
      "<CR>" = kr "an" "Expand selection to parent node";
      "<BS>" = kr "in" "Shrink selection to child node";
    };
  };

  plugins = {
    treesitter = {
      enable = true;
      folding.enable = true;
      nixvimInjections = true;
      indent.enable = true;
      highlight.enable = true;

      # Upstream guesses whether a top-level binding is a function or a variable
      # from the shape of its type, so `f :: Foo Bar` ends up as @variable while
      # `f :: Foo -> Bar` is @function. Patch the query to treat every top-level
      # definition (and anything with a signature) as a function.
      grammarPackages = let
        inherit (config.plugins.treesitter.package) allGrammars builtGrammars;
        haskell = builtGrammars.haskell.overrideAttrs (old: {
          passthru =
            old.passthru
            // {
              associatedQuery = old.passthru.associatedQuery.overrideAttrs {
                buildCommand = ''
                  mkdir -p $out/queries
                  cp -rL --no-preserve=mode ${old.passthru.associatedQuery}/queries/haskell $out/queries/
                  patch -d $out/queries/haskell -p1 < ${../etc/haskell-highlights.patch}
                '';
              };
            };
        });
      in
        map (g:
          if g == builtGrammars.haskell
          then haskell
          else g)
        allGrammars;
    };
  };
}
