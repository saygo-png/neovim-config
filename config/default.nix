{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./neovide.nix
    #
    ./plugins/dial.nix
    ./plugins/flash.nix
    ./plugins/spider.nix
    ./plugins/gruvbox.nix
    ./plugins/harpoon.nix
    ./plugins/rainbow.nix
    ./plugins/telescope.nix
    ./plugins/vimVisualMulti.nix
    #
    ./plugins/ide/lsp.nix
    ./plugins/ide/formatting.nix
  ];

  # I put them in the global scope since direnv deletes the one in the neovim scope
  extraPackages = [
    pkgs.tree-sitter
    pkgs.deadnix # Nix linter
    pkgs.nodePackages.jsonlint
    pkgs.hlint # Haskell linter
    pkgs.statix # Another linter
    pkgs.isort # Python import sorter
    pkgs.markdownlint-cli # Markdown linter
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
        "nvim-treesitter"
        "oil.nvim"
        mini-nvim
      ];
    };
  };

  # extraPlugins = let
  #   mkNvimplugin = name:
  #     pkgs.vimUtils.buildVimPlugin {
  #       inherit name;
  #       src = builtins.getAttr ("nvim-plugin-" + name) inputs;
  #     };
  # in
  #   [pkgs.vimPlugins.vim-pencil]
  #   ++ map mkNvimplugin [
  #     "cutlass"
  #     "faster"
  #   ];

  highlightOverride = {
    noCursor.blend = 100;
    statusline.bg = "NONE";
    ModeMsg.fg = "#7d8618";
    MsgArea.fg = "#7d8618";
    statusline.fg = "#7d8618";
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
    # foldexpr = "nvim_treesitter#foldexpr()";

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
    "ftplugin/haskell.vim".text = "set nocursorline"; # https://github.com/nvim-treesitter/nvim-treesitter/issues/7967
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

      -- Stops treesitter node increment in command window (q:) {{{
      vim.api.nvim_create_augroup("_cmd_win", { clear = true })
      vim.api.nvim_create_autocmd("CmdWinEnter", {
          callback = function()
              local ok, _ = pcall(vim.keymap.del, "n", "<CR>", { buffer = true })
              if not ok then
                  -- Silently ignore error when node increment isnt set, like in q/
              end
          end,
          group = "_cmd_win",
      })
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

      -- Statusline {{{
      -- Statusline components
      local cmp = {}

      -- Helper function to call statusline components by name
      function _G._statusline_component(name)
        return cmp[name]()
      end

      -- Diagnostic status component
      function cmp.diagnostic_status()
        local ok = '''

        local ignore = {
          ['c'] = true, -- command mode
          ['t'] = true  -- terminal mode
        }

        local mode = vim.api.nvim_get_mode().mode

        if ignore[mode] then
          return ok
        end

        local levels = vim.diagnostic.severity
        local errors = #vim.diagnostic.get(0, { severity = levels.ERROR })
        if errors > 0 then
          return 'ERROR '
        end

        local warnings = #vim.diagnostic.get(0, { severity = levels.WARN })
        if warnings > 0 then
          return 'WARN '
        end

        return ok
      end

      -- Git status component using gitsigns
      function cmp.git_status()
        local git_info = vim.b.gitsigns_status_dict
        if not git_info or git_info.head == "" then
          return ""
        end

        local added = git_info.added and ("%#GitSignsAdd#+" .. git_info.added .. " ") or ""
        local changed = git_info.changed and ("%#GitSignsChange#~" .. git_info.changed .. " ") or ""
        local removed = git_info.removed and ("%#GitSignsDelete#-" .. git_info.removed .. " ") or ""

        -- Clean up display if values are 0
        if git_info.added == 0 then
          added = ""
        end
        if git_info.changed == 0 then
          changed = ""
        end
        if git_info.removed == 0 then
          removed = ""
        end

        return table.concat({
          " ",
          added,
          changed,
          removed,
          "%#GitSignsAdd#branch ",
          git_info.head,
          " %#Normal#",
        })
      end

      -- Define the statusline
      local statusline = {
        '%{%v:lua._statusline_component("diagnostic_status")%}',  -- Diagnostic status
        '%t',                                                    -- File name
        '%r',                                                    -- Read-only flag
        '%m',                                                    -- Modified flag
        '%{%v:lua._statusline_component("git_status")%}',         -- Git status
        '%=',                                                    -- Right align
        '%{&filetype} ',                                         -- Filetype
        '%2p%%',                                                 -- File position in percentage
      }

      -- Set the statusline
      vim.o.statusline = table.concat(statusline, ''')
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

      -- Jump whitespace
      vim.keymap.set("n", "{", "<Cmd>call search('^\\s*\\S', 'Wbc') | call search('^\\s*$\\|\\%^', 'Wb')<CR>", { desc = "jump whitespace forward"})
      vim.keymap.set("n", "}", "<Cmd>call search('^\\s*\\S', 'Wc') | call search('^\\s*$\\|\\%$', 'W')<CR>", { desc = "jump whitespae backward"})

      -- Keep selection when indenting.
      vim.keymap.set("v", ">", ">gv", { desc = "Keep selection after indenting" })
      vim.keymap.set("v", "<", "<gv", { desc = "Keep selection after unindenting" })

      -- Previous buffer
      vim.keymap.set('n', '<S-B>', '<C-6>')

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
      vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
      vim.keymap.set("v", "gj", "J", { desc = "join lines" })
      vim.keymap.set("v", "J", ":m '>+1<CR>gv==kgvo<esc>=kgvo", { desc = "move highlighted text down" })
      vim.keymap.set("v", "K", ":m '<-2<CR>gv==jgvo<esc>=jgvo", { desc = "move highlighted text up" })
      vim.keymap.set( "i", "<C-r>", "<C-r><C-o>", { desc = "Insert contents of named register. Inserts text literally, not as if you typed it." })

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

      -- oil.nvim {{{
      vim.keymap.set("n", "<leader>f", "<cmd>Oil<CR>", {desc = "[f]ile browser"})
      -- }}};

      -- Nvim-tree {{{
      vim.keymap.set("n", "<leader>op", "<cmd>NvimTreeToggle<CR>", {desc = "[o]pen [p]roject"})
      -- }}}

      -- Cutlass (Delete copy registers) {{{
      -- require("cutlass").setup({
      --   override_del = true,
      --   exclude = { "ns", "nS", "nx", "nX", "nxx", "nX", "vx", "vX", "xx", "xX" }, -- Motion plugins rebind this
      -- })
      -- }}}

      -- Faster.nvim (Speed up big files) {{{
      -- require("faster").setup({
      --   behaviours = {
      --     bigfile = {
      --       on = true,
      --       features_disabled = {
      --         "illuminate", "matchparen", "lsp", "treesitter",
      --         "indent_blankline", "vimopts", "syntax", "filetype"
      --       },
      --       -- Files larger than `filesize` are considered big files. Value is in MB.
      --       filesize = 0.3,
      --       -- Autocmd pattern that controls on which files behaviour will be applied.
      --       -- `*` means any file.
      --       pattern = "*",
      --     }
      --   }
      -- })
      --- }}}

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
    direnv.enable = true;
    comment.enable = true;
    fugitive.enable = true;
    vim-surround.enable = true;
    web-devicons.enable = true;
    friendly-snippets.enable = true;

    lz-n.enable = true;
    lzn-auto-require.enable = true;

    lspkind = {
      enable = true;
      # lazyLoad.settings.event = "DeferredUIEnter"; # https://github.com/nix-community/nixvim/pull/3563
      cmp.enable = true;
    };

    nvim-tree = {
      enable = true;
      respectBufCwd = true;
      syncRootWithCwd = true;
      updateFocusedFile = {
        enable = true;
        updateRoot = true;
      };
    };

    project-nvim = {
      enable = true;
      settings = {
        silent_chdir = false;
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
      modules = {
        indentscope = {
          symbol = "│";
          draw.delay = 0;
          draw.priority = 2;
          options.border = "top";
          options.try_as_border = true;
          options.indent_at_cursor = true;
        };
      };
    };

    trouble = {
      lazyLoad.settings.event = "DeferredUIEnter";
      enable = true;
      settings.auto_close = true;
    };

    treesitter = let
      boolMatch = let
        checkPassed =
          lib.assertMsg
          (builtins.match "abc" "abc" == [] && builtins.match "foo" "abc" == null)
          "builtins.match must have changed";
      in
        regex: str: (builtins.match regex str) != null && checkPassed;

      inherit (pkgs.vimPlugins.nvim-treesitter.passthru) allGrammars;
      matchCommentGrammar = str: boolMatch ".*comment-grammar.*" str;
      filteredGrammars = builtins.filter (set: !matchCommentGrammar set.name) allGrammars;
    in {
      enable = true;
      folding = true;
      nixvimInjections = true;
      nixGrammars = true; # Install grammars with Nix
      grammarPackages = filteredGrammars;
      settings = {
        indent.enable = true;
        ignore_install = ["comment"]; # Comment parser is very slow
        auto_install = false;
        highlight.enable = true;
        incremental_selection = {
          enable = true;
          keymaps = {
            scope_incremental = "gsi";
            node_decremental = "<BS>";
            node_incremental = "<Enter>";
            init_selection = "<Enter>";
          };
        };
      };
    };

    gitsigns = {
      lazyLoad.settings.event = "DeferredUIEnter";
      enable = true;
      settings = {
        current_line_blame = false;
        signcolumn = true;
      };
    };

    lint = let
      statixConfig = builtins.toFile "statix.toml" ''disabled = [repeated_keys]'';
    in {
      enable = true;
      linters.statix.args = ["--config=${statixConfig}"];
      lintersByFt = {
        c = ["clangtidy"];
        cpp = ["clangtidy"];
        haskell = ["hlint"];
        json = ["jsonlint"];
        bash = ["shellcheck"];
        shell = ["shellcheck"];
        nix = ["nix" "deadnix" "statix"];
        dockerfile = ["hadolint"];
        markdown = ["markdownlint"];
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
          (nRegister "<leader>s" "Swap" " ")
          (nRegister "<leader>o" "Open" " ")
          (nRegister "<leader>r" "Re" " ")
          (nRegister "<leader>q" "Quit" "󱢓 ")
          (nRegister "<leader>d" "Definition" "")
          (nRegister "<leader>f" "File browser" " ")
          (nRegister "<leader>S" "Sort by length" "󰒼 ")
          (nRegister "<S-k>" "Hover info" "")

          (nRegister "<leader>g" "go" "󰜎 ")
          (nRegister "<leader>gs" "Gitsigns" " ")
          (nRegister "<leader>gd" "go to definition" "")
          (nRegister "<leader>gr" "go to references" "")
          (nRegister "<leader>gi" "go to implementation" "")

          (nRegister "<leader>ha" "Add file" "")
          (nRegister "<leader>hm" "File menu" "")
          (nRegister "<leader>hc" "Command menu" "")
          (nRegister "<leader>hn" "Next file" "")
          (nRegister "<leader>hp" "Previous file" "")
        ];
      };
    };

    oil = {
      enable = true;
      settings.defaultFileExplorer = true;
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
