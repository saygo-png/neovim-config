{lib, ...}: let
  inherit (lib.nixvim) mkRaw;
  palette = color: mkRaw "require('gruvbox').palette.${color}";
  italic = color: {
    fg = palette color;
    italic = true;
  };
  bold = color: {
    fg = palette color;
    bold = true;
  };
in {
  colorschemes.base16.enable = lib.mkForce false;

  highlightOverride = {
    WinBar.bg = "NONE";
    WinBarNC.bg = "NONE"; # not focused;
    NormalFloat.bg = "NONE";
    StatusLineNC.bg = "NONE";

    ModeMsg.fg = "#7d8618";
    MsgArea.fg = "#7d8618";
    FloatBorder.fg = "#7d8618";
    MiniIndentscopeSymbol.fg = "#3c3836"; # Gray indentline
    Normal.fg = "#d5c4a1";
    TelescopeSelection.link = "CursorLine";
    TelescopeSelectionCaret.link = "TelescopePromptPrefix";
    TelescopePromptPrefix = bold "bright_green";
    TelescopeMatching.link = "BlinkCmpLabelMatch"; # Same as completion matches
    TelescopePromptCounter.fg = "#504945";
    LineNr.fg = "#7c6f64";
    CursorLineNr = {
      fg = "#7d8618";
      bg = "#3c3836"; # Gray numberline
    };

    # Strings should be aqua
    "@string".link = "GruvboxAqua";
    "@lsp.type.string".link = "GruvboxAqua";

    # Completion menu: gray selection, bold green matches
    PmenuSel = {
      fg = "#504945";
      bg = "#a89984";
    };
    BlinkCmpLabel.link = ""; # Inherit the menu/selection foreground
    BlinkCmpLabelMatch = bold "bright_green";

    GitSignsChange.link = "GruvboxBlue";
    GitSignsCurrentLineBlame.link = "GruvboxGray";

    # Import keywords red like other keywords (gruvbox.nvim: Include, aqua)
    "@keyword.import".link = "Keyword";

    # Nix coloured like Haskell where it maps.
    "@punctuation.delimiter.nix".link = "@module.haskell";
    "@variable.nix".link = "";
    "@lsp.type.variable.nix".link = ""; # nil: let-bound names, hides calls
    "@variable.parameter.nix".link = ""; # Arguments Normal, like variables
    "@lsp.type.parameter.nix".link = "";
    "@variable.parameter.builtin.nix".link = "@module.haskell"; # ...
    "@function.builtin.nix".link = "Function"; # nil: function, green
    "@keyword.import.nix".link = "Function"; # import is a builtin function
    "@constant.builtin.nix".link = "Constant"; # null
    "@module.nix".link = "@module.haskell"; # builtins
    "@lsp.type.struct.nix".link = "@module.nix"; # nil: builtins
    "@number.nix".link = "GruvboxAqua";
    "@number.float.nix".link = "GruvboxAqua";
    "@lsp.type.number.nix".link = "@number.nix";
    "@string.special.path.nix" = {
      fg = palette "bright_aqua";
      underline = true;
    };

    # Haskell. HLS semantic tokens keep gruvbox.nvim's colours.

    # Module names (Map.Map, imports) dimmer than Normal, they rarely matter.
    "@module.haskell".fg = "#a89984";
    "@lsp.type.namespace.haskell".link = "@module.haskell";

    # Delimiters (, ;) and built-in syntax (:: -> = | <- \ => @) in the same
    # dim colour, gruvbox.nvim makes them orange like real operators.
    "@punctuation.delimiter.haskell".link = "@module.haskell";
    "@punctuation.special.haskell".link = "@module.haskell";

    # Number and character literals aqua like strings, so purple is only
    # data constructors.
    "@number.haskell".link = "GruvboxAqua";
    "@number.float.haskell".link = "GruvboxAqua";
    "@character.haskell".link = "GruvboxAqua";

    # Types (HLS: enum = data/newtype, class, type = synonym) yellow italic.
    "@type.haskell" = italic "bright_yellow";
    "@lsp.type.enum.haskell".link = "@type.haskell";
    "@lsp.type.class.haskell".link = "@type.haskell";
    "@lsp.type.type.haskell".link = "@type.haskell";

    # Type families (HLS: interface) orange italic.
    "@lsp.type.interface.haskell" = italic "bright_orange";
    "@type.family.haskell".link = "@lsp.type.interface.haskell";

    # Data constructors (HLS: enumMember) purple; treesitter makes them orange.
    "@constructor.haskell".link = "Constant";

    # Plain variables (HLS: variable) keep the Normal colour, as without HLS.
    "@lsp.type.variable.haskell".link = "";

    # Plain type variables, HLS colours them like types otherwise
    "@lsp.type.typeParameter.haskell".link = "";
    "@variable.signature.haskell".link = "GruvboxGreen";
    "@type.parameter.haskell".link = "";
  };

  colorschemes.gruvbox = {
    enable = true;
    settings = {
      contrast = "soft";
      transparent_mode = true;
      bold = false;
      italic = {
        strings = false;
        emphasis = true;
        comments = true;
        operators = false;
        folds = true;
      };
    };
  };

  # Hide end of line tildes.
  opts.fillchars.eob = " ";
}
