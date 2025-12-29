{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config) lk;
  inherit (lib.nixvim.utils) mkRaw;
in {
  extraPackages = [
    pkgs.tree-sitter
    pkgs.deadnix
    pkgs.shellcheck
  ]; # Needed for lspsaga
  lsp = {
    keymaps = [
      (lk "<Leader>e" "<cmd>lua vim.diagnostic.open_float()<CR>" "Diagnostic")
      (lk "<leader>a" "<cmd>Lspsaga code_action<CR>" "Code [a]ctions")
      (lk "K" "<cmd>Lspsaga hover_doc<CR>" "Hover")

      (lk "gD" "declaration" "")
      (lk "gh" "<cmd>Lspsaga show_workspace_diagnostics<CR>" "Diagnostics [h]elp")
      (lk "gp" "<cmd>Lspsaga diagnostic_jump_prev<CR>" "[p]revious diagnostic")
      (lk "gn" "<cmd>Lspsaga diagnostic_jump_next<CR>" "[n]ext diagnostic")

      (lk "gd" "<cmd>Telescope lsp_definitions<CR>" "")
      (lk "gt" "<cmd>Telescope lsp_type_definitions<CR>" "")
      (lk "gr" "<cmd>Telescope lsp_references<CR>" "")
      (lk "gI" "<cmd>Telescope lsp_implementations<CR>" "")
      (lk "<leader>s" "<cmd>Telescope lsp_document_symbols<CR>" "")
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

      # Typescript
      ts_ls = {
        enable = true;
        config = {
          root_dir = ''
            function (filename, bufnr)
              local util = require 'lspconfig.util'
              local denoRootDir = util.root_pattern("deno.json", "deno.jsonc")(filename);
              if denoRootDir then
                return nil;
              end
              return util.root_pattern("package.json")(filename);
            end
          '';
          single_file_support = false;
        };
      };

      # Typescript with deno
      denols = {
        enable = true;
        config.root_dir = ''
          function (filename, bufnr)
            local util = require 'lspconfig.util'
            return util.root_pattern("deno.json", "deno.jsonc")(filename);
          end
        '';
      };
    };
  };

  plugins = {
    lspconfig.enable = true;

    lspsaga = {
      enable = true;
      settings = {
        ui.border = "single";
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
    jump.severity = mkRaw "vim.diagnostic.severity.WARN";
    float.source = "if_many";
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
