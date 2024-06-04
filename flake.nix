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
        ringer = naersk'.buildPackage { src = ./.; };
      in rec {
        packages.ringer = ringer;

        packages.default = packages.ringer;

        devShell =
          pkgs.mkShell { nativeBuildInputs = with pkgs; [ rustc cargo ]; };

      }) // {
        nixosModules = {
          ringer = { config, lib, ringer, ... }:
            let cfg = config.services.ringer.enable;
            in rec {
              options = {
                enable = lib.mkOption {
                  default = true;
                  example = true;
                  type = lib.types.bool;

                  description = ''
                    Enable ringer service
                  '';
                };

                config = lib.mkIf config.enable {
                  systemd.sockets.ringer = {
                    enable = true;
                    wantedBy = [ "sockets.target" ];
                    socketConfig = {
                      ListenStream = 79;
                      Accept = "yes";
                    };
                  };

                  systemd.services."ringer@" = {
                    enable = true;
                    description = "Ringer service";
                    requires = [ "ringer.socket" ];

                    serviceConfig = {
                      DynamicUser = "yes";
                      ProtectHome = "true";
                      ExecStart = "-${ringer}/bin/fingerd";
                      StandardInput = "socket";
                      StandardOutput = "socket";
                      StateDirectory = "ringer";
                    };
                  };
                };
              };
            };

          default = { self, pkgs, ... }: {
            imports = [ self.nixosModules.ringer ];
            services.ringer = { enable = true; };
          };
        };
      };
}
