// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#![no_main]
#![no_std]

extern crate panic_halt as _;
use core::fmt::Write;

use riscv::delay::McycleDelay;
use riscv_rt::entry;

use embedded_graphics::{
    image::{Image, ImageRaw, ImageRawLE},
    mono_font::{ascii::FONT_6X10, MonoTextStyle},
    pixelcolor::Rgb565,
    prelude::*,
    text::Text,
};

use st7735_lcd;
use st7735_lcd::Orientation;

use crate::hal::{pac, GpioExt};

use embedded_hal::{self, delay::DelayNs, digital::OutputPin};

use ibex_demo_system_hal as hal;

const CPU_CLOCK_HZ: u32 = 50_000_000;

#[entry]
fn main() -> ! {
    let mut delay = McycleDelay::new(CPU_CLOCK_HZ);
    let p = pac::Peripherals::take().unwrap();

    let pins = p.GPIOA.pins();
    let mut led0 = pins.pin4.into_output();
    let mut cs = pins.pin0.into_output();
    let mut lcd_led = pins.pin3.into_output();
    let rst = pins.pin1.into_output();
    let dc = pins.pin2.into_output();

    led0.set_high().unwrap();
    cs.set_low().unwrap();
    lcd_led.set_low().unwrap();

    let spi = hal::spi::Spi::new(p.SPI0, cs);

    let mut disp = st7735_lcd::ST7735::new(spi, dc, rst, true, false, 160, 128);
    disp.init(&mut delay).unwrap();
    disp.set_orientation(&Orientation::Landscape).unwrap();
    disp.clear(Rgb565::WHITE).unwrap();
    disp.set_offset(0, 0);
    lcd_led.set_high().unwrap();

    let style = MonoTextStyle::new(&FONT_6X10, Rgb565::BLUE);

    let image_raw: ImageRawLE<Rgb565> =
        ImageRaw::new(include_bytes!("../resorces/lowrisc.rgb565"), 105);
    let image: Image<_> = Image::new(&image_raw, Point::new((160 - 105) / 2, 0));
    image.draw(&mut disp).unwrap();

    Text::new("Open to the core", Point::new(30, 90), style)
        .draw(&mut disp)
        .unwrap();

    loop {
        delay.delay_ms(15);
    }
}
