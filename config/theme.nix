{
  lib,
  pkgs,
  ...
}: {
  colorschemes.base16.enable = lib.mkForce false;
  impureRtp = true; # Needed for better_performance setting

  highlightOverride = {
    WinBar.bg = "NONE";
    WinBarNC.bg = "NONE"; # not focused;
    NormalFloat.bg = "NONE";

    noCursor.blend = 100;
    ModeMsg.fg = "#7d8618";
    MsgArea.fg = "#7d8618";
    FloatBorder.fg = "#7d8618";
    MiniIndentscopeSymbol.fg = "#3c3836"; # Gray indentline
    Normal.fg = "#d5c4a1";
    TSString.link = "Green";
    TelescopeSelection.link = "CursorLine";
    TelescopeSelectionCaret.link = "TelescopePromptPrefix";
    TelescopePromptCounter.fg = "#504945";
    LineNr.fg = "#7c6f64";
    CursorLineNr = {
      fg = "#7d8618";
      bg = "#3c3836"; # Gray numberline
    };
  };

  colorschemes.gruvbox-material = {
    enable = true;
    settings = {
      foreground = "original";
      background = "soft";
      transparent_background = 2;
      enable_bold = 0;
      enable_italic = 1;
      statusline_style = "original";
      better_performance = 1;
    };
  };

  # Hide end of line tildes.
  extraConfigLua = ''vim.opt.fillchars:append({ eob = " " })'';

  performance.combinePlugins.standalonePlugins = [
    pkgs.vimPlugins.gruvbox-material
  ];
}
