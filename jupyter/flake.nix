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

        KernelsDir = ".jupyter/kernels";

        pyKernel = pkgs.python3.withPackages (p:
          with p; [
            #jupyter
            #ipykernel
            ptpython
            bpython
            pandas
          ]);

        rKernel = pkgs.radianWrapper.override {
          packages = with pkgs.rPackages; [
            #IRkernel
            #rvisidata
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
          buildInputs = [pyKernel rKernel];
          shellHook =
            /*
            bash
            */
            ''
              ## Set up R kernel
              ## Ensure an 'ir' folder exists in 'KernelsDir':
              #mkdir -p "${KernelsDir}/ir"
              ## Copy the files using interpolation
              #cp -r ${pkgs.rPackages.IRkernel}/library/IRkernel/kernelspec/* "${KernelsDir}/ir"
              ## Add write permission
              #chmod -R u+w "${KernelsDir}/ir"
              ## set up Jupyter to look for kernels in the '.jupyter' dir:
              #export JUPYTER_PATH="$PWD/.jupyter"

              ## Install python kernel
              #python -m ipykernel install --user --name ipython


              #jupyter console --kernel="ir" -f /tmp/irKernel.json
              #jupyter console --kernel="ipython" -f /tmp/pyKernel.json
            '';
          exitHook = ''
            #jupyter kernelspec remove -f ir || true
            #rm /tmp/irKernel.json
            #jupyter kernelspec remove -f ipython || true
            #rm /tmp/pyKernel.json
            #rm -rf ~/.local/share/jupyter/kernels/ipython
          '';
        };
      }
    );
}
