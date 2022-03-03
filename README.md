# Ibex Super System

This an example RISC-V SoC targetting the Arty-A7 FPGA board. It comprises the
[lowRISC Ibex core](https://www.github.com/lowrisc/ibex) along with the
following features:

* RISC-V debug support (using the [PULP RISC-V Debug Module](https://github.com/pulp-platform/riscv-dbg))
* A UART (transmit only for now)
* GPIO (output only for now)

Debug can be used via a USB connection to the Arty-A7 board. No external JTAG
probe is required.

## Building

FuseSoC handles the build

```
fusesoc --verbose --cores-root=. run --target=synth --setup --build lowrisc:ibex:super_system
```
