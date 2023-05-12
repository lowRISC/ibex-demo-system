// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

package jtag_id_pkg;

  // lowRISC JEDEC Manufacturer ID, bank 13 0xEF
  localparam logic [10:0] JEDEC_MANUFACTURER_ID = {4'd12, 7'b110_1111};
  localparam logic [3:0] JTAG_VERSION = 4'h1;

  localparam logic [31:0] RV_DM_JTAG_IDCODE = {
    JTAG_VERSION,          // Version
    {12'h100,4'h1},        // Part Number
    JEDEC_MANUFACTURER_ID, // Manufacturer ID
    1'b1                   // (fixed)
  };

endpackage : jtag_id_pkg
