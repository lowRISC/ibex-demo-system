// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

use core::ops::Deref;
use embedded_io::Write;
use ibex_demo_system_pac as pac;

pub struct Serial<U: Deref<Target = pac::uart0::RegisterBlock>> {
    device: U,
}

impl<U: Deref<Target = pac::uart0::RegisterBlock>> Serial<U> {
    pub fn new(device: U) -> Self {
        Serial { device }
    }
}

impl<U: Deref<Target = pac::uart0::RegisterBlock>> core::fmt::Write for Serial<U> {
    fn write_str(&mut self, s: &str) -> core::fmt::Result {
        let _ = self.write(s.as_bytes());
        Ok(())
    }
}

impl<U: Deref<Target = pac::uart0::RegisterBlock>> embedded_io::ErrorType for Serial<U> {
    type Error = crate::utils::Error;
}

impl<U: Deref<Target = pac::uart0::RegisterBlock>> embedded_io::Read for Serial<U> {
    fn read(&mut self, buf: &mut [u8]) -> Result<usize, Self::Error> {
        let mut len = 0;
        for elem in buf.iter_mut() {
            if self.device.status.read().rx_empty().bit() {
                break;
            }
            *elem = self.device.rx.read().data().bits();
            len += 1;
        }
        Ok(len)
    }
}

impl<U: Deref<Target = pac::uart0::RegisterBlock>> embedded_io::ReadReady for Serial<U> {
    fn read_ready(&mut self) -> Result<bool, Self::Error> {
        Ok(!self.device.status.read().rx_empty().bit())
    }
}

impl<U: Deref<Target = pac::uart0::RegisterBlock>> embedded_io::Write for Serial<U> {
    fn write(&mut self, buf: &[u8]) -> Result<usize, Self::Error> {
        let mut len = 0;
        for elem in buf {
            if self.device.status.read().tx_full().bit() {
                break;
            }
            self.device.tx.write(|w| {
                w.data().variant(*elem);
                w
            });
            len += 1;
        }
        Ok(len)
    }

    fn flush(&mut self) -> Result<(), Self::Error> {
        Ok(())
    }
}

impl<U: Deref<Target = pac::uart0::RegisterBlock>> embedded_io::WriteReady for Serial<U> {
    fn write_ready(&mut self) -> Result<bool, Self::Error> {
        Ok(!self.device.status.read().tx_full().bit())
    }
}
