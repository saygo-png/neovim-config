{pkgs, ...}: {
  extraPackages = [
    pkgs.dotnet-sdk
  ];

  plugins.roslyn = {
    enable = true;
  };
}
