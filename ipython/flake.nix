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
            ptpython
            bpython
            pandas
          ]);
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [pyKernel];
          shellHook =
            /*
            bash
            */
            ''
              alias python="ptpython"
            '';
          exitHook = ''
          '';
        };
      }
    );
}
