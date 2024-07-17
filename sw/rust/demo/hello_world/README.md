# Hello world

This demo prints a `Hello world` string to the JTAG semihosting interface.

How to run this demo:
1. Build and load a [IBEX bitstream](../../../../README.md#Building-FPGA-bitstream)
2. Build and load the demo with `cargo run`.
3. Connect [openocd](../../../../README.md#Debugging-an-application) 
4. Run the gdb:

```console
$ riscv32-unknown-elf-gdb ../../target/riscv32imc-unknown-none-elf/debug/led

(gdb) # Connect to OpenOCD
(gdb) target remote :3333

(gdb) # Enable OpenOCD's semihosting support
(gdb) monitor arm semihosting enable

(gdb) # Flash the program
(gdb) load

(gdb) # Run the program
(gdb) continue
```
The log will show up on the openocd console (Step 3).
