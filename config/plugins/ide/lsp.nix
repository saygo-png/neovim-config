{pkgs, ...}: {
  extraPackages = [pkgs.tree-sitter]; # Needed for lspsaga
  lsp = {
    keymaps = [
      {
        key = "<Leader>e";
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        options.desc = "Diagnostic";
      }
      {
        key = "gD";
        lspBufAction = "declaration";
        options.desc = "";
      }
      {
        key = "K";
        action = "<cmd>Lspsaga hover_doc<CR>";
        options.desc = "Hover";
      }
      {
        key = "<leader>a";
        action = "<cmd>Lspsaga code_action<CR>";
        options.desc = "Code [a]ctions";
      }
      {
        key = "gd";
        action.__raw = "require('telescope.builtin').lsp_definitions";
        options.desc = "";
      }
      {
        key = "gt";
        action.__raw = "require('telescope.builtin').lsp_type_definitions";
        options.desc = "";
      }
      {
        key = "gr";
        action.__raw = "require('telescope.builtin').lsp_references";
        options.desc = "";
      }
      {
        key = "gI";
        action.__raw = "require('telescope.builtin').lsp_implementations";
        options.desc = "";
      }
      {
        key = "<leader>s";
        action.__raw = "require('telescope.builtin').lsp_document_symbols";
        options.desc = "";
      }
    ];

    servers = {
      "*".settings = {
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

      # Haskell.
      hls.enable = true;

      # Nix.
      nil_ls = {
        enable = true;
        settings.nix.flake.autoArchive = true;
      };

      # Typos.
      typos_lsp = {
        enable = true;
        settings.init_options.diagnosticSeverity = "Hint";
      };

      # Typescript
      ts_ls = {
        enable = true;
        settings = {
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
        settings.root_dir = ''
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
      ui.border = "single";
      symbolInWinbar.enable = true;
      implement.enable = true;
      lightbulb.enable = false;
    };
  };

  diagnostic.settings = {
    signs = true;
    underline = true;
    severity_sort = true;
    jump.severity.__raw = "vim.diagnostic.severity.WARN";
    float = {
      source = "if_many";
      border = "single";
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
