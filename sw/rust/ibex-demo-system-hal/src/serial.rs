// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

use core::ops::Deref;
use embedded_hal::serial::{Read, Write};
use ibex_demo_system_pac as pac;
pub struct Serial<U: Deref<Target = pac::uart0::RegisterBlock>> {
    device: U,
}

impl<U: Deref<Target = pac::uart0::RegisterBlock>> Serial<U> {
    pub fn new(device: U) -> Self {
        Serial { device }
    }
}

impl<U: Deref<Target = pac::uart0::RegisterBlock>> Write<u8> for Serial<U> {
    type Error = super::utils::Error;
    fn write(&mut self, word: u8) -> nb::Result<(), Self::Error> {
        self.device.tx.write(|w| {
            w.data().variant(word);
            w
        });
        Ok(())
    }

    fn flush(&mut self) -> nb::Result<(), Self::Error> {
        Ok(())
    }
}

impl<U: Deref<Target = pac::uart0::RegisterBlock>> core::fmt::Write for Serial<U> {
    fn write_str(&mut self, s: &str) -> core::fmt::Result {
        let _ = s.bytes().try_for_each(|c| self.write(c));
        Ok(())
    }
}

impl<U: Deref<Target = pac::uart0::RegisterBlock>> Read<u8> for Serial<U> {
    type Error = super::utils::Error;
    fn read(&mut self) -> nb::Result<u8, Self::Error> {
        Ok(self.device.rx.read().data().bits())
    }
}
