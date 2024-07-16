// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

use core::ops::Deref;
use embedded_hal::{delay::DelayNs, digital::OutputPin, spi};
use ibex_demo_system_pac as pac;

pub struct Spi<
    S: Deref<Target = pac::spi0::RegisterBlock>,
    CS: OutputPin,
    D: DelayNs = riscv::delay::McycleDelay,
> {
    device: S,
    chip_select: CS,
    delay: Option<D>,
}

impl<S, CS> Spi<S, CS>
where
    S: Deref<Target = pac::spi0::RegisterBlock>,
    CS: OutputPin,
{
    pub fn new(device: S, chip_select: CS) -> Self {
        Spi {
            device,
            chip_select,
            delay: None,
        }
    }
}

impl<S, CS, D> Spi<S, CS, D>
where
    S: Deref<Target = pac::spi0::RegisterBlock>,
    CS: OutputPin,
    D: DelayNs,
{
    pub fn new_with_delay(device: S, chip_select: CS, delay: D) -> Self {
        Spi {
            device,
            chip_select,
            delay: Some(delay),
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

impl<S, CS, D> embedded_hal::spi::ErrorType for Spi<S, CS, D>
where
    S: Deref<Target = pac::spi0::RegisterBlock>,
    CS: OutputPin,
    D: DelayNs,
{
    type Error = crate::utils::Error;
}

impl<S, CS, D> embedded_hal::spi::SpiDevice for Spi<S, CS, D>
where
    S: Deref<Target = pac::spi0::RegisterBlock>,
    CS: OutputPin,
    D: DelayNs,
{
    fn transaction(
        &mut self,
        operations: &mut [spi::Operation<'_, u8>],
    ) -> Result<(), Self::Error> {
        for operation in operations.iter_mut() {
            match operation {
                spi::Operation::Read(words) => spi::SpiBus::read(self, *words),
                spi::Operation::Write(words) => spi::SpiBus::write(self, *words),
                spi::Operation::Transfer(read, write) => spi::SpiBus::transfer(self, *read, *write),
                spi::Operation::TransferInPlace(words) => {
                    spi::SpiBus::transfer_in_place(self, *words)
                }
                spi::Operation::DelayNs(ns) => {
                    let Some(delay) = self.delay.as_mut() else {
                        return Err(Self::Error::NotSupported);
                    };
                    delay.delay_ns(*ns);
                    Ok(())
                }
            }?
        }
        Ok(())
    }
}

impl<S, CS, D> spi::SpiBus for Spi<S, CS, D>
where
    S: Deref<Target = pac::spi0::RegisterBlock>,
    CS: OutputPin,
    D: DelayNs,
{
    fn read(&mut self, _words: &mut [u8]) -> Result<(), Self::Error> {
        Err(Self::Error::NotSupported)
    }

    fn write(&mut self, words: &[u8]) -> Result<(), Self::Error> {
        let _ = self.chip_select.set_low();
        for word in words {
            self.tx_write(*word)
        }
        while !self.is_tx_fifo_empty() {}
        let _ = self.chip_select.set_high();
        Ok(())
    }

    fn transfer(&mut self, read: &mut [u8], write: &[u8]) -> Result<(), Self::Error> {
        assert!(write.len() <= read.len());
        let _ = self.chip_select.set_low();
        for (w, r) in write.iter().zip(read.iter_mut()) {
            self.tx_write(*w);
            *r = 0xff;
        }
        while !self.is_tx_fifo_empty() {}
        let _ = self.chip_select.set_high();
        Ok(())
    }

    fn transfer_in_place(&mut self, words: &mut [u8]) -> Result<(), Self::Error> {
        let _ = self.chip_select.set_low();
        for w in words.iter_mut() {
            self.tx_write(*w);
            *w = 0xff;
        }
        while !self.is_tx_fifo_empty() {}
        let _ = self.chip_select.set_high();
        Ok(())
    }

    fn flush(&mut self) -> Result<(), Self::Error> {
        Ok(())
    }
}
