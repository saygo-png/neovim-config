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

  # nil sends function names as properties/variables, which would hide the
  # green of definitions and calls, so those go above semantic tokens (150).
  extraFiles."queries/nix/highlights.scm".text = ''
    ; extends

    ((binding
      attrpath: (attrpath
        attr: (identifier) @function .)
      expression: (function_expression))
      (#set! priority 155))

    ((apply_expression
      function: (variable_expression
        name: (identifier) @function.call))
      (#set! priority 155))

    ((apply_expression
      function: (select_expression
        attrpath: (attrpath
          attr: (identifier) @function.call .)))
      (#set! priority 155))

    ; inherit x; defines attribute x (nil: property)
    (inherited_attrs
      attr: (identifier) @variable.member)

    ; `builtins` is a namespace, like a Haskell module qualifier
    ((variable_expression
      name: (identifier) @module)
      (#eq? @module "builtins")
      (#set! priority 101))
  '';

  # Captures for my theme on top of simple-tree-sitter-haskell's queries.
  # Where the syntax is enough to tell, they match HLS's semantic token kinds,
  # so colours don't shift when HLS attaches (see theme.nix).
  extraFiles."queries/haskell/highlights.scm".text = ''
    ; extends

    ; Names declared by a type signature (f :: …, f, g :: …)
    (signature
      [
        name: (variable) @variable.signature
        names: (binding_list
          (variable) @variable.signature)
      ])

    ; Function definitions (HLS: function)
    (function
      name: (variable) @function)

    ; Type families, including associated types and their instances
    ; (HLS: interface). Data families are ordinary types to HLS.
    ; Priority 101 to beat the plain (name) @type capture.
    ((type_family
      name: (name) @type.family)
      (#set! priority 101))

    ((type_family
      closed_family: (equations
        equation: (equation
          name: (name) @type.family)))
      (#set! priority 101))

    ((type_instance
      name: (name) @type.family)
      (#set! priority 101))

    ; Haddock comments: GHC resolves identifiers in them, so HLS sends
    ; semantic tokens there. Draw the comment over them (they're 150-152).
    ((haddock) @comment.documentation
      (#set! priority 160))

    ; Built-in syntax that the base queries call operators. Real operators
    ; ((operator) nodes: . <$> >>= +) stay @operator.
    ([
      "::"
      "."
      (all_names)
    ] @punctuation.special
      (#set! priority 101))

    ; Names used infix with backticks stay operators (a `elem` b) even with
    ; HLS, which calls them functions. Semantic tokens are priority 150.
    ((infix_id
      [
        (variable) @operator
        (constructor) @operator
        (qualified
          id: (_) @operator)
      ])
      (#set! priority 155))

    ; Pattern synonym declarations (HLS: macro), over (constructor)
    ((pattern_synonym
      [
        (signature
          synonym: (constructor) @function.macro)
        (equation
          synonym: (constructor) @function.macro)
      ])
      (#set! priority 101))
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
        grammar = config.plugins.treesitter.package.builtGrammars;
      in [
        inputs.simple-tree-sitter-haskell.packages.${pkgs.stdenv.hostPlatform.system}.default

        grammar.bash
        grammar.css
        grammar.fish
        grammar.graphql
        grammar.html
        grammar.javascript
        grammar.json
        grammar.lua
        grammar.markdown
        grammar.markdown_inline
        grammar.nix
        grammar.python
        grammar.scss
        grammar.tsx
        grammar.typescript
        grammar.typst

        # Used by Neovim itself and in comments.
        grammar.comment
        grammar.luadoc
        grammar.luap
        grammar.printf
        grammar.query
        grammar.regex
        grammar.vim
        grammar.vimdoc

        # Config files and git.
        grammar.csv
        grammar.diff
        grammar.dockerfile
        grammar.git_config
        grammar.git_rebase
        grammar.gitattributes
        grammar.gitcommit
        grammar.gitignore
        grammar.ini
        grammar.jsdoc
        grammar.json5
        grammar.kdl
        grammar.make
        grammar.rasi
        grammar.sql
        grammar.ssh_config
        grammar.toml
        grammar.xml
        grammar.yaml

        # Common languages.
        grammar.c
        grammar.cpp
        grammar.go
        grammar.rust
      ];
    };
  };
}
