// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#![no_main]
#![no_std]

extern crate panic_halt as _;

use core::fmt::{self, Write};
use embedded_hal::delay::DelayNs;
use ibex_demo_system_pac::Peripherals;
use riscv::delay::McycleDelay;
use riscv_rt::entry;

const CPU_CLOCK_HZ: u32 = 50_000_000;

#[entry]
fn main() -> ! {
    let mut delay = McycleDelay::new(CPU_CLOCK_HZ);
    let p = Peripherals::take().unwrap();

    let mut uart = Uart::new(p.UART0);

    let gpio = p.GPIOA;
    let mut gpio_value = 0xff;
    let _ = writeln!(uart, "Hello Rusty Ibex System!!");
    let _ = writeln!(uart, "Press a button (BTN0-4) and watch the LEDs");

    loop {
        let in_val = gpio.in_.read().pins().bits();
        if in_val != gpio_value {
            if in_val != 0 {
                let _ = writeln!(uart, " Button {} pressed", get_button(in_val));

                gpio.out.write(|w| {
                    w.pins().variant(in_val << 4);
                    w
                });
            } else {
                let _ = writeln!(uart, "Button released: ");
            }
        }
        gpio_value = in_val;
        delay.delay_ms(50u32);
    }
}

struct Uart {
    uart: ibex_demo_system_pac::UART0,
}

impl Uart {
    fn new(uart: ibex_demo_system_pac::UART0) -> Self {
        Uart { uart }
    }

    fn uart_log(&self, msg: &str) {
        for c in msg.bytes() {
            self.uart_putc(c);
        }
    }

    fn uart_putc(&self, c: u8) {
        self.uart.tx.write(|w| {
            w.data().variant(c);
            w
        });
    }
}

// Implementing this trait will allow we use the `writeln!` macro to format log messages.
impl Write for Uart {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        self.uart_log(s);
        Ok(())
    }
}

fn get_button(pin: u32) -> &'static str {
    match pin {
        0x01 => "BTN0",
        0x02 => "BTN1",
        0x04 => "BTN2",
        0x08 => "BTN3",
        _ => "Unknown",
    }
}
