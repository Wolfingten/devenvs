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

        pyKernel = pkgs.python3.withPackages (p:
          with p; [
            jupyter
            ipykernel
          ]);

        definitions = {
          ipython = {
            displayName = "Python";
            language = "python";
            logo32 = "";
            logo64 = "";
            argv = [
              "${pyKernel}/bin/python3"
              "-m"
              "ipykernel_launcher"
              "-f"
              "{connection_file}"
            ];
          };
        };
        jupyter = pkgs.jupyter-all.override {inherit definitions;};
      in {
        packages = {inherit jupyter;};
        packages.default = jupyter;

        apps.python = {
          type = "app";
          program = "${jupyter}/bin/python";
        };

        apps.jupyter = {
          type = "app";
          program = "${jupyter}/bin/jupyter";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [pyKernel jupyter pkgs.python312Packages.jupyter-console];
          shellHook = ''
            python -m ipykernel install --user --name ipython
            jupyter console --kernel="ipython" -f /tmp/pyKernel.json
          '';
          exitHook = ''
            rm /tmp/pyKernel.json
            rm -rf ~/.local/share/jupyter/kernels/ipython
          '';
        };
      }
    );
}
