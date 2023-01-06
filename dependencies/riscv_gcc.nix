{ # Chosen toolchain subarchitecture, e.g. 'rv32imc'
  riscv-arch

  # Package set
, pkgs
}:

# --------------------------
# RISC-V GCC Toolchain Setup

let
  riscv-toolchain-ver = "8.2.0";
  riscv-src = pkgs.fetchFromGitHub {
    owner  = "lowRISC";
    repo   = "lowrisc-toolchains";
    rev    = "2cac2b9797d96a5c46d86d463c71e0a66926f473";
    sha256 = "sha256-DNEkdJ5G8wpN2nQbD+nzvAQixWWGCG5RbJrXg5IRteg=";
  };
  #
  # given an architecture like 'rv32i', this will generate the given
  # toolchain derivation based on the above source code.
  make-riscv-toolchain = arch:
    pkgs.stdenv.mkDerivation rec {
      name    = "riscv-${arch}-toolchain-${version}";
      version = "${riscv-toolchain-ver}-${builtins.substring 0 7 src.rev}";
      src     = riscv-src;

      configureFlags   = [ "--with-arch=${arch}" ];
      installPhase     = ":"; # 'make' installs on its own
      # installPhase = ''
      #   mkdir -p $out
      #   cp -r * $out
      # '';
      hardeningDisable = [ "all" ];
      enableParallelBuilding = true;

      # Stripping/fixups break the resulting libgcc.a archives, somehow.
      # Maybe something in stdenv that does this...
      dontStrip = true;
      dontFixup = true;

      nativeBuildInputs = with pkgs; [ curl gawk texinfo bison flex gperf ];
      buildInputs = with pkgs; [ libmpc mpfr gmp expat ];
    };

in make-riscv-toolchain riscv-arch
