{
  inputs = {
    emanote.url = "github:srid/emanote";
    nixpkgs.follows = "emanote/nixpkgs";
    flake-utils.follows = "emanote/flake-utils";
    flake-compat.follows = "emanote/flake-compat";
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
    flake-compat-ci.url = "github:hercules-ci/flake-compat-ci";
  };

  outputs = { self, flake-utils, emanote, nixpkgs, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        defaultApp = apps.live;
        apps = {
          live = rec {
            type = "app";
            # '' is required for escaping ${} in nix
            script = pkgs.writeShellApplication {
              name = "emanoteRun.sh";
              text = ''
                set -xe
                export PORT="''${EMANOTE_PORT:-7072}"
                ${emanote.defaultPackage.${system}}/bin/emanote run --port "$PORT"
              '';
            };
            program = "${script}/bin/emanoteRun.sh";
          };
        };
        devShell = pkgs.mkShell {
          buildInputs = [ pkgs.nixpkgs-fmt ];
        };

        # Hercules CI support: https://hercules-ci.com/
        ciNix = args@{ src }: inputs.flake-compat-ci.lib.recurseIntoFlakeWith {
          flake = self;
          systems = [ "x86_64-linux" ];
          effectsArgs = args;
        };
      });
}
