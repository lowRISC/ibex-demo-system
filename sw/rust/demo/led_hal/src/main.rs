// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#![no_main]
#![no_std]

extern crate panic_halt as _;

use core::fmt::Write;
use embedded_hal::delay::DelayNs;
use riscv::delay::McycleDelay;
use riscv_rt::entry;

use embedded_hal;
use embedded_hal::digital::{InputPin, OutputPin};
use hal::{pac, ErasePin, GpioExt};
use ibex_demo_system_hal as hal;

const CPU_CLOCK_HZ: u32 = 50_000_000;

struct BtnLedMap<'a, S> {
    btn: &'a mut dyn InputPin<Error = hal::utils::Error>,
    led: hal::gpio::DynPin<S>,
    prev_val: bool,
}

impl<'a, S> BtnLedMap<'a, S> {
    fn new(
        btn: &'a mut dyn InputPin<Error = hal::utils::Error>,
        led: hal::gpio::DynPin<S>,
        prev_val: bool,
    ) -> Self {
        Self { btn, led, prev_val }
    }
}

#[entry]
fn main() -> ! {
    let mut delay = McycleDelay::new(CPU_CLOCK_HZ);
    let p = pac::Peripherals::take().unwrap();

    let mut uart = hal::serial::Serial::new(p.UART0);

    let pins = p.GPIOA.pins();
    let mut btn0 = pins.pin0.into_input();
    let mut btn1 = pins.pin1.into_input();
    let mut btn2 = pins.pin2.into_input();
    let mut btn3 = pins.pin3.into_input();

    // Dynamic pins are convenient because they have the same type, but there's a run time cost.
    let led0 = pins.pin4.into_dynamic().into_output();
    let led1 = pins.pin5.into_dynamic().into_output();
    let led2 = pins.pin6.into_dynamic().into_output();
    let led3 = pins.pin7.into_dynamic().into_output();

    let mut map = [
        BtnLedMap::new(&mut btn0, led0, false),
        BtnLedMap::new(&mut btn1, led1, false),
        BtnLedMap::new(&mut btn2, led2, false),
        BtnLedMap::new(&mut btn3, led3, false),
    ];

    let _ = writeln!(uart, "Hello Ibex Rusty System!!");
    let _ = writeln!(uart, "Press a button (BTN0-4) and watch the LEDs");

    loop {
        for node in map.iter_mut() {
            let in_val = node.btn.is_high().unwrap();
            if in_val != node.prev_val {
                node.prev_val = in_val;
                if in_val {
                    let _ = writeln!(uart, " Button pressed");
                    node.led.set_high().unwrap();
                } else {
                    node.led.set_low().unwrap();
                    let _ = writeln!(uart, "Button released: ");
                }
            }
        }
        delay.delay_ms(50);
    }
}
