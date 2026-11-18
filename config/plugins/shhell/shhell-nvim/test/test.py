#!/usr/bin/env python3
"""Runs shhell.nvim in a headless Neovim and drives it like a user, with keys
sent over RPC.

usage: test.py <nvim> <directory with "file two.txt" and "dir one/three.txt">
"""
import os, subprocess, sys, tempfile, time

NVIM, FILES = sys.argv[1:3]
SOCK = os.path.join(tempfile.mkdtemp(), "nvim.sock")
HELPERS = """
local sh = require('shhell')
function _G.where()
  local w = vim.api.nvim_get_current_win()
  local name = w == sh._state.prompt_win and 'prompt' or w == sh._state.term_win and 'output' or 'other'
  return name .. ' ' .. vim.api.nvim_get_mode().mode
end
function _G.output()
  return table.concat(vim.api.nvim_buf_get_lines(sh._state.term_buf, 0, -1, false), '\\n')
end
function _G.cursor_to(text)
  vim.fn.search(text, 'bw')
end
"""
nvim = subprocess.Popen([NVIM, "--headless", "--clean", "--listen", SOCK, "--cmd", "set rtp^=. lines=50 columns=160",
                         "-c", "lua require('shhell').setup()" + HELPERS + "require('shhell').open()"])
failures = 0


def expr(e):
    return subprocess.run([NVIM, "--server", SOCK, "--remote-expr", e], capture_output=True, text=True).stdout


def keys(k):
    subprocess.run([NVIM, "--server", SOCK, "--remote-send", k])


def wait(cond, secs=10):
    end = time.time() + secs
    while time.time() < end:
        if cond():
            return True
        time.sleep(0.1)
    return False


def check(ok, what):
    global failures
    failures += not ok
    print("ok  " if ok else "FAIL", what, "" if ok else f"({expr('v:lua.where()')})")


def where(w):
    return lambda: expr("v:lua.where()") == w


def shows(text):
    return lambda: text in expr("v:lua.output()")


check(wait(shows("@"), 120) and wait(where("prompt i")), "starts in the prompt, in insert mode")

keys('putStrLn "hello"<CR>')
check(wait(shows("\nhello")), "<CR> runs the command")
check(where("prompt i")(), "and the prompt keeps the keys")

def height():
    return expr("winheight(0)")


check(height() == "1", "the prompt is one line")
keys('do putStrLn "multi"<M-CR>   putStrLn "line"')
check(wait(lambda: height() == "2"), "and grows with what is typed")
keys("<CR>")
check(wait(shows("multi\nline")), "<M-CR> makes a multi-line command")
check(wait(lambda: height() == "1"), "sending it shrinks the prompt back")

keys("<Esc>")
check(wait(where("prompt n")), "<Esc> goes to normal mode")
keys("<Esc>")
check(wait(where("output nt")), "<Esc> again goes to the output")
keys("i")
check(wait(where("prompt i")), "i there goes back to the prompt")

keys('exe "btop"<CR>')
check(wait(where("output t")), "btop gets the keys")
keys("q")
check(wait(where("prompt i")), "and gives them back when it quits")

keys('exe "sleep" "60"<CR>')
time.sleep(1)
keys("<C-c>putStrLn \"interrupted\"<CR>")
check(wait(shows("\ninterrupted")), "<C-c> interrupts")

keys(f'cd "{FILES}"<CR>eza "--hyperlink=always"<CR>')
check(wait(shows("file two.txt")), "eza prints links")
time.sleep(0.5)
keys("<Esc><Esc>")
wait(where("output nt"))
expr("v:lua.cursor_to('two')")
keys("<C-CR>")
check(wait(lambda: expr("getline(1)") == '"file two.txt"'), "<C-CR> puts a link in the prompt")
keys("<Esc><Esc>")
wait(where("output nt"))
expr("v:lua.cursor_to('dir one')")
before = expr("string(getpos('.'))")
keys("<CR>")
check(wait(lambda: expr("luaeval('require(\"shhell\")._state.cwd')").endswith("/dir one")), "<CR> on a directory goes there")
check(wait(shows("three.txt")), "and lists it")
check(expr("string(getpos('.'))") == before, "the cursor stays where it was")

keys(f'i<Esc>cccd "{FILES}"<CR><Esc><Esc>')
wait(where("output nt"))
expr("v:lua.cursor_to('two')")
keys("<CR>")
check(wait(lambda: expr("expand('%:t')") == "file two.txt" and expr("winnr('$')") == "1"),
      "<CR> on a file edits it in place of the shell")
keys(":Shhell<CR>")
check(wait(where("prompt i")) and shows("\ninterrupted")(), ":Shhell brings both back")

nvim.kill()
print(f"{failures} failed" if failures else "all passed")
sys.exit(failures > 0)
