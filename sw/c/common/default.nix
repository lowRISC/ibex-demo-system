{
  rules,
  pkgs,
  lowrisc-toolchain-gcc-rv32imcb,
}: let
  toolchain = rec {
    cc = "${lowrisc-toolchain-gcc-rv32imcb}/bin/riscv32-unknown-elf-gcc";
    cflags = ["-march=rv32imc" "-mabi=ilp32" "-mcmodel=medany" "-Wall" "-fvisibility=hidden" "-ffreestanding"];
    ld = cc;
    ldflags = ["-nostartfiles" "-T" "${../../common/link.ld}"];
    asm = cc;
    asmflags = ["-march=rv32imc"];
  };

  rules_cc = rules.cc.override {
    inherit toolchain;
  };

  passthru = with rules_cc; rec {
    inherit toolchain rules_cc;

    crt0 = asm {
      src = ./crt0.S;
      deps = [./demo_system_regs.h];
    };

    gpio = object {
      src = ./gpio.c;
      deps = [./gpio.h ./uart.h ./dev_access.h ./demo_system.h ./demo_system_regs.h];
      extra-cflags = ["-O3"];
    };

    uart = object {
      src = ./uart.c;
      deps = [./gpio.h ./uart.h ./dev_access.h ./demo_system.h ./demo_system_regs.h];
    };

    pwm = object {
      src = ./pwm.c;
      deps = [./gpio.h ./uart.h ./pwm.h ./dev_access.h ./demo_system.h ./demo_system_regs.h];
    };

    spi = object {
      src = ./spi.c;
      deps = [./gpio.h ./uart.h ./spi.h ./dev_access.h ./demo_system.h ./demo_system_regs.h];
    };

    timer = object {
      src = ./timer.c;
      deps = [./gpio.h ./uart.h ./timer.h ./dev_access.h ./demo_system.h ./demo_system_regs.h];
    };

    demo_system = object {
      src = ./demo_system.c;
      deps = [./gpio.h ./uart.h ./dev_access.h ./demo_system.h ./demo_system_regs.h];
    };

    common = static {
      name = "common.a";
      deps = [crt0 gpio uart pwm spi timer ./demo_system.c] ++ [./gpio.h ./uart.h ./timer.h ./spi.h ./pwm.h ./dev_access.h ./demo_system.h ./demo_system_regs.h];
    };
  };
in
  passthru.common // passthru
