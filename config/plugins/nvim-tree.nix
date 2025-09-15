{config, ...}: let
  inherit (config) k wk;
in {
  plugins = {
    nvim-tree = {
      enable = true;
      lazyLoad.settings.cmd = [
        "NvimTreeClipboard"
        "NvimTreeClose"
        "NvimTreeCollapse"
        "NvimTreeCollapseKeepBuffers"
        "NvimTreeFindFile"
        "NvimTreeFindFileToggle"
        "NvimTreeFocus"
        "NvimTreeHiTest"
        "NvimTreeOpen"
        "NvimTreeRefresh"
        "NvimTreeResize"
        "NvimTreeToggle"
      ];
      settings = {
        respect_buf_cwd = true;
        sync_root_with_cwd = true;
        update_focused_file = {
          enable = true;
          update_root = true;
        };
      };
    };
  };

  my = {
    which-keys."<leader>op" = wk "File tree" " ";
    keymaps.normal."<leader>op" = k "<cmd>NvimTreeToggle<CR>" "[o]pen [p]roject";
  };
}
