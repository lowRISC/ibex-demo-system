set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH {4} [current_design]

set_property -dict {PACKAGE_PIN C23 IOSTANDARD LVTTL} [get_ports {csn}]
set_property -dict {PACKAGE_PIN B24 IOSTANDARD LVTTL} [get_ports {sdi_dq0}]
set_property -dict {PACKAGE_PIN A25 IOSTANDARD LVTTL} [get_ports {sdo_dq1}]
set_property -dict {PACKAGE_PIN B22 IOSTANDARD LVTTL} [get_ports {wpn_dq2}]
set_property -dict {PACKAGE_PIN A22 IOSTANDARD LVTTL} [get_ports {hldn_dq3}]

