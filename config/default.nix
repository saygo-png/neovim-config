{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./neovide.nix
    ./statusline.nix
    #
    ./plugins
    ./plugins/oil.nix
    ./plugins/dial.nix
    ./plugins/flash.nix
    ./plugins/spider.nix
    ./plugins/gruvbox.nix
    ./plugins/harpoon.nix
    ./plugins/rainbow.nix
    ./plugins/telescope.nix
    ./plugins/nvim-tree.nix
    ./plugins/treesitter.nix
    ./plugins/vimVisualMulti.nix
    #
    ./plugins/ide/lsp.nix
    ./plugins/ide/linting.nix
    ./plugins/ide/formatting.nix
  ];

  performance = {
    byteCompileLua = {
      enable = true;
      configs = true;
      luaLib = true;
      initLua = false;
      plugins = true;
      nvimRuntime = true;
    };

    combinePlugins = {
      enable = true;
      standalonePlugins = with pkgs.vimPlugins; [
        mini-nvim
      ];
    };
  };

  # Speeds up eval.
  enableMan = false;

  extraPlugins = let
    lpkgs = import inputs.nixpkgs-cutlass {system = "x86_64-linux";};
  in [
    pkgs.vimPlugins.vim-pencil
    lpkgs.vimPlugins.cutlass-nvim
    # (pkgs.vimUtils.buildVimPlugin {
    #   name = "cutlass";
    #   src = inputs.nvim-plugin-cutlass;
    # })
  ];

  highlightOverride = {
    noCursor.blend = 100;
    ModeMsg.fg = "#7d8618";
    MsgArea.fg = "#7d8618";
    FloatBorder.fg = "#7d8618";
    CursorLineNr.fg = "#7d8618";
    CursorLineNr.bg = "#3c3836"; # Gray numberline
    MiniIndentscopeSymbol.fg = "#3c3836"; # Gray indentline
  };

  opts = {
    # Speed
    lazyredraw = true;
    regexpengine = 1;

    # Indents.
    tabstop = 2;
    shiftwidth = 2;
    softtabstop = 2;
    expandtab = true;
    # smartindent = true;
    breakindent = true; # Indent when wrapping

    # Wrapping.
    linebreak = true;
    wrap = true;

    # Center it all.
    scrolloff = 999;
    sidescrolloff = 999;

    # Delay on switching to normal mode.
    ttimeoutlen = 0;

    # g in substitute implicit
    gdefault = true;

    # Incremental search.
    incsearch = true;
    updatetime = 100;

    # Relative numberline on the left.
    number = true;
    relativenumber = true;

    # Color current line number.
    cursorline = true;
    cursorlineopt = "number";

    # Smartcase search and ripgrep.
    smartcase = true;
    ignorecase = true;
    grepprg = "rg --vimgrep";
    grepformat = "%f:%l:%c:%m";

    # Folds.
    foldenable = false;
    foldmethod = "marker";

    # More space.
    cmdheight = 0;

    # Puts error messages on the number line.
    signcolumn = "number";

    # Show some whitespace.
    list = true;
    listchars = "tab:▸ ,trail:·,nbsp:␣";

    # Better completion.
    completeopt = ["menuone" "noselect" "noinsert"];

    # (https://neovim.io/doc/user/options.html#'laststatus')
    laststatus = 3;
  };

  globals = {
    mapleader = " ";
    maplocalleader = ",";
    python_recommended_style = 0; # Otherwise python sets itself to indent 4
  };

  extraFiles = {
    "ftplugin/markdown.vim".text = "setlocal wrap";
  };

  extraConfigLua =
    # Lua
    ''
      -- Miscellaneous {{{
      -- 24 bit color.
      if vim.fn.has('termguicolors') == 1 then
        vim.opt.termguicolors = true
      end

      -- Faster syntax highlighting.
      vim.cmd("syntax sync minlines=256")

      -- Hide end of line tildes.
      vim.opt.fillchars:append({ eob = " " })
      -- }}}
      -- }}}

      vim.cmd[[
        augroup remember_folds
          autocmd!
          au BufWinLeave ?* mkview 1
          au BufWinEnter ?* silent! loadview 1
        augroup END
      ]]

      -- Remember last line {{{
      vim.api.nvim_create_autocmd("BufRead", {
        callback = function(opts)
          vim.api.nvim_create_autocmd("BufWinEnter", {
            once = true,
            buffer = opts.buf,
            callback = function()
              local ft = vim.bo[opts.buf].filetype
              local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
              if
                not (ft:match("commit") and ft:match("rebase"))
                and last_known_line > 1
                and last_known_line <= vim.api.nvim_buf_line_count(opts.buf)
              then
                vim.api.nvim_feedkeys([[g`"]], "nx", false)
              end
            end,
          })
        end,
      })
      -- }}}

      -- Keymaps {{{
      -- Better open
      local open_command = "xdg-open"
      if vim.fn.has("mac") == 1 then
        open_command = 'open'
      end
      local function url_repo()
        local cursorword = vim.fn.expand('<cfile>')
        if string.find(cursorword, '^[a-zA-Z0-9-_.]*/[a-zA-Z0-9-_.]*$') then
          cursorword = "https://github.com/" .. cursorword
        end
        return cursorword or ""
      end
      vim.keymap.set('n', 'gx', function()
        vim.fn.jobstart({ open_command, url_repo() }, { detach = true })
      end, { silent = true })

      -- Open/close quickfix on toggle
      local function toggle_quickfix()
        local quickfix_open = false
        for _, win in ipairs(vim.fn.getwininfo()) do
          if win.quickfix == 1 then
            quickfix_open = true
            break
          end
        end
        if quickfix_open then
          vim.cmd('cclose')
        else
          vim.cmd('copen')
        end
      end
      vim.keymap.set('n', '<S-f>', toggle_quickfix, { silent = true, desc = "Toggle quickfix" })

      -- Keep selection when indenting.
      vim.keymap.set("v", ">", ">gv", { desc = "Keep selection after indenting" })
      vim.keymap.set("v", "<", "<gv", { desc = "Keep selection after unindenting" })

      -- Previous buffer
      vim.keymap.set('n', '<S-l>', '<C-6>')

      -- Split movement
      vim.keymap.set("n", "<S-M-h>", "<cmd>wincmd h<CR>", { desc = "Move to the split on the left side" })
      vim.keymap.set("n", "<S-M-l>", "<cmd>wincmd l<CR>", { desc = "Move to the split on the right side" })
      vim.keymap.set("n", "<S-M-k>", "<cmd>wincmd k<CR>", { desc = "Move to the split above" })
      vim.keymap.set("n", "<S-M-j>", "<cmd>wincmd j<CR>", { desc = "Move to the split below" })

      -- Copy and paste
      vim.keymap.set("n", "<c-v>", '"+p', { desc = "proper paste" })
      vim.keymap.set({"i", "c"}, "<C-V>", "<C-r>+", { desc = "Proper paste" })
      vim.keymap.set({"i", "c"}, "<C-V>", "<C-r>+", { desc = "Proper paste" })
      vim.keymap.set('n', 'Y', 'y$', { desc = "Copy till end of line without newline" })
      vim.keymap.set('n', 'yy', '^y$', { desc = "Copy line without newline and whitespace" })
      vim.keymap.set('v', 'v', '<Esc>^vg_', { desc = "Select line without newline and whitespace" })

      -- Infinite paste
      vim.keymap.set('v', 'p', '"_dP')

      -- Surround each line
      vim.keymap.set('v', 'L', ':norm yss')

      -- Basic
      vim.keymap.set('n', ';', ':', { desc = "Command mode with or without shift" })
      vim.keymap.set("n", ">", ">>", { desc = "Indent more", silent = true })
      vim.keymap.set("n", "<lt>", "<lt><lt>", { desc = "Indent less", silent = true })
      vim.keymap.set("v", ".", "<cmd>normal .<CR>", { desc = "Dot commands over visual blocks" })
      vim.keymap.set("n", "G", "Gzz", { desc = "Center bottom" })
      vim.keymap.set("n", "gg", "ggzz", { desc = "Center top" })
      vim.keymap.set("n", "<Esc>", function() vim.fn.setreg("/", {}) end)
      vim.keymap.set("v", "gj", "J", { desc = "join lines" })
      vim.keymap.set("v", "J", ":m '>+1<CR>gv==kgvo<esc>=kgvo", { desc = "move highlighted text down" })
      vim.keymap.set("v", "K", ":m '<-2<CR>gv==jgvo<esc>=jgvo", { desc = "move highlighted text up" })

      -- Tabs
      vim.keymap.set('n', 'tk', ':tabnext<CR>', {silent = true, desc = "Go to next tab" })
      vim.keymap.set('n', 'tj', ':tabprev<CR>', {silent = true, desc = "Go to previous tab" })
      vim.keymap.set('n', 'td', ':tabclose<CR>', {silent = true, desc = "Close current tab" })
      vim.keymap.set('n', '<leader>1', '1gt', {silent = true, desc = "Go to tab 1" })
      vim.keymap.set('n', '<leader>2', '2gt', {silent = true, desc = "Go to tab 2" })
      vim.keymap.set('n', '<leader>3', '3gt', {silent = true, desc = "Go to tab 3" })
      vim.keymap.set('n', '<leader>4', '4gt', {silent = true, desc = "Go to tab 4" })
      vim.keymap.set('n', '<leader>5', '5gt', {silent = true, desc = "Go to tab 5" })
      vim.keymap.set('n', '<leader>6', '6gt', {silent = true, desc = "Go to tab 6" })
      vim.keymap.set('n', '<leader>7', '7gt', {silent = true, desc = "Go to tab 7" })
      vim.keymap.set('n', '<leader>8', '8gt', {silent = true, desc = "Go to tab 8" })
      vim.keymap.set('n', '<leader>9', '9gt', {silent = true, desc = "Go to tab 9" })

      -- Makes ctrl+s increment to not conflict with tmux
      vim.keymap.set('n', '<C-s>', '<C-a>', {silent = true, desc = "Increment number under cursor" })

      -- Center search and substitution
      vim.keymap.set('n', 'n', 'nzz', {silent = true, desc = "Next search result and center" })
      vim.keymap.set('n', 'N', 'Nzz', {silent = true, desc = "Previous search result and center" })
      vim.keymap.set('n', '*', '*zz', {silent = true, desc = "Search word under cursor and center" })
      vim.keymap.set('n', '#', '#zz', {silent = true, desc = "Search word under cursor (reverse) and center" })
      vim.keymap.set('n', 'g*', 'g*zz', {silent = true, desc = "Search partial word under cursor and center" })
      vim.keymap.set('n', 'g#', 'g#zz', {silent = true, desc = "Search partial word under cursor (reverse) and center" })

      -- Autocomplete
      vim.keymap.set("i", "<C-x>", "<C-x><C-o>", { desc = "Autocomplete" })

      vim.keymap.set('n', '<leader>q', vim.cmd.quit, { desc = "Quit"})
      vim.keymap.set('n', '<leader>Q', vim.cmd.only, { desc = "Quit other windows"})
      -- }}}

      -- Plugins {{{

      -- Cutlass (Delete copy registers) {{{
      require("cutlass").setup({
        override_del = true,
        exclude = { "ns", "nS", "nx", "nX", "nxx", "nX", "vx", "vX", "xx", "xX" }, -- Motion plugins rebind this
        registers = {
          select = "s",
          delete = "d",
          change = "c",
        },
      })
      -- }}}

      -- Gitsigns {{{
      vim.keymap.set("n", "<leader>gsc", "<cmd>Gitsigns toggle_signs<CR>", {desc = "[g]it[s]igns [c]olumn"})
      vim.keymap.set("n", "<leader>gsb", "<cmd>Gitsigns toggle_current_line_blame<CR>", {desc = "[g]it[s]igns [b]lame"})
      -- }}}
      -- }}}
    '';

  clipboard.register = "unnamedplus";
  colorschemes.base16.enable = lib.mkForce false;

  keymaps = [
    {
      action = '':!awk '{ print length(), $0 | "sort -n | cut -d\\  -f2-" }'<CR><CR>'';
      key = "<Leader>S";
      options.silent = true;
      options.desc = "[S]ort lines by length";
    }
  ];

  # Plugins {{{
  plugins = {
    colorful-winsep = {
      enable = true;
      settings = {
        hi.fg = "#7d8618";
        symbols = ["─" "│" "┌" "┐" "└" "┘"];
      };
      lazyLoad.settings.event = "WinLeave";
    };

    lspkind = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      cmp.enable = true;
    };

    project-nvim = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      settings = {
        silent_chdir = true;
        exclude_dirs = ["~/nixos/resources/haskell/*"];
      };
    };

    colorizer = {
      lazyLoad.settings.event = "DeferredUIEnter";
      enable = true;
      settings = {
        user_default_options.names = false;
        buftypes = ["*" "!prompt" "!popup"];
        fileTypes = let
          css = {css = true;};
        in [
          "*"
          ({language = "css";} // css)
          ({language = "less";} // css)
          ({language = "sass";} // css)
          ({language = "scss";} // css)
          ({language = "stylus";} // css)
        ];
      };
    };

    mini = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      modules = {
        indentscope = {
          symbol = "│";
          draw = {
            delay = 0;
            priority = 2;
          };
          options = {
            border = "top";
            try_as_border = true;
            indent_at_cursor = true;
          };
        };
      };
    };

    trouble = {
      lazyLoad.settings.event = "DeferredUIEnter";
      enable = true;
      settings.auto_close = true;
    };

    gitsigns = {
      lazyLoad.settings.event = "DeferredUIEnter";
      enable = true;
      settings = {
        current_line_blame = false;
        signcolumn = true;
      };
    };

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
          (nRegister "<leader>q" "Quit" "󱢓 ")
          (nRegister "<leader>S" "Sort by length" "󰒼 ")

          (nRegister "<leader>gs" "Gitsigns" " ")
        ];
      };
    };

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

  # }}}

  autoCmd = [
    {
      event = ["BufEnter"];
      pattern = ["*"];
      command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o";
      desc = "Dont insert comments on newline";
    }
  ];
}
