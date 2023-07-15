// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

pub mod dyn_pin;
pub mod pin;
pub mod static_pin;

pub use dyn_pin::DynPin;
pub use static_pin::StaticPin;

use ibex_demo_system_pac as pac;

/// The code bellow must be replicated for any new GPIO port that might be added in the future.
/// Extension trait to split the `ibex_demo_system_pac::Peripheral::GPIOx` into pins.
impl pin::GpioExt for pac::GPIOA {
    type Pins = static_pin::PortPins<'A'>;
    fn pins(self) -> Self::Pins {
        Self::Pins::new()
    }
}

impl<P: pin::Pin> pin::Block for P {
    fn block(&self, port: char) -> &'static pac::gpioa::RegisterBlock {
        let ptr = match port {
            'A' => pac::GPIOA::ptr(),
            _ => unreachable!(),
        };
        unsafe { &*ptr }
    }
}
