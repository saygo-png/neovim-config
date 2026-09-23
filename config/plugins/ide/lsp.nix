{
  config,
  lib,
  ...
}: let
  inherit (config) lk lkb;
  inherit (lib.nixvim.utils) mkRaw;
in {
  lsp = {
    linkedEditingRange.enable = true;
    codelens.enable = true;
    documentColor = {
      enable = true;
      settings.style = "background";
    };

    keymaps = [
      (lk "<leader>a" "<cmd>Lspsaga code_action<CR>" "Code [a]ctions")
      (lk "<Leader>e" (mkRaw "vim.diagnostic.open_float") "Diagnostic")
      (lkb "K" "hover" "Hover")

      (lk "gh" "<cmd>Lspsaga show_workspace_diagnostics<CR>" "Diagnostics [h]elp")
      (lkb "gD" "declaration" "Declaration")
      (lk "gp" (mkRaw "function() vim.diagnostic.jump({count = -1}) end") "[p]revious diagnostic")
      (lk "gn" (mkRaw "function() vim.diagnostic.jump({count = 1}) end") "[n]ext diagnostic")

      (lk "gd" "<cmd>Telescope lsp_definitions<CR>" "")
      (lk "gt" "<cmd>Telescope lsp_type_definitions<CR>" "")
      (lk "te" "<cmd>Telescope lsp_references<CR>" "")
      (lk "gI" "<cmd>Telescope lsp_implementations<CR>" "")
      (lk "<leader>ts" "<cmd>Telescope lsp_document_symbols<CR>" "")
    ];

    servers = {
      "*".config = {
        root_markers = [".git"];
        capabilities.textDocument.semanticTokens.multilineTokenSupport = true;
      };

      rust_analyzer.enable = true;
      pyright.enable = true;
      bashls.enable = true;
      lua_ls.enable = true;

      # Web
      html.enable = true;
      jsonls.enable = true;
      cssls.enable = true;
      eslint.enable = true;

      # Typst
      tinymist.enable = true;

      # Nix.
      nil_ls = {
        enable = true;
        config.nix.flake.autoArchive = true;
      };

      # Typos.
      typos_lsp = {
        enable = true;
        config.init_options.diagnosticSeverity = "Hint";
      };

      ts_ls.enable = true;
      denols.enable = true;
    };
  };

  plugins = {
    lspconfig.enable = true;

    lspsaga = {
      enable = true;
      settings = {
        symbol_in_winbar.enable = true;
        implement.enable = true;
        lightbulb.enable = false;
      };
    };
  };

  diagnostic.settings = {
    signs = true;
    underline = true;
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

  extraConfigLua = ''
    -- Rename node using vim binds
    vim.keymap.set("n", "<leader>rn", function()
      local cmdId
      cmdId = vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
        callback = function()
          local key = vim.api.nvim_replace_termcodes("<C-f>", true, false, true)
          vim.api.nvim_feedkeys(key, "c", false)
          vim.api.nvim_feedkeys("0", "n", false)
          -- autocmd was triggered and so we can remove the ID and return true to delete the autocmd
          cmdId = nil
          return true
        end,
      })
      vim.lsp.buf.rename()
      -- if LSP couldn't trigger rename on the symbol, clear the autocmd
      vim.defer_fn(function()
        -- the cmdId is not nil only if the LSP failed to rename
        if cmdId then
          vim.api.nvim_del_autocmd(cmdId)
        end
      end, 500)
    end, {desc = "rename node"})
  '';
}
