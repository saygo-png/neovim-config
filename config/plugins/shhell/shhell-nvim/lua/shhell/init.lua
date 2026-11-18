-- shhell.nvim: shhell in a terminal, with commands typed in a prompt buffer
-- below it. See README.md.

local ffi = require("ffi")

local M = {}

---@class shhell.Config
---@field cmd string[] The shell to run.
---@field height integer Height of the prompt window.
local config = { cmd = { "shhell" }, height = 3 }

---@class shhell.Link
---@field path string
---@field text string Its text, to check it is still there.

---@class shhell.State
---@field job integer?
---@field term_win integer? The window showing the terminal, while it does.
---@field term_buf integer?
---@field prompt_win integer?
---@field prompt_buf integer?
---@field cwd string? The shell's directory, from OSC 7.
---@field took boolean The running program has the keys.
---@field wanted integer For how many checks in a row it has wanted them.
---@field link {row: integer, cell: integer, path: string}? The link being printed.
local s = { took = false, wanted = 0 }

local ns = vim.api.nvim_create_namespace("shhell")
local links = {} ---@type table<integer, shhell.Link>

function M.focus_prompt()
  if vim.api.nvim_get_mode().mode == "t" then
    -- Leaving terminal mode only takes effect after this returns, which would
    -- undo startinsert, so come back once it has.
    vim.api.nvim_feedkeys(vim.keycode("<C-\\><C-n><Cmd>lua require('shhell').focus_prompt()<CR>"), "n", false)
  else
    vim.api.nvim_set_current_win(assert(s.prompt_win))
    vim.cmd.startinsert({ bang = true })
  end
end

-- Programs that want the keys -------------------------------------------------
--
-- A program that reads keys one at a time (btop, fzf, nvim) or a password
-- turns off the terminal's line editing or echo. GHCi does too while it waits
-- at its prompt, but then it has no child process, except for a moment while
-- the prompt runs direnv.

pcall(ffi.cdef, [[
  struct shhell_termios { unsigned int iflag, oflag, cflag, lflag; unsigned char line, cc[32]; unsigned int ispeed, ospeed; };
  int tcgetattr(int fd, struct shhell_termios *termios);
]])

---@return boolean
local function program_wants_keys()
  local children = vim.fn.glob("/proc/" .. vim.fn.jobpid(s.job) .. "/task/*/children", false, true)
  if not vim.iter(children):any(function(f) return vim.fn.readfile(f)[1] ~= nil end) then
    return false
  end
  local pty = vim.api.nvim_get_chan_info(assert(s.job)).pty
  local c = vim.uv.constants
  local fd = pty and vim.uv.fs_open(pty, bit.bor(c.O_RDONLY, c.O_NOCTTY, c.O_NONBLOCK), 0)
  if not fd then
    return false
  end
  local t = ffi.new("struct shhell_termios") --[[@as {lflag: integer}]]
  local ok = ffi.C.tcgetattr(fd, t) == 0
  vim.uv.fs_close(fd)
  local ICANON, ECHO = 2, 8
  return ok and bit.band(t.lflag, ICANON + ECHO) ~= ICANON + ECHO
end

-- Checked ten times a second: the keys go to the program once it has wanted
-- them for 300 ms, and come back as soon as it doesn't.
local function watch()
  s.wanted = s.job ~= nil and program_wants_keys() and s.wanted + 1 or 0
  local wants = s.wanted >= 3
  if wants == s.took then
    return
  end
  s.took = wants
  local win = vim.api.nvim_get_current_win()
  if wants and (win == s.prompt_win or win == s.term_win) then
    vim.api.nvim_set_current_win(assert(s.term_win))
    vim.cmd.startinsert()
  elseif not wants and win == s.term_win and vim.api.nvim_get_mode().mode == "t" then
    M.focus_prompt()
  end
end

-- Links -----------------------------------------------------------------------
--
-- `eza --hyperlink=always` and the like wrap file names in OSC 8 sequences.
-- Neovim can't read them back, so each link is noted as it arrives, and marked
-- once its text is in the buffer. It counts only while that text is still
-- there, so lines the terminal has since redrawn don't keep old links.

