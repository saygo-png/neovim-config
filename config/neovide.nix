{lib, ...}: {
  globals = {
    neovide_refresh_rate = 144;
    neovide_normal_opacity = 0.5;
    neovide_floating_shadow = false;
    neovide_cursor_smooth_blink = true;
    neovide_floating_blur_amount_x = 20.0;
    neovide_floating_blur_amount_y = 20.0;
    neovide_padding_top = lib.mkDefault 8;
    neovide_padding_left = lib.mkDefault 6;
    neovide_padding_right = lib.mkDefault 6;
    neovide_padding_bottom = lib.mkDefault 0;
    neovide_cursor_animate_command_line = true;
    neovide_cursor_animate_in_insert_mode = true;
  };
}
