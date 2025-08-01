_: {
  highlightOverride = {
    statusline.bg = "NONE";
    statusline.fg = "#7d8618";
  };

  extraConfigLuaPre =
    # Lua
    ''
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
    '';
}
