{pkgs, ...}: {
  extraPackages = [
    pkgs.deadnix # Nix linter
    pkgs.nodePackages.jsonlint
    pkgs.hlint # Haskell linter
    pkgs.statix # Another linter
    pkgs.isort # Python import sorter
    pkgs.markdownlint-cli # Markdown linter
  ];

  plugins = {
    lint = {
      enable = true;
      lazyLoad.settings.event = "DeferredUIEnter";
      lintersByFt = {
        c = ["clangtidy"];
        cpp = ["clangtidy"];
        haskell = ["hlint"];
        json = ["jsonlint"];
        bash = ["shellcheck"];
        shell = ["shellcheck"];
        nix = ["nix" "deadnix" "statix"];
        dockerfile = ["hadolint"];
        markdown = ["markdownlint"];
      };
    };
  };
}
