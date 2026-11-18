{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config) k wk;
  inherit (lib.nixvim) mkRaw;
  send = mkRaw "function() require('shhell').send_from_buffer() end";

  # Type-checks the plugin's annotations against the Neovim it runs in. Strict,
  # so everything needs a known type.
  luarc = pkgs.writeText "luarc.json" (builtins.toJSON {
    "runtime.version" = "LuaJIT";
    "workspace.library" = ["${config.package}/share/nvim/runtime/lua"];
    "workspace.checkThirdParty" = false;
    "diagnostics.groupFileStatus" = {
      strict = "Opened";
      strong = "Opened";
    };
    "diagnostics.groupSeverity" = {
      strict = "Warning";
      strong = "Warning";
    };
  });
in {
  # shhell, the GHCi shell from the NixOS config, in a terminal tab with a
  # prompt below it. See shhell-nvim/README.md.
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "shhell.nvim";
      src = lib.fileset.toSource {
        root = ./shhell-nvim;
        fileset = ./shhell-nvim/lua;
      };
      nativeBuildInputs = [pkgs.lua-language-server];
      preInstall = ''
        lua-language-server --check=lua --checklevel=Information \
          --configpath=${luarc} --logpath="$TMPDIR/luals" --metapath="$TMPDIR/luals-meta"
      '';
    })
  ];

  extraConfigLua = ''require("shhell").setup()'';

  my = {
    which-keys."<leader>s" = wk "Shhell" " ";
    keymaps = {
      normal = {
        "<leader>sh" = k "<cmd>Shhell<CR>" "[sh]hell";
        "<leader>ss" = k send "[s]hell: [s]end the line";
      };
      visual."<leader>ss" = k send "[s]hell: [s]end the selection";
    };
  };
}
