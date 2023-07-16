// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#![no_main]
#![no_std]

pub use gpio::pin::{ErasePin, GpioExt};
pub use ibex_demo_system_pac as pac;

pub mod gpio;
pub mod pwm;
pub mod serial;
pub mod spi;
pub mod timer;
pub mod utils;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {}
}
