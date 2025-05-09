{
  description = "Flake to install Jupyter with an interactive R kernel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        rKernel = pkgs.radianWrapper.override {
          packages = with pkgs.rPackages; [
            tidyr
            dplyr
            readr
            lme4
            brms
            loo
            tidybayes
            matrixStats
            jmuOutlier
            plotrix
            ggplot2
          ];
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [rKernel];
          shellHook =
            /*
            bash
            */
            ''
              alias R="radian"
            '';
          exitHook = ''
          '';
        };
      }
    );
}
