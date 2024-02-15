create_clock -period 40.000 -name mainclk -waveform {0.000 20.000} [get_ports mainclk]
create_clock -period 100.000 -name tck -waveform {0.000 50.000} [get_ports tck_i]

## Clock Domain Crossings
set clks_sys_unbuf  [get_clocks -of_objects [get_pin clkgen/pll/CLKOUT0]]
set clks_peri_unbuf [get_clocks -of_objects [get_pin clkgen/pll/CLKOUT2]]
set clks_usb_unbuf  [get_clocks -of_objects [get_pin clkgen/pll/CLKOUT1]]

## Set asynchronous clock groups
set_clock_groups -group ${clks_sys_unbuf} -group ${clks_peri_unbuf} -group ${clks_usb_unbuf} -group mainclk -asynchronous

set_property PACKAGE_PIN B13 [get_ports {userled[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {userled[0]}]
set_property PACKAGE_PIN B14 [get_ports {userled[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {userled[1]}]
set_property PACKAGE_PIN C12 [get_ports {userled[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {userled[2]}]
set_property PACKAGE_PIN B12 [get_ports {userled[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {userled[3]}]
set_property PACKAGE_PIN B11 [get_ports {userled[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {userled[4]}]
set_property PACKAGE_PIN A11 [get_ports {userled[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {userled[5]}]
set_property PACKAGE_PIN F13 [get_ports {userled[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {userled[6]}]
set_property PACKAGE_PIN F14 [get_ports {userled[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {userled[7]}]

set_property PACKAGE_PIN H17 [get_ports tck_i]
set_property IOSTANDARD LVCMOS33 [get_ports tck_i]
set_property PACKAGE_PIN G17 [get_ports td_i]
set_property IOSTANDARD LVCMOS33 [get_ports td_i]
set_property PACKAGE_PIN J14 [get_ports td_o]
set_property IOSTANDARD LVCMOS33 [get_ports td_o]
set_property PACKAGE_PIN H15 [get_ports tms_i]
set_property IOSTANDARD LVCMOS33 [get_ports tms_i]

set_property PACKAGE_PIN D12 [get_ports {user_sw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {user_sw[0]}]
set_property PACKAGE_PIN D13 [get_ports {user_sw[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {user_sw[1]}]
set_property PACKAGE_PIN B16 [get_ports {user_sw[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {user_sw[2]}]
set_property PACKAGE_PIN B17 [get_ports {user_sw[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {user_sw[3]}]
set_property PACKAGE_PIN A15 [get_ports {user_sw[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {user_sw[4]}]
set_property PACKAGE_PIN A16 [get_ports {user_sw[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {user_sw[5]}]
set_property PACKAGE_PIN A13 [get_ports {user_sw[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {user_sw[6]}]
set_property PACKAGE_PIN A14 [get_ports {user_sw[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {user_sw[7]}]
set_property PACKAGE_PIN F5 [get_ports {nav_sw[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {nav_sw[0]}]
set_property PACKAGE_PIN D8 [get_ports {nav_sw[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {nav_sw[1]}]
set_property PACKAGE_PIN C7 [get_ports {nav_sw[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {nav_sw[2]}]
set_property PACKAGE_PIN E7 [get_ports {nav_sw[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {nav_sw[3]}]
set_property PACKAGE_PIN D7 [get_ports {nav_sw[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {nav_sw[4]}]

set_property PACKAGE_PIN K6 [get_ports {cherierr[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cherierr[0]}]
set_property PACKAGE_PIN L1 [get_ports {cherierr[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cherierr[1]}]
set_property PACKAGE_PIN M1 [get_ports {cherierr[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cherierr[2]}]
set_property PACKAGE_PIN K3 [get_ports {cherierr[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cherierr[3]}]
set_property PACKAGE_PIN L3 [get_ports {cherierr[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cherierr[4]}]
set_property PACKAGE_PIN N2 [get_ports {cherierr[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cherierr[5]}]
set_property PACKAGE_PIN N1 [get_ports {cherierr[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cherierr[6]}]
set_property PACKAGE_PIN M3 [get_ports {cherierr[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cherierr[7]}]
set_property PACKAGE_PIN M2 [get_ports {cherierr[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {cherierr[8]}]

# USRUSB interface
set_property PACKAGE_PIN G1 [get_ports {USRUSB_SPD}]
set_property IOSTANDARD LVCMOS18 [get_ports {USRUSB_SPD}]
set_property PACKAGE_PIN G6 [get_ports {USRUSB_V_P}]
set_property IOSTANDARD LVCMOS18 [get_ports {USRUSB_V_P}]
set_property PACKAGE_PIN F6 [get_ports {USRUSB_V_N}]
set_property IOSTANDARD LVCMOS18 [get_ports {USRUSB_V_N}]
set_property PACKAGE_PIN G4 [get_ports {USRUSB_VPO}]
set_property IOSTANDARD LVCMOS18 [get_ports {USRUSB_VPO}]
set_property PACKAGE_PIN G3 [get_ports {USRUSB_VMO}]
set_property IOSTANDARD LVCMOS18 [get_ports {USRUSB_VMO}]
set_property PACKAGE_PIN J4 [get_ports {USRUSB_RCV}]
set_property IOSTANDARD LVCMOS18 [get_ports {USRUSB_RCV}]
set_property PACKAGE_PIN H4 [get_ports {USRUSB_SOFTCN}]
set_property IOSTANDARD LVCMOS18 [get_ports {USRUSB_SOFTCN}]
set_property PACKAGE_PIN J3 [get_ports {USRUSB_OE}]
set_property IOSTANDARD LVCMOS18 [get_ports {USRUSB_OE}]
set_property PACKAGE_PIN K2 [get_ports {USRUSB_SUS}]
set_property IOSTANDARD LVCMOS18 [get_ports {USRUSB_SUS}]
set_property PACKAGE_PIN K1 [get_ports {USRUSB_VBUSDETECT}]
set_property IOSTANDARD LVCMOS18 [get_ports {USRUSB_VBUSDETECT}]

# PMOD0
set_property PACKAGE_PIN H14 [get_ports {PMOD0_1}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_1}]
set_property PACKAGE_PIN F16 [get_ports {PMOD0_2}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_2}]
set_property PACKAGE_PIN F15 [get_ports {PMOD0_3}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_3}]
set_property PACKAGE_PIN G14 [get_ports {PMOD0_4}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_4}]
set_property PACKAGE_PIN J13 [get_ports {PMOD0_5}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_5}]
set_property PACKAGE_PIN E17 [get_ports {PMOD0_6}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_6}]
set_property PACKAGE_PIN D17 [get_ports {PMOD0_7}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_7}]
set_property PACKAGE_PIN K13 [get_ports {PMOD0_8}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD0_8}]

# PMOD1
set_property PACKAGE_PIN B18 [get_ports {PMOD1_1}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_1}]
set_property PACKAGE_PIN E16 [get_ports {PMOD1_2}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_2}]
set_property PACKAGE_PIN A18 [get_ports {PMOD1_3}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_3}]
set_property PACKAGE_PIN E15 [get_ports {PMOD1_4}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_4}]
set_property PACKAGE_PIN D15 [get_ports {PMOD1_5}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_5}]
set_property PACKAGE_PIN C15 [get_ports {PMOD1_6}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_6}]
set_property PACKAGE_PIN H16 [get_ports {PMOD1_7}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_7}]
set_property PACKAGE_PIN G16 [get_ports {PMOD1_8}]
set_property IOSTANDARD LVCMOS33 [get_ports {PMOD1_8}]

set_property PACKAGE_PIN K5 [get_ports led_legacy]
set_property IOSTANDARD LVCMOS33 [get_ports led_legacy]
set_property PACKAGE_PIN L4 [get_ports led_cheri]
set_property IOSTANDARD LVCMOS33 [get_ports led_cheri]
set_property PACKAGE_PIN L6 [get_ports led_halted]
set_property IOSTANDARD LVCMOS33 [get_ports led_halted]
set_property PACKAGE_PIN L5 [get_ports led_bootok]
set_property IOSTANDARD LVCMOS33 [get_ports led_bootok]

set_property PACKAGE_PIN R6 [get_ports lcd_rst]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_rst]
set_property PACKAGE_PIN U4 [get_ports lcd_dc]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_dc]
set_property PACKAGE_PIN R3 [get_ports lcd_copi]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_copi]
set_property PACKAGE_PIN R5 [get_ports lcd_clk]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_clk]
set_property PACKAGE_PIN P5 [get_ports lcd_cs]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_cs]

set_property PACKAGE_PIN C17 [get_ports ser0_tx]
set_property IOSTANDARD LVCMOS33 [get_ports ser0_tx]
set_property PACKAGE_PIN D18 [get_ports ser0_rx]
set_property IOSTANDARD LVCMOS33 [get_ports ser0_rx]

set_property PULLTYPE PULLUP [get_ports user_sw[*]]
set_property PULLTYPE PULLUP [get_ports nav_sw[*]]

set_output_delay -clock mainclk 0.000 [get_ports userled]

# QWIIC and Arduino Shield
set_property PACKAGE_PIN U7 [get_ports SDA0]
set_property IOSTANDARD LVCMOS33 [get_ports SDA0]
set_property PACKAGE_PIN V9 [get_ports SCL0]
set_property IOSTANDARD LVCMOS33 [get_ports SCL0]

# QWIIC
set_property PACKAGE_PIN V7 [get_ports SDA1]
set_property IOSTANDARD LVCMOS33 [get_ports SDA1]
set_property PACKAGE_PIN U9 [get_ports SCL1]
set_property IOSTANDARD LVCMOS33 [get_ports SCL1]

# mikroBUS Click
set_property PACKAGE_PIN V1 [get_ports MB5]
set_property IOSTANDARD LVCMOS33 [get_ports MB5]
set_property PACKAGE_PIN U2 [get_ports MB6]
set_property IOSTANDARD LVCMOS33 [get_ports MB6]

# R-Pi Header

# GPIO/I2C bus
set_property PACKAGE_PIN L13 [get_ports RPH_G2_SDA]
set_property IOSTANDARD LVCMOS33 [get_ports RPH_G2_SDA]
set_property PACKAGE_PIN K18 [get_ports RPH_G3_SCL]
set_property IOSTANDARD LVCMOS33 [get_ports RPH_G3_SCL]

# I2C - Enable the internal pull-up resistors, if there are no external resistors on the PCB.
set_property PULLUP true [get_ports RPH_G2_SDA]
set_property PULLUP true [get_ports RPH_G3_SCL]

# ID_SC/SD - I2C bus for HAT ID EEPROM; pull-ups are on the HAT itself
set_property PACKAGE_PIN T15 [get_ports RPH_G1]
set_property IOSTANDARD LVCMOS33 [get_ports RPH_G1]
set_property PACKAGE_PIN U17 [get_ports RPH_G0]
set_property IOSTANDARD LVCMOS33 [get_ports RPH_G0]

#set_property PACKAGE_PIN [get_ports RPH_TXD0]
#set_property IOSTANDARD LVCMOS33 [get_ports RPH_TXD0]
#set_property PACKAGE_PIN [get_ports RPH_RXD0]
#set_property IOSTANDARD LVCMOS33 [get_ports RPH_RXD0]


set_property PACKAGE_PIN P15 [get_ports mainclk]
set_property IOSTANDARD LVCMOS33 [get_ports mainclk]

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets tck_i]