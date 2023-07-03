// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#![no_std]
#![no_main]

extern crate panic_halt;
extern crate riscv_rt;

use core::fmt::Write;
use riscv_semihosting::hio;

use riscv_rt::entry;

#[entry]
fn main() -> ! {
    // do something here
    jtag_print("Hello world!").unwrap();
    loop {}
}

fn jtag_print(msg: &str) -> Result<(), core::fmt::Error> {
    let mut stdout = hio::hstdout().map_err(|_| core::fmt::Error)?;
    writeln!(stdout, "{}", msg)?;
    Ok(())
}
