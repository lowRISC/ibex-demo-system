## Clock signal
set_property -dict { PACKAGE_PIN D15  IOSTANDARD LVCMOS33 } [get_ports { IO_CLK }]; # HS2 pin
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { IO_CLK }];

## Switches
# IO3-4:
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { SW[0] }]; #IO3
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { SW[1] }]; #IO4

## RGB LEDs
# HDR1-10:
set_property -dict { PACKAGE_PIN L1    IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[0]  }]; #HDR1
set_property -dict { PACKAGE_PIN M1    IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[1]  }]; #HDR2
set_property -dict { PACKAGE_PIN N1    IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[2]  }]; #HDR3
set_property -dict { PACKAGE_PIN T1    IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[3]  }]; #HDR4
set_property -dict { PACKAGE_PIN U1    IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[4]  }]; #HDR5
set_property -dict { PACKAGE_PIN V1    IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[5]  }]; #HDR6
set_property -dict { PACKAGE_PIN V4    IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[6]  }]; #HDR7
set_property -dict { PACKAGE_PIN V6    IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[7]  }]; #HDR8
set_property -dict { PACKAGE_PIN V7    IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[8]  }]; #HDR9
set_property -dict { PACKAGE_PIN V9    IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[9]  }]; #HDR10
# TRACEDATA0-1:
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[10] }]; #TRACEDATA0
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[11] }]; #TRACEDATA1

## LEDs
set_property -dict { PACKAGE_PIN R1    IOSTANDARD LVCMOS33 } [get_ports { LED[0] }];
set_property -dict { PACKAGE_PIN V2    IOSTANDARD LVCMOS33 } [get_ports { LED[1] }];
set_property -dict { PACKAGE_PIN V5    IOSTANDARD LVCMOS33 } [get_ports { LED[2] }];

set_property DRIVE 8 [get_ports LED*]

## UART
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports { UART_TX }]; #CW IO1
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { UART_RX }]; #CW IO2

set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports { IO_RST_N }];

