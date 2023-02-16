## Clock signal
set_property -dict { PACKAGE_PIN F5   IOSTANDARD LVCMOS33 } [get_ports { IO_CLK }]; # USB clock (96 MHz)
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { IO_CLK }];

## Switches
set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS33 } [get_ports { SW[0] }]; #IO_L12N_T1_MRCC_16 Sch=sw[0]
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { SW[1] }]; #IO_L13P_T2_MRCC_16 Sch=sw[1]
set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { SW[2] }]; #IO_L13N_T2_MRCC_16 Sch=sw[2]
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { SW[3] }]; #IO_L14P_T2_SRCC_16 Sch=sw[3]

## RGB LEDs
set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[0]  }]; #IO_L18N_T2_35 Sch=led0_b
set_property -dict { PACKAGE_PIN A13   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[1]  }]; #IO_L19N_T3_VREF_35 Sch=led0_g
set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[2]  }]; #IO_L19P_T3_35 Sch=led0_r
set_property -dict { PACKAGE_PIN C11   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[3]  }]; #IO_L20P_T3_35 Sch=led1_b
set_property -dict { PACKAGE_PIN C14   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[4]  }]; #IO_L21P_T3_DQS_35 Sch=led1_g
set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[5]  }]; #IO_L20N_T3_35 Sch=led1_r
set_property -dict { PACKAGE_PIN D13   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[6]  }]; #IO_L21N_T3_DQS_35 Sch=led2_b
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[7]  }]; #IO_L22N_T3_35 Sch=led2_g
set_property -dict { PACKAGE_PIN D16   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[8]  }]; #IO_L22P_T3_35 Sch=led2_r
set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[9]  }]; #IO_L23P_T3_35 Sch=led3_b
set_property -dict { PACKAGE_PIN F12   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[10] }]; #IO_L24P_T3_35 Sch=led3_g
set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[11] }]; #IO_L23N_T3_35 Sch=led3_r

## LEDs
set_property -dict { PACKAGE_PIN T2    IOSTANDARD LVCMOS33 } [get_ports { LED[0] }]; #IO_L24N_T3_35 Sch=led[4]
set_property -dict { PACKAGE_PIN T3    IOSTANDARD LVCMOS33 } [get_ports { LED[1] }]; #IO_25_35 Sch=led[5]
set_property -dict { PACKAGE_PIN T4    IOSTANDARD LVCMOS33 } [get_ports { LED[2] }]; #IO_L24P_T3_A01_D17_14 Sch=led[6]

set_property DRIVE 8 [get_ports LED*]

## UART
set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { UART_TX }]; #CW IO1
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { UART_RX }]; #CW IO2

set_property -dict { PACKAGE_PIN R1    IOSTANDARD LVCMOS33 } [get_ports { IO_RST_N }]; #IO_L16P_T2_35 Sch=ck_rst

