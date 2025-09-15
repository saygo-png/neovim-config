{lib, ...}: {
  highlightOverride.statusline.fg = "#7d8618";
  plugins.lualine = {
    enable = true;
    settings = let
      inherit (lib) mapAttrs mapAttrs' nameValuePair boolToString toUpper genAttrs;

      rnm = n: nameValuePair (ite (n == "module") "__unkeyed" n);
      ite = b: t: f: ({true = t;} // {false = f;}).${boolToString b};
      padding = mapAttrs (_: lib.mkDefault) ({left = 0;} // {right = 0;});
      p = mapAttrs (_: v: ite (v == []) lib.nixvim.emptyTable (rnmAndPad v));
      rnmAndPad = map (y: lib.mkMerge [(mapAttrs' rnm y) {inherit padding;}]);

      diagnostics = {
        module = "diagnostics";
        symbols = genAttrs [
          "error"
          "warn"
          "info"
          "hint"
        ] (n: toUpper n + " ");
      };

      filename = {
        module = "%t";
        padding.right = 1;
      };

      gitBranch = {
        module = "branch";
        icon = "branch";
        color.fg = "#b8bb26";
      };

      gitDiff.module = "diff";
      filePosition.module = "progress";
    in {
      sections = p {
        # A  B  C                X  Y  Z
        lualine_a = [diagnostics filename];
        lualine_b = [gitBranch gitDiff];
        lualine_c = [];

        lualine_x = [];
        lualine_y = [filePosition];
        lualine_z = [];
      };

      options =
        {
          globalstatus = true;
          icons_enable = false;
          theme = genAttrs [
            "normal"
            "insert"
            "visual"
            "replace"
            "command"
            "inactive"
          ] (_: {a.fg = "none";} // {c.bg = "none";});
        }
        // genAttrs ["component_separators" "section_separators"]
        (_: {left = " ";} // {right = " ";});
    };
  };
}
