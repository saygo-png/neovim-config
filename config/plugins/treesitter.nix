{
  config,
  lib,
  pkgs,
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

      # Use our own fork of the haskell highlights query, see the header of
      # ../etc/haskell-highlights.scm for what changed from upstream.
      grammarPackages = let
        inherit (config.plugins.treesitter.package) allGrammars builtGrammars;
        highlights = ../etc/haskell-highlights.scm;
        checkQuery = pkgs.writeText "check-haskell-highlights.lua" ''
          vim.treesitter.language.add("haskell", {path = "${builtGrammars.haskell}/parser"})
          vim.treesitter.query.parse("haskell", io.open("${highlights}"):read("*a"))
        '';
        haskell = builtGrammars.haskell.overrideAttrs (old: {
          passthru =
            old.passthru
            // {
              associatedQuery = old.passthru.associatedQuery.overrideAttrs {
                buildCommand = ''
                  # Fail the build if the forked query no longer fits the grammar
                  HOME=$TMPDIR ${lib.getExe pkgs.neovim-unwrapped} --clean -l ${checkQuery}

                  mkdir -p $out/queries
                  cp -rL --no-preserve=mode ${old.passthru.associatedQuery}/queries/haskell $out/queries/
                  cp ${highlights} $out/queries/haskell/highlights.scm
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
