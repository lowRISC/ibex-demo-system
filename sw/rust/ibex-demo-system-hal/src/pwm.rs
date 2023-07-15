// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

use core::ops::Deref;
use embedded_hal::PwmPin;
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

impl<P: Deref<Target = pac::pwm0::RegisterBlock>> PwmPin for Pwm<P> {
    type Duty = u32;

    // Required methods
    fn disable(&mut self) {}

    fn enable(&mut self) {}

    fn get_duty(&self) -> Self::Duty {
        self.device.width.read().bits()
    }

    fn get_max_duty(&self) -> Self::Duty {
        self.get_period()
    }

    fn set_duty(&mut self, duty: Self::Duty) {
        self.device.width.write(|w| {
            w.value().variant(duty);
            w
        });
    }
}
