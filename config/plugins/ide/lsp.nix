{
  config,
  lib,
  ...
}: let
  inherit (config) kns lk;
  inherit (lib.nixvim.utils) mkRaw;
in {
  lsp = {
    # HLS shows explicit import lists and record wildcard fields as hints.
    inlayHints.enable = true;
    linkedEditingRange.enable = true;
    codelens.enable = true;
    documentColor.enable = true;

    keymaps = [
      (lk "<leader>a" "<cmd>Lspsaga code_action<CR>" "Code [a]ctions")
      (lk "<Leader>e" (mkRaw "vim.diagnostic.open_float") "Diagnostic")
      (lk "<leader>w" (mkRaw ''
        function()
          local S = vim.diagnostic.severity
          vim.g.warnings_hidden = not vim.g.warnings_hidden
          local severity = vim.g.warnings_hidden and { S.ERROR, S.INFO, S.HINT } or nil

          local current = vim.diagnostic.config()
          local cfg = {}
          for _, h in ipairs({ "underline", "virtual_text", "signs", "float" }) do
            if current[h] == false then
              cfg[h] = false
            else
              local t = vim.deepcopy(type(current[h]) == "table" and current[h] or {})
              t.severity = severity
              cfg[h] = t
            end
          end
          vim.diagnostic.config(cfg)

          vim.notify("Warnings " .. (vim.g.warnings_hidden and "hidden" or "shown"))
        end
      '') "toggle [w]arnings")

      (lk "gh" "<cmd>Lspsaga show_workspace_diagnostics<CR>" "Diagnostics [h]elp")
      (lk "gD" (mkRaw "vim.lsp.buf.declaration") "Declaration")

      (lk "gd" "<cmd>Telescope lsp_definitions<CR>" "Definitions")
      (lk "gt" "<cmd>Telescope lsp_type_definitions<CR>" "Type definitions")
      (lk "grr" "<cmd>Telescope lsp_references<CR>" "References")
      (lk "gI" "<cmd>Telescope lsp_implementations<CR>" "Implementations")
      (lk "<leader>ts" "<cmd>Telescope lsp_document_symbols<CR>" "Document symbols")
    ];

    servers = {
      "*".config.root_markers = [".git"];

      zuban.enable = true;
      biome.enable = true;

      # Typst
      tinymist.enable = true;

      # Nix.
      nil_ls = {
        enable = true;
        config.settings.nil.nix.flake.autoArchive = true;
      };

      # Typos.
      typos_lsp = {
        enable = true;
        config.init_options = {
          diagnosticSeverity = "Hint";
          config = builtins.toFile "typos.toml" ''
            [default.extend-words]
            bimap = "bimap"
          '';
        };
      };
    };
  };

  # `<leader>rn` opens the cmdline window on `:Rename <word>`, so the new name
  # is edited with normal vim motions.
  userCommands.Rename = {
    command = mkRaw "function(args) vim.lsp.buf.rename(args.args) end";
    nargs = 1;
    desc = "Rename the symbol under the cursor";
  };
  my.keymaps.normal."<leader>rn" = kns ":Rename <C-r><C-w><C-f>0w" "[r]e[n]ame node";

  plugins = {
    lspconfig.enable = true;

    lspsaga = {
      enable = true;
      # Loads on the first LSP attach, or when a keymap calls :Lspsaga.
      lazyLoad.settings = {
        event = "LspAttach";
        cmd = "Lspsaga";
      };
      settings = {
        implement.enable = true;
        lightbulb.enable = false;
      };
    };
  };

  # LSP progress as native progress messages, shown by ui2 (see default.nix).
  autoCmd = [
    {
      event = "LspProgress";
      desc = "Show LSP progress";
      callback = mkRaw ''
        function(ev)
          local value = ev.data.params.value
          vim.api.nvim_echo({ { value.message or "done" } }, false, {
            id = "lsp." .. ev.data.params.token,
            kind = "progress",
            source = "vim.lsp",
            title = value.title,
            status = value.kind ~= "end" and "running" or "success",
            percent = value.percentage,
          })
        end
      '';
    }
  ];

  diagnostic.settings = {
    severity_sort = true;
    float.source = "if_many";
    jump = {
      severity = mkRaw "vim.diagnostic.severity.WARN";
      on_jump = mkRaw ''
        function(_, bufnr)
          vim.diagnostic.open_float({buffer = bufnr, scope = "cursor", focus = false})
        end
      '';
    };
  };
}
