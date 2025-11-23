{pkgs, ...}: {
  extraPackages = [
    pkgs.deadnix # Nix linter
    pkgs.shellcheck
  ];

  plugins = {
    lint = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      customLinters = {
        nlint = {
          cmd = "nlint";
          stdin = false;
          parser.__raw = ''
            function(output)
              local severities = {
                error = vim.diagnostic.severity.ERROR,
                warning = vim.diagnostic.severity.WARN,
                hint = vim.diagnostic.severity.HINT,
              }
              local diagnostics = {}
              local items = #output > 0 and vim.json.decode(output) or {}
              for _, item in ipairs(items) do
                table.insert(diagnostics, {
                  lnum = item.startLine - 1,
                  col = item.startColumn - 1,
                  end_lnum = item.endLine - 1,
                  end_col = item.endColumn - 1,
                  severity = severities[item.severity:lower()],
                  source = "nlint",
                  message = item.hint
                            .. "\n"
                            .. (item.from ~= vim.NIL and ("From: " .. item.from) or "")
                            .. "\n"
                            .. (item.to ~= vim.NIL and ("To: " .. item.to) or "")
                            .. "\n" .. "\n"
                            .. item.why,
                })
              end
              return diagnostics
            end
          '';
        };
      };
      lintersByFt = {
        bash = ["shellcheck"];
        shell = ["shellcheck"];
        nix = ["nlint" "nix" "deadnix"];
      };
    };
  };
}
