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

        rKernel = pkgs.rWrapper.override {
          packages = with pkgs.rPackages; [
            IRkernel
          ];
        };

        definitions = {
          ir = {
            displayName = "R";
            language = "r";
            logo32 = "";
            logo64 = "";
            argv = [
              "${rKernel}/bin/R"
              "--slave"
              "-e"
              "IRkernel::main()"
              "--args"
              "{connection_file}"
            ];
          };
        };
        jupyter = pkgs.jupyter-all.override {inherit definitions;};
      in {
        packages = {inherit jupyter;};
        packages.default = jupyter;

        apps.r = {
          type = "app";
          program = "${jupyter}/bin/R";
        };

        apps.jupyter = {
          type = "app";
          program = "${jupyter}/bin/jupyter";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [rKernel jupyter pkgs.python312Packages.jupyter-console];
          shellHook = ''
            jupyter console --kernel="ir" -f /tmp/irKernel.json
          '';
          exitHook = ''
            rm /tmp/irKernel.json
          '';
        };
      }
    );
}
