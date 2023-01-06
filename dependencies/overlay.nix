final: prev: {
  riscv-gcc-toolchain-lowrisc = prev.callPackage ./riscv-gcc-toolchain-lowrisc.nix {};
  riscv-isa-sim = prev.callPackage ./riscv-isa-sim.nix {};
}
