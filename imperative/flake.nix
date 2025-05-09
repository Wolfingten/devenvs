{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    tokenizers.url = "github:nixos/nixpkgs/e2b8feae8470705c3f331901ae057da3095cea10";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };

    oldTokenizers = import inputs.tokenizers {
      inherit system;
    };

    pythonEnv = pkgs.python311.withPackages (p:
      with p; [
        pip
        virtualenv
      ]);

    fhsEnv = pkgs.buildFHSUserEnv {
      name = "python-fhs";
      targetPkgs = pkgs:
        with pkgs; [
          pythonEnv
          libGL
          zlib
          stdenv.cc.cc
          glibc
          gcc
          openssl
          rustc
          cargo
          cmake
          pkg-config
        ];

      profile =
        /*
        bash
        */
        ''
          export PKG_CONFIG_PATH=${pkgs.openssl.dev}/lib/pkgconfig
          export VENV=.venv
          if [ ! -d "$VENV" ]; then
            python -m venv $VENV
          fi
          source $VENV/bin/activate
        '';

      runScirpt = "bash";
    };
  in {
    devShells.${system}.default = fhsEnv.env;
  };
}
