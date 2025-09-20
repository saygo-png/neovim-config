{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit (config) k wk;
  inherit (lib.nixvim) mkRaw;
in {
  plugins = {
    harpoon.enableTelescope = true;
    project-nvim.enableTelescope = false;
    telescope = {
      enable = true;
      # lazyLoad.settings.cmd = ["Telescope"]; # Lazyloading makes extensions not load in
      enabledExtensions = ["git_file_history"];
      extensions.fzf-native = {
        enable = true;
        settings = {
          fuzzy = true;
          override_file_sorter = true;
          override_generic_sorter = true;
        };
      };

      keymaps = {
        "<leader>tb" = {
          action = "current_buffer_fuzzy_find";
          options.desc = "[t]elescope [b]uffer";
        };
        "<leader>tn" = {
          action = "help_tags";
          options.desc = "[t]elescope [n]oob";
        };
        "<leader>tk" = {
          action = "keymaps";
          options.desc = "[t]elescope [k]eymaps";
        };
        "<leader>tf" = {
          action = "find_files";
          options.desc = "[t]elescope [f]iles";
        };
        "<leader>ts" = {
          action = "builtin";
          options.desc = "[t]elescope [s]elect telescope";
        };
        "<leader>tw" = {
          action = "grep_string";
          options.desc = "[t]elescope current [w]ord";
        };
        "<leader>tl" = {
          action = "live_grep";
          options.desc = "[t]elescope [l]ive grep";
        };
        "<leader>td" = {
          action = "diagnostics";
          options.desc = "[t]elescope [d]iagnostics";
        };
        "<leader>tr" = {
          action = "resume";
          options.desc = "[t]elescope [r]esume";
        };
        "<leader>t." = {
          action = "oldfiles";
          options.desc = "[t]elescope recent files (. for repeat)";
        };
        "<leader><leader>" = {
          action = "buffers";
          options.desc = "Find existing buffers";
        };
      };
    };
  };

  my = {
    which-keys."<leader>t" = wk "Telescope" " ";
    keymaps.normal =
      {
        "<leader>to" = k (mkRaw "function()
          require'telescope.builtin'.live_grep({ grep_open_files = true, prompt_title = 'Live Grep in Open Files' })
        end") "[T]raverse in [O]pen Files";

        "<leader>tcf" = k (mkRaw "function()
          require'telescope.builtin'.find_files({ cwd = require'telescope.utils'.buffer_dir() })
        end") "[t]elescope find [f]iles in [c]urrent dir";

        "<leader>tcg" = k (mkRaw "function()
          require'telescope.builtin'.live_grep({ cwd = require'telescope.utils'.buffer_dir() })
        end") "[t]elescope grep in [c]urrent dir";

        "<leader>tg" = k (mkRaw "function()
          require'telescope.builtin'.grep_string({ shorten_path = true, only_sort_text = true, search = '' })
        end") "[t]elescope fuzzy [g]rep";

        "<leader>tv" = k (mkRaw "function()
          require'telescope'.extensions.git_file_history.git_file_history()
        end") "[t]elescope [v]ersions";
      }
      // lib.optionals config.plugins.harpoon.enable {
        "<leader>th" = k "<cmd>Telescope harpoon marks<CR>" "[t]elescope [h]arpoon Marks";
      };
  };

  highlightOverride = {
    TelescopeBorder.link = "LineNr";
    TelescopePromptBorder.link = "LineNr";
    TelescopeResultsBorder.link = "LineNr";
    TelescopePreviewBorder.link = "LineNr";
  };

  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "telescope-git-file-history";
      src = inputs.nvim-plugin-telescope-git-file-history;
    })
  ];
}
