{
  description = "A lychee flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  inputs.lychee-src.url = "github:lycheeverse/lychee";
  #inputs.lychee-src.url = "https://github.com/lycheeverse/lychee/archive/refs/heads/master.tar.gz";
  inputs.lychee-src.flake = false;

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    lychee-src,
  }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
      version = (lib.importTOML "${lychee-src}/Cargo.toml").workspace.package.version + "-nightly";
      lychee = pkgs.lychee.overrideAttrs (drv: {
        name = "lychee-${version}";
        inherit version;
        src = lychee-src;
        cargoDeps = drv.cargoDeps.overrideAttrs (_: {
          src = lychee-src;
          outputHash = "sha256-Edosx1jIFmFkrIsYNoIH/rTs0qkuGL8minm8mShNLxE=";
        });
        checkFlags = drv.checkFlags ++ [
            "--skip=formatters::response::color::tests::test_format_response_with_error_status"
            "--skip=formatters::response::color::tests::test_format_response_with_ok_status"
        ];
      });
    in
    {
      packages.default = lychee;
      packages.lychee = lychee;
    });
}
