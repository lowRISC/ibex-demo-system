// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

use core::ops::Deref;
use embedded_hal::blocking;
use embedded_hal::digital::v2::OutputPin;
use embedded_hal::spi;

use ibex_demo_system_pac as pac;

pub struct Spi<S: Deref<Target = pac::spi0::RegisterBlock>, CS: OutputPin> {
    device: S,
    chip_select: CS,
}

impl<S: Deref<Target = pac::spi0::RegisterBlock>, CS: OutputPin> Spi<S, CS> {
    pub fn new(device: S, chip_select: CS) -> Self {
        Spi {
            device,
            chip_select,
        }
    }

    pub fn is_tx_fifo_full(&self) -> bool {
        self.device.status.read().tx_full().bit()
    }

    pub fn is_tx_fifo_empty(&self) -> bool {
        self.device.status.read().tx_empty().bit()
    }

    pub fn tx_write(&mut self, byte: u8) {
        while self.is_tx_fifo_full() {}
        self.device.tx.write(|w| {
            w.data().variant(byte);
            w
        });
    }
}

impl<S: Deref<Target = pac::spi0::RegisterBlock>, T: OutputPin> spi::FullDuplex<u8> for Spi<S, T> {
    type Error = super::utils::Error;
    fn read(&mut self) -> nb::Result<u8, Self::Error> {
        Err(nb::Error::Other(super::utils::Error::NotSupported))
    }

    fn send(&mut self, word: u8) -> nb::Result<(), Self::Error> {
        self.tx_write(word);
        Ok(())
    }
}

impl<S: Deref<Target = pac::spi0::RegisterBlock>, T: OutputPin> blocking::spi::Write<u8>
    for Spi<S, T>
{
    type Error = super::utils::Error;
    fn write(&mut self, words: &[u8]) -> Result<(), Self::Error> {
        let _ = self.chip_select.set_low();
        for c in words {
            self.tx_write(*c);
        }
        while !self.is_tx_fifo_empty() {}
        let _ = self.chip_select.set_high();
        Ok(())
    }
}
