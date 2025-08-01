_: {
  plugins = {
    nvim-tree = {
      enable = true;
      respectBufCwd = true;
      syncRootWithCwd = true;
      updateFocusedFile = {
        enable = true;
        updateRoot = true;
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
