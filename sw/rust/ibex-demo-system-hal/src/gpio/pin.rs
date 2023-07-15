// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

use ibex_demo_system_pac as pac;

pub(crate) trait Pin: Sized {
    fn id(&self) -> u8;

    fn port(&self) -> char;

    fn mask(&self) -> u32 {
        0x01 << self.id()
    }

    #[inline(always)]
    fn set_value(&self, val: bool) {
        let port = self.port();
        let block = self.block(port);
        block.out.modify(|r, w| {
            w.pins()
                .variant((r.pins().bits() & !self.mask()) | (val as u32) << self.id());
            w
        });
    }

    #[inline(always)]
    fn get_value(&self) -> bool {
        let port = self.port();
        let block = self.block(port);
        let bits = block.in_.read().pins().bits();
        (bits & self.mask()) == self.mask()
    }
}

pub trait ErasePin: Sized {
    type ErasedPin;
    fn erase(self) -> Self::ErasedPin;

    fn into_dynamic(self) -> Self::ErasedPin {
        self.erase()
    }
}

pub trait GpioExt: Sized {
    type Pins;
    fn pins(self) -> Self::Pins;
    fn split(self) -> Self::Pins {
        self.pins()
    }
}

pub trait Block: Sized {
    fn block(&self, port: char) -> &'static pac::gpioa::RegisterBlock;
}

pub struct DisabledState;
pub struct OutputState;
pub struct InputState;
