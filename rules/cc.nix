{
  pkgs,
  lib,
  stdenv,
  toolchain ? {
    cc = "/no-toolchain-defined";
    cflags = [];
    ld = "/no-toolchain-defined";
    ldflags = [];
    asm = "/no-toolchain-defined";
    asmflags = [];
  },
}: let
  include = {
    src,
    deps ? [],
  }:
    pkgs.runCommandLocal (builtins.baseNameOf src) {} ''
      mkdir -p $out/include

      ARGS=()
      for dep in $deps; do
        if [ -d $dep/include ]; then
          ln -s $src/include/* $out/include/
        fi
      done

      ln -s ${src} $out/include/${builtins.baseNameOf src}
    '';

  # If a raw file path is specified, turn that into a header derivation.
  autowrap_header = f:
    if !(builtins.isPath f)
    then f
    else if lib.hasSuffix ".h" f
    then include {src = f;}
    else throw "unknown file type: ${f}";

  # Turn all raw file paths into derivations.
  # Files will be grouped so that source files can depend on header files.
  autowrap_deps = deps: let
    src = builtins.filter (f: builtins.isPath f && !(lib.hasSuffix ".h" f)) deps;
    other = builtins.filter (f: !(builtins.isPath f) || lib.hasSuffix ".h" f) deps;
    wrapped = map autowrap_header other;
    src_drv =
      map (
        f:
          if lib.hasSuffix ".S" f
          then
            asm {
              src = f;
              deps = wrapped;
            }
          else if lib.hasSuffix ".c" f
          then
            object {
              src = f;
              deps = wrapped;
            }
          else throw "unknown file type: ${f}"
      )
      src;
  in
    src_drv ++ wrapped;

  asm = {
    src,
    deps ? [],
    extra-asmflags ? [],
    asmflags ? toolchain.asmflags ++ extra-asmflags,
  }:
    stdenv.mkDerivation {
      name = (lib.removeSuffix ".S" (builtins.baseNameOf src)) + ".o";
      inherit src asmflags;
      inherit (toolchain) asm;
      deps = autowrap_deps deps;
      dontUnpack = true;
      buildPhase = ''
        ARGS=()
        for dep in $deps; do
          if [ -d $dep/include ]; then
            ARGS+=(-I$dep/include)
          fi
        done

        mkdir -p $out/obj
        $asm $asmflags -c -o $out/obj/$name $src ''${ARGS[@]}
      '';
    };

  object = {
    src,
    deps ? [],
    extra-cflags ? [],
    cflags ? toolchain.cflags ++ extra-cflags,
  }:
    stdenv.mkDerivation {
      name = (lib.removeSuffix ".c" (builtins.baseNameOf src)) + ".o";
      inherit src cflags;
      inherit (toolchain) cc;
      deps = autowrap_deps deps;
      dontUnpack = true;
      buildPhase = ''
        ARGS=()
        for dep in $deps; do
          if [ -d $dep/include ]; then
            ARGS+=(-I$dep/include)
          fi
        done

        mkdir -p $out/obj
        $cc $cflags -c -o $out/obj/$name $src ''${ARGS[@]}
      '';
    };

  static = {
    name,
    deps,
  }:
    stdenv.mkDerivation {
      inherit name;
      srcs = autowrap_deps deps;
      dontUnpack = true;
      buildPhase = ''
        ARGS=()
        for src in $srcs; do
          if [ -d $src/obj ]; then
            ARGS+=($src/obj/*)
          fi
          if [ -d $src/include ]; then
            mkdir -p $out/include
            ln -s $src/include/* $out/include/
          fi
        done

        mkdir -p $out/lib
        ar rcs $out/lib/$name ''${ARGS[@]}
      '';
    };

  binary = {
    name,
    deps ? [],
    extra-ldflags ? [],
    ldflags ? toolchain.ldflags ++ extra-ldflags,
  }:
    stdenv.mkDerivation {
      inherit name ldflags;
      inherit (toolchain) ld;
      srcs = autowrap_deps deps;
      dontUnpack = true;
      buildPhase = ''
        ARGS=()
        for src in $srcs; do
          if [ -d $src/obj ]; then
            ARGS+=($src/obj/*)
          fi
          if [ -d $src/lib ]; then
            ARGS+=($src/lib/*)
          fi
        done

        mkdir -p $out/bin
        $ld $ldflags -o $out/bin/$name ''${ARGS[@]}
      '';
    };

  set = deps:
    pkgs.symlinkJoin {
      name = "";
      paths = autowrap_deps deps;
    };
in {
  inherit asm include object static binary set;
}
