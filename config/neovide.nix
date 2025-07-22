{lib, ...}: {
  extraConfigLua =
    lib.mkBefore
    # lua
    ''
      -- Neovide
      if vim.g.neovide then
        vim.cmd[[colorscheme gruvbox]]
        vim.o.background = 'dark'
        vim.o.guifont = 'Courier Prime:h13:#e-antialias:#h-slight'
        vim.cmd [[ hi Normal guibg=#282828} ]]
      end
    '';

  globals = {
    neovide_transparency = 0.5;
    neovide_transparency_point = 0;
    neovide_background_color = "#282828";
    neovide_padding_top = lib.mkDefault 8;
    neovide_padding_bottom = lib.mkDefault 0;
    neovide_padding_right = lib.mkDefault 6;
    neovide_padding_left = lib.mkDefault 6;
    neovide_floating_blur_amount_x = 20.0;
    neovide_floating_blur_amount_y = 20.0;
    neovide_hide_mouse_when_typing = true;
    neovide_refresh_rate = 144;
    neovide_cursor_vfx_mode = "ripple";
    neovide_cursor_animation_length = 0.08;
    neovide_cursor_smooth_blink = true;
    neovide_floating_shadow = false;
    neovide_cursor_animate_command_line = true;
    neovide_cursor_animate_in_insert_mode = true;
  };
}
