_: {
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
    which-key.settings.spec = [
      {
        __unkeyed = "<leader>op";
        group = "File tree";
        icon = " ";
      }
    ];
  };

  keymaps = [
    {
      key = "<leader>op";
      action = "<cmd>NvimTreeToggle<CR>";
      options.desc = "[o]pen [p]roject";
    }
  ];
}
