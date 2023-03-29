## Clocks
set_property -dict { PACKAGE_PIN N13   IOSTANDARD LVCMOS33 } [get_ports { I_pll_clk1 }];
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { I_cw_clkin }];

create_clock -period 10.000 -name pll_clk1 -waveform {0.000 5.000} [get_nets I_pll_clk1]
create_clock -period 10.000 -name cw_clkin -waveform {0.000 5.000} [get_nets I_cw_clkin]

## Switches
set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS33 } [get_ports { J16 }]; #IO_L12N_T1_MRCC_16 Sch=sw[0]
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { K16 }]; #IO_L13P_T2_MRCC_16 Sch=sw[1]
set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { L14 }]; #IO_L13N_T2_MRCC_16 Sch=sw[2]
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { K15 }]; #IO_L14P_T2_SRCC_16 Sch=sw[3]

## LEDs
set_property -dict { PACKAGE_PIN T2    IOSTANDARD LVCMOS33 } [get_ports { LED[0] }]; #IO_L24N_T3_35 Sch=led[4]
set_property -dict { PACKAGE_PIN T3    IOSTANDARD LVCMOS33 } [get_ports { LED[1] }]; #IO_25_35 Sch=led[5]
set_property -dict { PACKAGE_PIN T4    IOSTANDARD LVCMOS33 } [get_ports { LED[2] }]; #IO_L24P_T3_A01_D17_14 Sch=led[6]

set_property DRIVE 8 [get_ports LED*]

## UART
set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { UART_TX }]; #CW IO1
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { UART_RX }]; #CW IO2

# IO3-4:
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { IO3 }]; #IO3
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { IO4 }]; #IO4


set_property -dict { PACKAGE_PIN R1    IOSTANDARD LVCMOS33 } [get_ports { IO_RST_N }]; #IO_L16P_T2_35 Sch=ck_rst

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
