{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-python = {
      url = "github:cachix/nixpkgs-python";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    devenv,
    ...
  }: let
    system = "x86_64-linux";
    #    pkgs = nixpkgs.legacyPackages.${system};
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        #        cudaSupport = true;
      };
    };
  in {
    devShells.${system}.default = devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [
        ({
          pkgs,
          config,
          ...
        }: {
          # This is your devenv configuration
          # for options see https://devenv.sh/reference/options/
          packages = with pkgs; [
            cudaPackages.cudatoolkit
            # from https://github.com/cachix/devenv/issues/1264#issuecomment-2368362686
            stdenv.cc.cc.lib # required by jupyter
            gcc-unwrapped # fix: libstdc++.so.6: cannot open shared object file
            libz # fix: for numpy/pandas import
            jupyter-all
          ];

          languages.python = {
            enable = true;
            #  venv = {
            #    enable = true;
            #    requirements = ["wordfreq"];
            #  };
          };

          languages.r = {
            enable = true;
            package = pkgs.rstudioWrapper.override {
              packages = with pkgs.rPackages; [
                IRkernel
                tidyr
                dplyr
                purrr
                lme4
                jmuOutlier
                plotrix
                ggplot2
              ];
            };
          };

          # for cuda support
          # https://discourse.nixos.org/t/pytorch-installed-via-pip-does-not-pick-up-cuda/30744/2
          # https://github.com/clementpoiret/nix-python-devenv/blob/main/flake.nix
          env.LD_LIBRARY_PATH = "${pkgs.gcc-unwrapped.lib}/lib64:${pkgs.libz}/lib:/run/opengl-driver/lib:/run/opengl-driver-32/lib";

          enterShell = ''
            ${pkgs.jupyter-all}/bin/jupyter kernelspec install ${pkgs.rPackages.IRkernel}/library/IRkernel/kernelspec --user --name r-2
            # Capture the kernel JSON path generated by previous command
            KERNEL_FILE=$(find /home/wolfingten/.local/share/jupyter -name "kernel*.json" | head -n 1)
            # Create a symlink to the runtime directory
            mkdir -p /home/wolfingten/.local/share/jupyter/runtime
            ln -sf "$KERNEL_FILE" /home/wolfingten/.local/share/jupyter/runtime/$(basename "$KERNEL_FILE")
          '';
        })
      ];
    };
  };
}
