# Ibex Rust stack
This a embedded Rust software stack for whom is enthusiast about Rust, embedded systems, RISC-V and open source.

## Installation
Install Rust:<https://www.rust-lang.org/tools/install>.

## Demos application
- [Hello world](demo/hello_world/README.md)
- [LED](demo/led/README.md)
  
## Running on the ARTY A7 FPGA
Before running, you need to build and load the bitstream to the board as described [here](../../README.md#building-fpga-bitstream).
```
cargo run --bin led
```