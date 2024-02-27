# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# OpenOCD config to connect to the Sonata board via a external Olimex
# ARM-USB-TINY-H JTAG probe:
# https://www.olimex.com/Products/ARM/JTAG/ARM-USB-TINY-H/
# Note to use the external probe the user JTAG isolation switches must be
# toggled on the Sonata board. This is all 8 switches in bank SW2 on the
# underside of the board. They should be set in the position next to the switch
# numbers.

source [find interface/ftdi/olimex-arm-usb-tiny-h.cfg]

# Configure JTAG chain and the target processor
set _CHIPNAME riscv

# Ibex Demo System JTAG IDCODE
set _EXPECTED_ID 0x11001CDF

jtag newtap $_CHIPNAME cpu -irlen 5 -expected-id $_EXPECTED_ID -ignore-version
set _TARGETNAME $_CHIPNAME.cpu
target create $_TARGETNAME riscv -chain-position $_TARGETNAME

adapter speed 10000

riscv set_mem_access sysbus
gdb_report_data_abort enable
gdb_report_register_access_error enable
gdb_breakpoint_override hard

reset_config none

init
halt
