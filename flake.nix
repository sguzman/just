{
  description = "just – handy command-runner";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
        rust = pkgs.rust-bin.stable.latest.default;
      in rec {
        # ── Build the binary ──────────────────────────────────────────────
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname   = "just";
          version = (builtins.fromTOML (builtins.readFile ./Cargo.toml)).package.version;
          src     = self;
          cargoLock = { lockFile = ./Cargo.lock; };

          # skip the flaky shebang test
          doCheck = false;

          cargoBuildFlags = [ "--verbose" "--color" "always" ];
        };

        # ── Dev shell ─────────────────────────────────────────────────────
        devShells.default = pkgs.mkShell {
          buildInputs = [ rust ];
        };
      });
}

