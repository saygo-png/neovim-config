{
  config,
  lib,
  ...
}: {
  options = {
    k = lib.mkOption {
      default = action: desc: {inherit action desc;};
      readOnly = true;
      type = lib.types.anything;
      description = "Make keybind";
    };

    kns = lib.mkOption {
      default = action: desc: {
        inherit action desc;
        silent = false;
      };
      readOnly = true;
      type = lib.types.anything;
      description = "Make keybind not silent";
    };

    my.keymaps = let
      mkKeymapOption = mn: {
        ${mn} = lib.mkOption {
          default = {};
          description = ''Set keybindings for ${mn} mode'';
          type = with lib.types; attrsOf (attrsOf (either str bool));
        };
      };
    in
      lib.mergeAttrsList (map mkKeymapOption [
        "normal"
        "visual"
      ]);
  };

  config = {
    keymaps = let
      toKeymapList = mode:
        lib.mapAttrsToList (
          key: actionAndDesc:
            {
              inherit key mode;
              inherit (actionAndDesc) action;
            }
            // lib.optionalAttrs (actionAndDesc.desc != null) {
              options.desc = actionAndDesc.desc;
            }
            // lib.optionalAttrs (actionAndDesc.silent or null != null) {
              options.silent = actionAndDesc.silent;
            }
        );

      sharedOpts = {options.silent = true;};
      inherit (config.my.keymaps) normal visual;
    in
      lib.nixvim.keymaps.mkKeymaps sharedOpts
      (lib.flatten [
        (toKeymapList "n" normal)
        (toKeymapList "v" visual)
      ]);
  };
}
