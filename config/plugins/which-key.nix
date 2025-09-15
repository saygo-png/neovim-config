_: {
  plugins = {
    which-key = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        delay = 1000;
        win.border = "single";
        spec = let
          nRegister = key: text: icon: {
            __unkeyed = key;
            group = text;
            inherit icon;
          };
        in [
          (nRegister "<leader>r" "Re" " ")
          (nRegister "<leader>q" "Quit" "󰩈 ")
          (nRegister "<leader>S" "Sort by length" "󰒼 ")
        ];
      };
    };
  };
}
