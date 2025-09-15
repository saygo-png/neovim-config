{config, ...}: let
  inherit (config) k kns;
in {
  imports = [
    ./lib/keymaps.nix

    ./neovide.nix
    ./theme.nix
    ./performance.nix

    ./plugins
    ./plugins/oil.nix
    ./plugins/dial.nix
    ./plugins/mini.nix
    ./plugins/flash.nix
    ./plugins/spider.nix
    ./plugins/fidget.nix
    ./plugins/lualine.nix
    ./plugins/harpoon.nix
    ./plugins/cutlass.nix
    ./plugins/rainbow.nix
    ./plugins/which-key.nix
    ./plugins/colorizer.nix
    ./plugins/gitsigns.nix
    ./plugins/project-nvim.nix
    ./plugins/trouble.nix
    ./plugins/colorful-winsep.nix
    ./plugins/telescope.nix
    ./plugins/nvim-tree.nix
    ./plugins/treesitter.nix
    ./plugins/vimVisualMulti.nix

    ./plugins/ide/lsp.nix
    ./plugins/ide/linting.nix
    ./plugins/ide/formatting.nix
    ./plugins/ide/autocomplete.nix
  ];

  opts = {
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

  clipboard.register = "unnamedplus";

  my.keymaps = {
    normal = {
      "<S-l>" = k "<C-6>" "Previous buffer";

      # Splits
      "<S-M-h>" = k "<cmd>wincmd h<CR>" "Move to the split on the left side";
      "<S-M-l>" = k "<cmd>wincmd l<CR>" "Move to the split on the right side";
      "<S-M-k>" = k "<cmd>wincmd k<CR>" "Move to the split above";
      "<S-M-j>" = k "<cmd>wincmd j<CR>" "Move to the split below";

      # Tabs
      "tk" = k ":tabnext<CR>" "Go to next tab";
      "tj" = k ":tabprev<CR>" "Go to previous tab";
      "td" = k ":tabclose<CR>" "Close current tab";
      "<leader>1" = k "1gt" "Go to tab 1";
      "<leader>2" = k "2gt" "Go to tab 2";
      "<leader>3" = k "3gt" "Go to tab 3";
      "<leader>4" = k "4gt" "Go to tab 4";
      "<leader>5" = k "5gt" "Go to tab 5";
      "<leader>6" = k "6gt" "Go to tab 6";
      "<leader>7" = k "7gt" "Go to tab 7";
      "<leader>8" = k "8gt" "Go to tab 8";
      "<leader>9" = k "9gt" "Go to tab 9";

      # Center
      "G" = k "Gzz" "Center bottom";
      "gg" = k "ggzz" "Center top";
      "n" = k "nzz" "Next search result and center";
      "N" = k "Nzz" "Previous search result and center";
      "*" = k "*zz" "Search word under cursor and center";
      "#" = k "#zz" "Search word under cursor (reverse) and center";
      "g*" = k "g*zz" "Search partial word under cursor and center";
      "g#" = k "g#zz" "Search partial word under cursor (reverse) and center";

      # Rebind increment to not conflict with tmux
      "<C-s>" = k "<C-a>" "Increment number under cursor";

      # Paste
      "Y" = k "y$" "Copy till end of line without newline";
      "yy" = k "^y$" "Copy line without newline and whitespace";
      "<c-v>" = k ''"+p'' "Raw paste";

      # Misc
      ";" = kns ":" "Command mode with or without shift";
      ">" = k ">>" "Indent more";
      "<lt>" = k "<lt><lt>" "Indent less";
    };
    visual = {
      # Keep selection when indenting.
      ">" = k ">gv" "Keep selection when indenting";
      "<" = k "<gv" "Keep selection when indenting";

      # Misc
      "v" = k "<Esc>^vg_" "Select line without newline and whitespace";
      "p" = k ''"_dP'' "Infinite paste";
      "L" = k ":norm yss" "Surround each line";
      "." = k "<cmd>normal .<CR>" "Dot commands over visual blocks";
      "gj" = k "J" "Join lines";

      "<Leader>S" = k '':!awk '{ print length(), $0 | "sort -n | cut -d\\  -f2-" }'<CR><CR>'' "[S]ort lines by length";
    };
  };

  autoGroups."remember_folds".clear = true;
  autoCmd = [
    {
      group = "remember_folds";
      event = ["BufWinEnter"];
      command = "silent! loadview 1";
    }
    {
      group = "remember_folds";
      event = ["BufWinLeave"];
      command = "mkview 1";
    }
  ];

  extraConfigLua =
    # Lua
    ''
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

      -- Copy and paste
      vim.keymap.set({"i", "c"}, "<C-V>", "<C-r>+", { desc = "Proper paste" })
      vim.keymap.set({"i", "c"}, "<C-V>", "<C-r>+", { desc = "Proper paste" })

      -- Basic
      vim.keymap.set("n", "<Esc>", function() vim.fn.setreg("/", {}) end)
      vim.keymap.set('n', '<leader>q', vim.cmd.only, { desc = "Quit other windows"})
    '';

  autoCmd = [
    {
      event = ["BufEnter"];
      pattern = ["*"];
      command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o";
      desc = "Dont insert comments on newline";
    }
  ];
}
