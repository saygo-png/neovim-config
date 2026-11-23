{
  config,
  inputs,
  pkgs,
  ...
}: let
  inherit (config) k wk;
in {
  plugins.telescope = {
    enable = true;
    lazyLoad.settings.cmd = "Telescope";
    extensions.fzf-native.enable = true;
  };

  my = {
    which-keys."<leader>tc".group = "Current dir";
    which-keys."<leader>t" = wk "Telescope" " ";
    keymaps.normal = {
      "<leader>tb" = k "<cmd>Telescope current_buffer_fuzzy_find<CR>" "[t]elescope [b]uffer";
      "<leader>tn" = k "<cmd>Telescope help_tags<CR>" "[t]elescope [n]oob";
      "<leader>tk" = k "<cmd>Telescope keymaps<CR>" "[t]elescope [k]eymaps";
      "<leader>tf" = k "<cmd>Telescope find_files<CR>" "[t]elescope [f]iles";
      "<leader>tt" = k "<cmd>Telescope builtin<CR>" "[t]elescope search [t]elescope";
      "<leader>tw" = k "<cmd>Telescope grep_string<CR>" "[t]elescope current [w]ord";
      "<leader>tl" = k "<cmd>Telescope live_grep<CR>" "[t]elescope [l]ive grep";
      "<leader>td" = k "<cmd>Telescope diagnostics<CR>" "[t]elescope [d]iagnostics";
      "<leader>tr" = k "<cmd>Telescope resume<CR>" "[t]elescope [r]esume";
      "<leader>t." = k "<cmd>Telescope oldfiles<CR>" "[t]elescope recent files (. for repeat)";
      "<leader><leader>" = k "<cmd>Telescope buffers<CR>" "Find existing buffers";
      "<leader>to" = k "<cmd>Telescope live_grep grep_open_files=true<CR>" "[T]raverse in [O]pen Files";
      "<leader>tcf" = k "<cmd>Telescope find_files cwd=%:p:h<CR>" "[t]elescope find [f]iles in [c]urrent dir";
      "<leader>tcg" = k "<cmd>Telescope live_grep cwd=%:p:h<CR>" "[t]elescope grep in [c]urrent dir";
      "<leader>tv" = k "<cmd>Telescope git_file_history<CR>" "[t]elescope [v]ersions";
      "<leader>tp" = k "<cmd>Telescope projects<CR>" "[t]elescope [p]rojects";
      "<leader>tg" = k "<cmd>Telescope grep_string search= only_sort_text=true shorten_path=true<CR>" "[t]elescope fuzzy [g]rep";
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
