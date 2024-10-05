{
  description = "Haskell libsodium library";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  outputs = { self, nixpkgs }:
    let
      pkgsOverlay = pself: psuper: {
        haskell = psuper.haskell // {
          packageOverrides = hself: hsuper: {
            libsodium = hself.callPackage ./. { libsodium = pself.libsodium; };
          };
        };
      };
      pkgsFor = system:
        import nixpkgs {
          inherit system;
          overlays = [ pkgsOverlay ];
        };

    in {
      packages =
        nixpkgs.lib.genAttrs [ "x86_64-linux" "i686-linux" "aarch64-linux" ]
        (system:
          let pkgs = pkgsFor system;
          in {
            default = pkgs.releaseTools.aggregate {
              name = "every output from this flake";
              constituents = let
                p = self.packages.${system};
                s = self.devShells.${system};
              in [
                p.libsodium__ghcDefault
                p.libsodium__ghc92
                p.libsodium__ghc94

                p.libsodium__ghcDefault.doc
                p.libsodium__ghc92.doc
                p.libsodium__ghc94.doc

                s.libsodium__ghcDefault
                s.libsodium__ghc92
                s.libsodium__ghc94
              ];
            };
            libsodium__ghcDefault = pkgs.haskellPackages.libsodium;
            libsodium__ghc92 = pkgs.haskell.packages.ghc92.libsodium;
            libsodium__ghc94 = pkgs.haskell.packages.ghc94.libsodium;
          });
      devShells =
        nixpkgs.lib.genAttrs [ "x86_64-linux" "i686-linux" "aarch64-linux" ]
        (system:
          let
            pkgs = pkgsFor system;
            mkShellFor = hpkgs:
              hpkgs.shellFor {
                packages = p: [ p.libsodium ];
                withHoogle = true;
                nativeBuildInputs = [ pkgs.cabal-install pkgs.cabal2nix ];
              };
          in {
            default = self.devShells.${system}.libsodium__ghc94;
            libsodium__ghcDefault = mkShellFor pkgs.haskellPackages;
            libsodium__ghc92 = mkShellFor pkgs.haskell.packages.ghc92;
            libsodium__ghc94 = mkShellFor pkgs.haskell.packages.ghc94;
          });
    };
}
