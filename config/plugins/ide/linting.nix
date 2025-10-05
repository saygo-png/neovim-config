{pkgs, ...}: {
  extraPackages = [
    pkgs.deadnix # Nix linter
    pkgs.statix # Nix linter
    pkgs.nodePackages.jsonlint
    pkgs.shellcheck
  ];

  plugins = {
    lint = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      lintersByFt = {
        json = ["jsonlint"];
        bash = ["shellcheck"];
        shell = ["shellcheck"];
        nix = ["nix" "deadnix" "statix"];
      };
    };
  };
}
