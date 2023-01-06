{ lib, stdenv, fetchFromGitHub,
  dtc
}:

stdenv.mkDerivation rec {
  name = "spike";
  pname = "riscv-isa-sim";
  version = "1.1.1-dev";

  src = fetchFromGitHub {
    owner = "riscv-software-src";
    repo = pname;
    rev = "ac466a21df442c59962589ba296c702631e041b5";
    sha256 = "sha256-1OLGEdj0dGnNREKZOrkAyKET7d2L+VFebOGm2oxtkHw=";
  };

  enableParallelBuilding = true;
  # buildInputs = [ ];
  nativeBuildInputs = [ dtc ];
  configureFlags = [ "--enable-commitlog" "--enable-misaligned" ];

  doCheck = false;
  dontInstall = false;

  meta = with lib; {
    description = "Riscv golden-reference simulator Spike";
    homepage    = "https://github.com/riscv-software-src/riscv-isa-sim";
    license     = with licenses; [];
    platforms   = platforms.unix;
    maintainers = with maintainers; [];
  };
}
