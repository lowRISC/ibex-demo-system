// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "demo_system.h"
#include "timer.h"
#include "gpio.h"
#include "spi.h"
#include "st7735/lcd_st7735.h"
#include "core/lucida_console_10pt.h"
#include "lowrisc_logo.h"
#include "lcd.h"
#include "fractal.h"

// Constants.
enum{
// Pin out mapping.
  LcdCsPin=0,
  LcdRstPin,
  LcdDcPin,
  LcdBlPin,
  LcdMosiPin,
  LcdSclkPin,
  // Spi clock rate.
  SpiSpeedHz = 5 * 100 * 1000,
};

// Buttons
typedef enum {
  BTN0 = 0b0001,
  BTN1 = 0b0010,
  BTN2 = 0b0100,
  BTN3 = 0b1000,
} Buttons_t;

// Local functions declaration.
static uint32_t spi_write(void *handle, uint8_t *data, size_t len);
static uint32_t gpio_write(void *handle, bool cs, bool dc);
static void timer_delay(uint32_t ms);
static void fractal_test(St7735Context *lcd);
static Buttons_t scan_buttons(uint32_t timeout, Buttons_t def);

int main(void) {
  timer_init();

  // Set the initial state of the LCD control pins.
  set_output_bit(GPIO_OUT, LcdDcPin, 0x0);
  set_output_bit(GPIO_OUT, LcdBlPin, 0x1);
  set_output_bit(GPIO_OUT, LcdCsPin, 0x0);

  // Init spi driver.
  spi_t spi;
  spi_init(&spi, DEFAULT_SPI, SpiSpeedHz);

  // Reset LCD.
  set_output_bit(GPIO_OUT, LcdRstPin, 0x0);
  timer_delay(150);
  set_output_bit(GPIO_OUT, LcdRstPin, 0x1);

  // Init LCD driver and set the SPI driver.
  St7735Context lcd;
  LCD_Interface interface = {
      .handle = &spi,  // SPI handle.
      .spi_write = spi_write, // SPI write callback.
      .gpio_write = gpio_write, // GPIO write callback.
      .timer_delay = timer_delay, // Timer delay callback.
  };
  lcd_st7735_init(&lcd, &interface);

  // Set the LCD orientation.
  lcd_st7735_set_orientation(&lcd, LCD_Rotate180);

  // Setup text font bitmaps to be used and the colors.
  lcd_st7735_set_font(&lcd, &lucidaConsole_10ptFont);
  lcd_st7735_set_font_colors(&lcd, BGRColorWhite, BGRColorBlack);

  // Clean display with a white rectangle.
  lcd_st7735_clean(&lcd);

  // Draw the splash screen with a RGB 565 bitmap and text in the bottom.
  lcd_st7735_draw_rgb565(&lcd, (LCD_rectangle){.origin = {.x = (160 - 105)/2, .y = 5},
                                .width = 105, .height = 80}, (uint8_t*)lowrisc_logo_105x80);
  lcd_println(&lcd, "Booting...", alined_center, 7);
  timer_delay(1000);

  do {
    lcd_st7735_clean(&lcd);

    // Show the main menu.
    const char * items[] = {"0. Fractal","1. Custom",};
    Menu_t main_menu = {
      .title = "Main menu",
      .color = BGRColorBlue,
      .selected_color = BGRColorRed,
      .background = BGRColorWhite,
      .items_count = sizeof(items)/sizeof(items[0]),
      .items = items,
    };
    lcd_show_menu(&lcd, &main_menu);
    lcd_st7735_puts(&lcd, (LCD_Point){.x = 5, .y = 106}, "Defaulting to item");
    lcd_st7735_puts(&lcd, (LCD_Point){.x = 5, .y = 118}, "0 after 3 seconds");

    switch(scan_buttons(3000, BTN0)) {
      case BTN0:
        // Run the fractal examples.
        fractal_test(&lcd);
        break;
      case BTN1:
        lcd_st7735_puts(&lcd, (LCD_Point){.x = 5, .y = 80}, "Button 1 pressed");
        timer_delay(1000);
        break;
      case BTN2:
        break;
      case BTN3:
        break;
      default:
        break;
    }
  } while(1);
}

static Buttons_t scan_buttons(uint32_t timeout, Buttons_t def) {
  do {
    // Sample buttons (debounced).
    const uint32_t in_val = read_gpio(GPIO_IN_DBNC) & 0xf;
    if (in_val == 0) {
      // No button pressed, so delay for 20ms and then try again, unless the timeout is reached.
      const uint32_t poll_delay = 20;
      timer_delay(poll_delay);
      if (timeout < poll_delay) {
        // Timeout reached, return default button.
        return def;
      } else {
        // Timeout not reached yet, decrease it and try again.
        timeout -= poll_delay;
      }
    } else {
      // Some button pressed, return the sampled value.
      return (Buttons_t)in_val;
    }
  } while (1);
}

static void fractal_test(St7735Context *lcd){
    fractal_mandelbrot_float(lcd);
    timer_delay(5000);
    fractal_mandelbrot_fixed(lcd);
    timer_delay(5000);
}

static uint32_t spi_write(void *handle, uint8_t *data, size_t len){
  const uint32_t data_sent = len;
  while(len--){
    spi_send_byte_blocking(handle, *data++);
  }
  while((spi_get_status(handle) & spi_status_fifo_empty) != spi_status_fifo_empty);
  return data_sent;
}

static uint32_t gpio_write(void *handle, bool cs, bool dc){
  set_output_bit(GPIO_OUT, LcdDcPin, dc);
  set_output_bit(GPIO_OUT, LcdCsPin, cs);
  return 0;
}

static void timer_delay(uint32_t ms){
  // Configure timer to trigger every 1 ms
  timer_enable(50000);
  uint32_t timeout = get_elapsed_time() + ms;
  while(get_elapsed_time() < timeout){ asm volatile ("wfi"); }
  timer_disable();
}

