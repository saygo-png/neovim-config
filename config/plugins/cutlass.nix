{
  plugins = {
    cutlass-nvim = {
      enable = true;
      settings = {
        override_del = true;
        exclude = ["ns" "nS" "nx" "nX" "nxx" "nX" "vx" "vX" "xx" "xX"];
        registers = {
          select = "s";
          delete = "d";
          change = "c";
        };
      };
    };
  };
}
