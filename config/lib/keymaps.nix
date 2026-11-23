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
      default = key: action: desc:
        {inherit key action;}
        // {
          mode = "n";
          options.desc = desc;
        };
      readOnly = true;
      type = lib.types.anything;
      description = "Make keybind for lsp module";
    };

    toLazyKeys = lib.mkOption {
      readOnly = true;
      type = lib.types.anything;
      description = "Convert keybinds to lz-n spec";
      default = binds: let
        toLazyKey = bind: {
          __unkeyed-1 = bind.name;
          __unkeyed-2 = bind.value.action;
          desc = bind.value.desc;
        };
      in
        map toLazyKey (lib.attrsToList binds);
    };

    kns = lib.mkOption {
      readOnly = true;
      type = lib.types.anything;
      description = "Make keybind not silent";
      default = action: desc: {inherit action desc;} // {silent = false;};
    };

    kr = lib.mkOption {
      readOnly = true;
      type = lib.types.anything;
      description = "Make keybind that recurses into other mappings";
      default = action: desc: {inherit action desc;} // {remap = true;};
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
      keymaps = lib.genAttrs ["normal" "visual" "insertAndCommand" "terminal"] (mn:
        lib.mkOption {
          default = {};
          description = "Set keybindings for ${mn} mode";
          type = with lib.types; attrsOf (attrsOf (oneOf [str bool (attrsOf str)]));
        });
    };
  };

  config = {
    plugins.which-key.settings.spec = lib.mapAttrsToList (key: v: {__unkeyed = key;} // v) config.my.which-keys;
    keymaps = let
      toKeymapList = mode:
        lib.mapAttrsToList (
          key: spec: {
            inherit key mode;
            inherit (spec) action;
            options = removeAttrs spec ["action"];
          }
        );

      sharedOpts = {options.silent = true;};
      inherit (config.my.keymaps) normal visual insertAndCommand terminal;
    in
      lib.nixvim.keymaps.mkKeymaps sharedOpts
      (lib.flatten [
        (toKeymapList "n" normal)
        (toKeymapList "x" visual)
        (toKeymapList ["i" "c"] insertAndCommand)
        (toKeymapList "t" terminal)
      ]);
  };
}
