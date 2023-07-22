{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    naersk.url = "github:nix-community/naersk";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        naersk' = pkgs.callPackage naersk { };
      in rec {
        defaultPackage = naersk'.buildPackage { src = ./.; };

        devShell =
          pkgs.mkShell { nativeBuildInputs = with pkgs; [ rustc cargo ]; };
      });
}
