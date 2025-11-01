{
  description = "Haskell libsodium library";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
                p.libsodium__ghc94
                p.libsodium__ghc96
                p.libsodium__ghc98
                p.libsodium__ghc910

                p.libsodium__ghcDefault.doc
                p.libsodium__ghc94.doc
                p.libsodium__ghc96.doc
                p.libsodium__ghc98.doc
                p.libsodium__ghc910.doc

                s.libsodium__ghcDefault
                s.libsodium__ghc94
                s.libsodium__ghc96
                s.libsodium__ghc98
                s.libsodium__ghc910
              ];
            };
            libsodium__ghcDefault = pkgs.haskellPackages.libsodium;
            libsodium__ghc94 = pkgs.haskell.packages.ghc94.libsodium;
            libsodium__ghc96 = pkgs.haskell.packages.ghc96.libsodium;
            libsodium__ghc98 = pkgs.haskell.packages.ghc98.libsodium;
            libsodium__ghc910 = pkgs.haskell.packages.ghc910.libsodium;
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
            default = self.devShells.${system}.libsodium__ghc910;
            libsodium__ghcDefault = mkShellFor pkgs.haskellPackages;
            libsodium__ghc94 = mkShellFor pkgs.haskell.packages.ghc94;
            libsodium__ghc96 = mkShellFor pkgs.haskell.packages.ghc96;
            libsodium__ghc98 = mkShellFor pkgs.haskell.packages.ghc98;
            libsodium__ghc910 = mkShellFor pkgs.haskell.packages.ghc910;
          });
    };
}
