_: {
  plugins = {
    oil = {
      enable = true;
      lazyLoad.settings = {
        cmd = "Oil";
        event = "VimEnter";
      };
      settings.defaultFileExplorer = true;
    };

    which-key.settings.spec = [
      {
        __unkeyed = "<leader>f";
        group = "File browser";
        icon = " ";
      }
    ];
  };

  performance.combinePlugins.standalonePlugins = ["oil.nvim"];

  keymaps = [
    {
      key = "<leader>f";
      action = "<cmd>Oil<CR>";
      options.desc = "[f]ile browser";
    }
  ];
}
