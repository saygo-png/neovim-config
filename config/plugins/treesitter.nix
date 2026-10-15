{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config) k kr;
  inherit (lib.nixvim) mkRaw;
in {
  performance.combinePlugins.standalonePlugins = ["nvim-treesitter"];

  extraConfigLua = "vim.hl.priorities.semantic_tokens = 150";

  # https://github.com/nvim-treesitter/nvim-treesitter/issues/7967
  extraFiles."ftplugin/haskell.vim".text = "set nocursorline";

  # Captures for my theme on top of simple-tree-sitter-haskell's queries:
  # names declared by a type signature (f :: …, f, g :: …)
  extraFiles."queries/haskell/highlights.scm".text = ''
    ; extends

    (signature
      [
        name: (variable) @variable.signature
        names: (binding_list
          (variable) @variable.signature)
      ])
  '';

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
      grammarPackages = let
        inherit (config.plugins.treesitter.package) allGrammars builtGrammars;
        customHaskell = inputs.simple-tree-sitter-haskell.packages.${pkgs.stdenv.hostPlatform.system}.default;
        replaceGrammar = target: replacement:
          map (grammar:
            if grammar == builtGrammars.${target}
            then replacement
            else grammar);
      in
        replaceGrammar "haskell" customHaskell allGrammars;
    };
  };
}
