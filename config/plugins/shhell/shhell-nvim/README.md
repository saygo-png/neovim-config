# shhell.nvim (prototype)

shhell in a Neovim terminal, with commands typed in a prompt buffer below it.
`:Shhell` shows both in the current window; showing another buffer there closes
the prompt. The prompt grows with what you type, up to 20 lines. The output is
an ordinary terminal buffer, which follows what is printed while its cursor is
on the last line.

```lua
require("shhell").setup() -- optional: { cmd = { "shhell" } }
vim.keymap.set({ "n", "x" }, "<leader>ss", require("shhell").send_from_buffer)
```

Then `:Shhell`.

## Keys

In the prompt:

| Key | |
|---|---|
| `<CR>` | send; several lines go as one `:{ :}` block |
| `<M-CR>` (insert) | new line |
| `<C-c>` | interrupt |
| `<C-u>` / `<C-d>` | scroll the output |
| `<Esc>` (normal) | go to the output |

In the output, `i`, `a`, `I` and `A` go back to the prompt. On a link that a
program printed (`eza --hyperlink=always`, `ls --hyperlink=always`, `fd
--hyperlink`), `<CR>` sends `cd "dir"` and `ls` for a directory, and opens a
file in place of the shell, which `:Shhell` brings back. `<C-CR>` adds the path
to the prompt. Paths are relative to the shell's directory when it reports it
(OSC 7, which `shhellPrompt` does).

A program that wants the keys, like btop, fzf, nvim or a password prompt, gets
them while it does: the plugin sees the shell's child turn off the terminal's
line editing or echo.

## Test

btop and eza must be on `PATH`, and the directory must hold `file two.txt` and
`dir one/three.txt`:

```
python3 test/test.py nvim <directory>
```
