{ mkDerivation, lib, base, c2hs, hedgehog, libsodium, tasty, tasty-hedgehog
, tasty-hunit }:
mkDerivation {
  pname = "libsodium";
  version = "1.0.19.0";
  src = lib.sources.cleanSource ./.;
  libraryToolDepends = [ c2hs ];
  libraryHaskellDepends = [ base ];
  libraryPkgconfigDepends = [ libsodium ];
  testHaskellDepends = [ base hedgehog tasty tasty-hedgehog tasty-hunit ];
  testPkgconfigDepends = [ libsodium ];
  testToolDepends = [ c2hs ];
  homepage = "https://github.com/k0001/hs-libsodium";
  description = "Low-level bindings to the libsodium C library";
  license = lib.licenses.isc;
  doCheck = true;
  configureFlags = [ "--flags=-use-build-tool-depends" ];
}
