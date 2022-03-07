# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

interface ftdi
transport select jtag

ftdi_device_desc "Digilent USB Device"
ftdi_vid_pid 0x0403 0x6010
ftdi_channel 0
ftdi_layout_init 0x0088 0x008b
reset_config none

# Configure JTAG chain and the target processor
set _CHIPNAME riscv

jtag newtap $_CHIPNAME cpu -irlen 6 -expected-id 0x0362D093 -ignore-version
set _TARGETNAME $_CHIPNAME.cpu
target create $_TARGETNAME riscv -chain-position $_TARGETNAME

riscv set_ir idcode 0x09
riscv set_ir dtmcs 0x22
riscv set_ir dmi 0x23

adapter_khz 10000

riscv set_prefer_sba on
gdb_report_data_abort enable
gdb_report_register_access_error enable
gdb_breakpoint_override hard

reset_config none

init
halt