---@param str string
---@return string
local function unescape(str)
  return (str:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

---@param link {row: integer, cell: integer, path: string}
---@param end_cell integer
local function mark_link(link, end_cell)
  if not s.term_win then
    return
  end
  local line = vim.api.nvim_buf_get_lines(assert(s.term_buf), link.row - 1, link.row, false)[1] or ""
  local first = vim.fn.virtcol2col(s.term_win, link.row, link.cell + 1)
  local last = vim.fn.virtcol2col(s.term_win, link.row, end_cell)
  local stop = last + vim.str_utf_end(line, last)
  local text = line:sub(first, stop)
  if first > 0 and text:match("%S") then
    local id = vim.api.nvim_buf_set_extmark(assert(s.term_buf), ns, link.row - 1, first - 1, { end_col = stop })
    links[id] = { path = link.path, text = text }
  end
end

---@param ev vim.api.keyset.create_autocmd.callback_args
local function on_request(ev)
  local data = ev.data ---@type vim.event.termrequest.data
  local uri = data.sequence:match("^\27%]8;[^;]*;(.*)")
  local dir = data.sequence:match("^\27%]7;file://[^/]*(/.*)")
  if uri and uri ~= "" then
    local path = uri:match("^file://[^/]*(/.*)") ---@type string?
    s.link = path and { row = data.cursor[1], cell = data.cursor[2], path = unescape(path) } or nil
  elseif uri and s.link and s.link.row == data.cursor[1] then
    local link, end_cell = assert(s.link), data.cursor[2]
    s.link = nil
    -- The text reaches the buffer a moment after the sequences.
    vim.defer_fn(function() mark_link(link, end_cell) end, 100)
  elseif dir then
    s.cwd = unescape(dir)
  end
end

---@return string?
local function link_at_cursor()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  for _, m in ipairs(vim.api.nvim_buf_get_extmarks(0, ns, { row - 1, col }, { row - 1, col }, { overlap = true, details = true })) do
    local link = links[m[1]]
    local stop = m[4] and m[4].end_col or 0
    if link and col < stop and line:sub(m[3] + 1, stop) == link.text then
      return link.path
    end
  end
end

-- A Haskell string for a path, relative to the shell's directory if inside it.
---@param path string
---@return string
local function haskell_string(path)
  local dir = s.cwd and s.cwd:gsub("/$", "") .. "/"
  if dir and vim.startswith(path, dir) then
    path = path:sub(#dir + 1)
  end
  local escaped = path:gsub('[\\"]', "\\%0"):gsub("%c", function(c) return "\\" .. c:byte() .. "\\&" end)
  return '"' .. escaped .. '"'
end

-- Sending ---------------------------------------------------------------------

--- Send lines to shhell as if typed; several go as one :{ :} block.
---@param lines string[]
function M.send(lines)
  if not s.job then
    vim.notify("shhell is not running", vim.log.levels.WARN)
    return
  end
  -- Show the end of the output, and follow it.
  if s.term_win then
    vim.api.nvim_win_set_cursor(s.term_win, { vim.api.nvim_buf_line_count(assert(s.term_buf)), 0 })
  end
  local text = #lines == 1 and lines[1] or ":{\r" .. table.concat(lines, "\r") .. "\r:}"
  vim.api.nvim_chan_send(s.job, text .. "\r")
end

--- Send the current line, or the visual selection, from any buffer.
function M.send_from_buffer()
  local a, b = vim.fn.line("v"), vim.fn.line(".")
  M.send(vim.api.nvim_buf_get_lines(0, math.min(a, b) - 1, math.max(a, b), false))
  if vim.fn.mode() ~= "n" then
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
  end
end

-- Opening ---------------------------------------------------------------------

---@param buf integer
---@param modes string|string[]
---@param lhs string
---@param rhs string|function
local function map(buf, modes, lhs, rhs)
  vim.keymap.set(modes, lhs, rhs, { buffer = buf })
end

---@param buf integer
local function prompt_keymaps(buf)
  map(buf, { "n", "i" }, "<CR>", function()
    M.send(vim.api.nvim_buf_get_lines(buf, 0, -1, false))
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  end)
  map(buf, "i", "<M-CR>", "<CR>")
  map(buf, { "n", "i" }, "<C-c>", function() vim.api.nvim_chan_send(assert(s.job), "\3") end)
  -- As in Telescope: <Esc> leaves insert mode, and again goes to the output,
  -- which <C-u> and <C-d> scroll from here.
  map(buf, "n", "<Esc>", function() vim.api.nvim_set_current_win(assert(s.term_win)) end)
  for _, key in ipairs({ "<C-u>", "<C-d>" }) do
    map(buf, { "n", "i" }, key, function()
      vim.api.nvim_win_call(assert(s.term_win), function() vim.cmd.normal({ vim.keycode(key), bang = true }) end)
    end)
  end
end

---@param buf integer
local function output_keymaps(buf)
  -- On a link, cd into a directory, or edit a file in this window, in place of
  -- the shell; elsewhere as usual.
  map(buf, "n", "<CR>", function()
    local path = link_at_cursor()
    if not path then
      vim.api.nvim_feedkeys(vim.keycode("<CR>"), "n", false)
    elseif vim.fn.isdirectory(path) == 1 then
      M.send({ "cd " .. haskell_string(path) })
    else
      vim.cmd.edit(vim.fn.fnameescape(path))
    end
  end)
  -- Add a link's path to the end of the prompt.
  map(buf, "n", "<C-CR>", function()
    local path, pbuf = link_at_cursor(), assert(s.prompt_buf)
    if path then
      local last = vim.api.nvim_buf_line_count(pbuf)
      local line = vim.api.nvim_buf_get_lines(pbuf, last - 1, last, false)[1]
      vim.api.nvim_buf_set_lines(pbuf, last - 1, last, false, { line .. haskell_string(path) })
      vim.api.nvim_win_set_cursor(assert(s.prompt_win), { last, 0 })
      M.focus_prompt()
    end
  end)
  -- Typing goes to the prompt, unless a program has the keys.
  for _, key in ipairs({ "i", "a", "I", "A" }) do
    map(buf, "n", key, function()
      if s.took then
        vim.cmd.startinsert()
      else
        M.focus_prompt()
      end
    end)
  end
end

--- Show shhell in the current window, with the prompt below it. Showing
--- another buffer there closes the prompt.
function M.open()
  if s.prompt_win and vim.api.nvim_win_is_valid(s.prompt_win) then
    vim.api.nvim_set_current_win(s.prompt_win)
    return M.focus_prompt()
  end
  if s.job then
    vim.api.nvim_win_set_buf(0, assert(s.term_buf))
  else
    vim.cmd.enew()
    s.term_buf = vim.api.nvim_get_current_buf()
    -- The most Neovim keeps. Once it is full, Neovim moves lines without
    -- saying, and links stop working.
    vim.bo.scrollback = 100000
    vim.api.nvim_create_autocmd("TermRequest", { buffer = s.term_buf, callback = on_request })
    vim.api.nvim_create_autocmd("BufWinLeave", {
      buffer = s.term_buf,
      callback = function(ev)
        if ev.buf == s.term_buf then
          s.term_win = nil
          local win = s.prompt_win
          vim.schedule(function() pcall(vim.api.nvim_win_close, win, true) end)
        end
      end,
    })
    local timer = assert(vim.uv.new_timer())
    s.job = vim.fn.jobstart(config.cmd, {
      term = true,
      on_exit = function()
        s.job = nil
        timer:close()
      end,
    })
    timer:start(100, 100, vim.schedule_wrap(watch))
    output_keymaps(s.term_buf)
  end
  s.term_win = vim.api.nvim_get_current_win()

  if not (s.prompt_buf and vim.api.nvim_buf_is_valid(s.prompt_buf)) then
    s.prompt_buf = vim.api.nvim_create_buf(false, true)
    -- Haskell highlighting, without the filetype, which would start a language server.
    pcall(vim.treesitter.start, s.prompt_buf, "haskell")
    prompt_keymaps(s.prompt_buf)
  end
  vim.cmd("belowright " .. config.height .. "split")
  s.prompt_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(s.prompt_win, s.prompt_buf)
  vim.wo.winfixheight = true
  M.focus_prompt()
end

---@param opts? {cmd?: string[], height?: integer}
function M.setup(opts)
  config = vim.tbl_extend("force", config, opts or {})
  vim.api.nvim_create_user_command("Shhell", M.open, {})
end

M._state = s -- For the tests.

return M
