_: {
  extraConfigLua = ''
    vim.keymap.set("i", "<C-x>", "<C-x><C-o>", { desc = "Autocomplete" })
  '';

  plugins = {
    lspkind = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      cmp.enable = true;
    };

    friendly-snippets.enable = true;

    luasnip = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        enable_autosnippets = true;
        store_selection_keys = "<Tab>";
      };
    };

    cmp = {
      enable = true;
      autoEnableSources = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        autocomplete = true;
        sources = [{name = "nvim_lsp";}];
        performance = {
          debounce = 200;
          throttle = 200;
          maxViewEntries = 5;
          fetchingTimeout = 100;
        };
        snippet.expand = ''
          function(args)
            require('luasnip').lsp_expand(args.body)
          end
        '';
        mapping = {
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<C-j>" = "cmp.mapping.select_next_item()";
          "<C-k>" = "cmp.mapping.select_prev_item()";
          "<C-e>" = "cmp.mapping.abort()";
          "<C-b>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<CR>" = "cmp.mapping.confirm({ select = false })";
          "<S-CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
        };

        window = {
          completion.scrollbar = true;
          documentation.border = "single";
        };
      };
    };
  };
}
