# LED

This is a interactive demo application that light the LEDs based on the the buttons pressed on the ARTY A7 board while outputs the logs via UART.

## How to build and load
1. Build and Load the bistream as described [here](../../../../README.md#building-fpga-bitstream).
2. Connect to UART to see the console.
    ```sh
    screen /dev/ttyUSB1 115200
    ```
3. Build and load the application
    ```
    cargo run
    ```