{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
    pyKernel = pkgs.python3.withPackages (p:
      with p; [
        jupyter
        ipykernel
      ]);
  in {
    devShells.${system}.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        pyKernel
      ];
      shellHook = ''
        ${pyKernel}/bin/python3 -m ipykernel install --user --name pyKernel
      '';
    };
  };
}
