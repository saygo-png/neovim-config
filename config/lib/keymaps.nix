# This is the ugly part of the config. I make this ugly so the rest is pretty :).
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

    lk = lib.mkOption {
      default = key: action: desc: {inherit key action;} // {options.desc = desc;};
      readOnly = true;
      type = lib.types.anything;
      description = "Make keybind for lsp module";
    };

    kns = lib.mkOption {
      readOnly = true;
      type = lib.types.anything;
      description = "Make keybind not silent";
      default = action: desc: {inherit action desc;} // {silent = false;};
    };

    wk = lib.mkOption {
      readOnly = true;
      description = "Make which-key registration";
      default = group: icon: {inherit icon group;};
    };

    my = {
      which-keys = lib.mkOption {
        default = {};
        description = "Registrations for which-key";
        type = with lib.types; attrsOf (attrsOf str);
      };
      keymaps = let
        mkKeymapOption = mn: {
          ${mn} = lib.mkOption {
            default = {};
            description = "Set keybindings for ${mn} mode";
            type = with lib.types; attrsOf (attrsOf (oneOf [str bool (attrsOf str)]));
          };
        };
      in
        lib.mergeAttrsList (map mkKeymapOption [
          "normal"
          "visual"
          "insertAndCommand"
        ]);
    };
  };

  config = {
    plugins.which-key.settings.spec = lib.mapAttrsToList (key: v: {__unkeyed = key;} // v) config.my.which-keys;
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
      inherit (config.my.keymaps) normal visual insertAndCommand;
    in
      lib.nixvim.keymaps.mkKeymaps sharedOpts
      (lib.flatten [
        (toKeymapList "n" normal)
        (toKeymapList "v" visual)
        (toKeymapList ["i" "c"] insertAndCommand)
      ]);
  };
}
