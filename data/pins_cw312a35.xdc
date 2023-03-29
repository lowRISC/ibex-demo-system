## Clock signal
set_property -dict { PACKAGE_PIN D15  IOSTANDARD LVCMOS33 } [get_ports { IO_CLK }]; # HS2 pin
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { IO_CLK }];

## Switches
# IO3-4:
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { IO3 }]; #IO3
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { IO4 }]; #IO4

## LEDs
set_property -dict { PACKAGE_PIN R1    IOSTANDARD LVCMOS33 } [get_ports { LED[0] }];
set_property -dict { PACKAGE_PIN V2    IOSTANDARD LVCMOS33 } [get_ports { LED[1] }];
set_property -dict { PACKAGE_PIN V5    IOSTANDARD LVCMOS33 } [get_ports { LED[2] }];

set_property DRIVE 8 [get_ports LED*]

## UART
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports { UART_TX }]; #CW IO1
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { UART_RX }]; #CW IO2

set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports { IO_RST_N }];

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

