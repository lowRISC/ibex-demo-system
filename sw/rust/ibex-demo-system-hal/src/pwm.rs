// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

use core::ops::Deref;
use ibex_demo_system_pac as pac;

pub struct Pwm<P: Deref<Target = pac::pwm0::RegisterBlock>> {
    device: P,
    period: u32,
}

impl<P: Deref<Target = pac::pwm0::RegisterBlock>> Pwm<P> {
    pub fn new(device: P) -> Self {
        let mut pwm = Pwm { device, period: 0 };
        pwm.set_period(u8::MAX.into());
        pwm
    }

    pub fn set_period(&mut self, period: u32) {
        self.period = period;
        self.device.counter.write(|w| {
            w.value().variant(period);
            w
        });
    }

    pub fn get_period(&self) -> u32 {
        self.period
    }
}

impl<P: Deref<Target = pac::pwm0::RegisterBlock>> embedded_hal::pwm::ErrorType for Pwm<P> {
    type Error = crate::utils::Error;
}

impl<P: Deref<Target = pac::pwm0::RegisterBlock>> embedded_hal::pwm::SetDutyCycle for Pwm<P> {
    fn max_duty_cycle(&self) -> u16 {
        self.get_period() as u16
    }

    fn set_duty_cycle(&mut self, duty: u16) -> Result<(), Self::Error> {
        self.device.width.write(|w| {
            w.value().variant(duty as u32);
            w
        });
        Ok(())
    }
}
