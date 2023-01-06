{ pkgs, lib, stdenv,
  fetchzip, zlib, ncurses5,
}:

# Used for reference...
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/compilers/gcc-arm-embedded/10/default.nix

stdenv.mkDerivation rec {
  name = "riscv-gcc-toolchain";
  version = "20220210-1";
  src = fetchzip {
    url = "https://github.com/lowRISC/lowrisc-toolchains/releases/download/${version}/lowrisc-toolchain-gcc-rv32imc-${version}.tar.xz";
    sha256 = "1m708xfdzf3jzclm2zw51my3nryvlsfwqkgps3xxa0xnhq4ly1bl";
  };

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true; # We will do this manually in preFixup
  dontStrip = true;

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';
  preFixup = ''
    find $out -type f ! -name ".o" | while read f; do
      patchelf "$f" > /dev/null 2>&1                                                             || continue
      patchelf --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) "$f"             || true
      patchelf --set-rpath ${lib.makeLibraryPath [ "$out" stdenv.cc.cc ncurses5 ]} "$f" || true
    done
  '';
}
