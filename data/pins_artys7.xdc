## Common constraints file for Arty S7-35 and S7-50.
## Based on https://github.com/Digilent/digilent-xdc/blob/master/Arty-S7-50-Master.xdc
## and modified for Ibex

## Clock signal
set_property -dict { PACKAGE_PIN R2    IOSTANDARD LVCMOS33 } [get_ports { IO_CLK }]; #IO_L12P_T1_MRCC_34 Sch=ddr3_clk[200]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5.000}  [get_ports { IO_CLK }];

## CPU Reset Button. Steal BTN[3] to make things work "out of the box"
#set_property -dict { PACKAGE_PIN C18    IOSTANDARD LVCMOS33 } [get_ports { IO_RST }]; #IO_L16P_T2_35 Sch=ck_rst
set_property -dict { PACKAGE_PIN H13   IOSTANDARD LVCMOS33 } [get_ports { IO_RST }]; #IO_L20P_T3_A20_15 Sch=btn[3]

## Switches
set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVCMOS33 } [get_ports { SW[0] }]; #IO_L20N_T3_A19_15 Sch=sw[0]
set_property -dict { PACKAGE_PIN H18   IOSTANDARD LVCMOS33 } [get_ports { SW[1] }]; #IO_L21P_T3_DQS_15 Sch=sw[1]
set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { SW[2] }]; #IO_L21N_T3_DQS_A18_15 Sch=sw[2]
set_property -dict { PACKAGE_PIN M5    IOSTANDARD LVCMOS33 } [get_ports { SW[3] }]; #IO_L6N_T0_VREF_34 Sch=sw[3]

## LEDs
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { LED[0] }]; #IO_L16N_T2_A27_15 Sch=led[2]
set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports { LED[1] }]; #IO_L17P_T2_A26_15 Sch=led[3]
set_property -dict { PACKAGE_PIN E13   IOSTANDARD LVCMOS33 } [get_ports { LED[2] }]; #IO_L17N_T2_A25_15 Sch=led[4]
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { LED[3] }]; #IO_L18P_T2_A24_15 Sch=led[5]

## Buttons
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { BTN[0] }]; #IO_L18N_T2_A23_15 Sch=btn[0]
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { BTN[1] }]; #IO_L19P_T3_A22_15 Sch=btn[1]
set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS33 } [get_ports { BTN[2] }]; #IO_L19N_T3_A21_VREF_15 Sch=btn[2]
set_property -dict { PACKAGE_PIN H13   IOSTANDARD LVCMOS33 } [get_ports { BTN[3] }]; #IO_L20P_T3_A20_15 Sch=btn[3]

## RGB LEDs
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[0] }]; #IO_L23N_T3_FWE_B_15 Sch=led0_r
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[1] }]; #IO_L14N_T2_SRCC_15 Sch=led0_g
set_property -dict { PACKAGE_PIN F15   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[2] }]; #IO_L13N_T2_MRCC_15 Sch=led0_b
set_property -dict { PACKAGE_PIN E15   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[3] }]; #IO_L15N_T2_DQS_ADV_B_15 Sch=led1_r
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[4] }]; #IO_L16P_T2_A28_15 Sch=led1_g
set_property -dict { PACKAGE_PIN E14   IOSTANDARD LVCMOS33 } [get_ports { RGB_LED[5] }]; #IO_L15P_T2_DQS_15 Sch=led1_b

## USB-UART Interface
set_property -dict { PACKAGE_PIN R12   IOSTANDARD LVCMOS33 } [get_ports { UART_TX }]; #IO_25_14 Sch=uart_rxd_out
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { UART_RX }]; #IO_L24N_T3_A00_D16_14 Sch=uart_txd_in

