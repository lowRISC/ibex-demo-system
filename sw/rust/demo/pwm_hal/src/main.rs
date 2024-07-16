// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#![no_main]
#![no_std]

extern crate panic_halt as _;

use crate::hal::timer::timer::CountDown;
use core::iter;
use riscv_rt::entry;

use embedded_hal::pwm::SetDutyCycle;

use crate::hal::pac;
use fugit::{ExtU32, RateExtU32};
use ibex_demo_system_hal as hal;

use smart_leds as leds;

const CPU_CLOCK_HZ: u32 = 50_000_000;

struct RgbLed<R, G, B> {
    r: R,
    g: G,
    b: B,
}

trait SetColor {
    fn set_color(&mut self, color: leds::RGB8);
}

impl<R, G, B> RgbLed<R, G, B>
where
    R: SetDutyCycle,
    G: SetDutyCycle,
    B: SetDutyCycle,
{
    fn new(mut b: B, mut g: G, mut r: R) -> Self {
        b.set_duty_cycle_percent(0).unwrap();
        g.set_duty_cycle_percent(0).unwrap();
        r.set_duty_cycle_percent(0).unwrap();
        Self { r, g, b }
    }
}

impl<R, G, B> SetColor for RgbLed<R, G, B>
where
    R: SetDutyCycle,
    G: SetDutyCycle,
    B: SetDutyCycle,
{
    fn set_color(&mut self, color: leds::RGB8) {
        self.r.set_duty_cycle_percent(color.r).unwrap();
        self.g.set_duty_cycle_percent(color.g).unwrap();
        self.b.set_duty_cycle_percent(color.b).unwrap();
    }
}

#[entry]
fn main() -> ! {
    let p = pac::Peripherals::take().unwrap();

    let timer = hal::timer::Timer::new(p.TIMER0, CPU_CLOCK_HZ.Hz());
    let mut count_down = timer.new_count_down();

    let pwm0 = hal::pwm::Pwm::new(p.PWM0);
    let pwm1 = hal::pwm::Pwm::new(p.PWM1);
    let pwm2 = hal::pwm::Pwm::new(p.PWM2);
    let pwm3 = hal::pwm::Pwm::new(p.PWM3);
    let pwm4 = hal::pwm::Pwm::new(p.PWM4);
    let pwm5 = hal::pwm::Pwm::new(p.PWM5);
    let pwm6 = hal::pwm::Pwm::new(p.PWM6);
    let pwm7 = hal::pwm::Pwm::new(p.PWM7);
    let pwm8 = hal::pwm::Pwm::new(p.PWM8);
    let pwm9 = hal::pwm::Pwm::new(p.PWM9);
    let pwm10 = hal::pwm::Pwm::new(p.PWM10);
    let pwm11 = hal::pwm::Pwm::new(p.PWM11);

    let mut led0 = RgbLed::new(pwm0, pwm1, pwm2);
    let mut led1 = RgbLed::new(pwm3, pwm4, pwm5);
    let mut led2 = RgbLed::new(pwm6, pwm7, pwm8);
    let mut led3 = RgbLed::new(pwm9, pwm10, pwm11);

    let mut n: u8 = 128;
    count_down.start(30u32.millis());
    loop {
        if count_down.wait().is_ok() {
            let color = wheel(n);
            n = n.wrapping_add(1);
            led0.set_color(color);
            led1.set_color(color);
            led2.set_color(color);
            led3.set_color(color);

            count_down.start(30u32.millis());
        }
    }
}

fn wheel(mut wheel_pos: u8) -> leds::RGB8 {
    wheel_pos = u8::MAX - wheel_pos;
    let color = if wheel_pos < 85 {
        // No green in this sector - red and blue only
        (u8::MAX - (wheel_pos * 3), 0, wheel_pos * 3).into()
    } else if wheel_pos < 170 {
        // No red in this sector - green and blue only
        wheel_pos -= 85;
        (0, wheel_pos * 3, u8::MAX - (wheel_pos * 3)).into()
    } else {
        // No blue in this sector - red and green only
        wheel_pos -= 170;
        (wheel_pos * 3, u8::MAX - (wheel_pos * 3), 0).into()
    };
    leds::gamma(leds::brightness(iter::once(color), 150))
        .next()
        .unwrap()
}
