// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "core/lucida_console_10pt.h"
#include "demo_system.h"
#include "fractal.h"
#include "gpio.h"
#include "lcd.h"
#include "lowrisc_logo.h"
#include "spi.h"
#include "st7735/lcd_st7735.h"
#include "timer.h"

// Constants.
enum {
  // Pin out mapping.
  LcdCsPin = 0,
  LcdRstPin,
  LcdDcPin,
  LcdBlPin,
  LcdMosiPin,
  LcdSclkPin,
  // Spi clock rate.
  SpiSpeedHz = 5 * 100 * 1000,
};

// Buttons
// The direction is relative to the screen in landscape orientation.
typedef enum {
  BTN_DOWN  = 0b00001,
  BTN_LEFT  = 0b00010,
  BTN_CLICK = 0b00100,
  BTN_RIGHT = 0b01000,
  BTN_UP    = 0b10000,
} Buttons_t;

// Local functions declaration.
static uint32_t spi_write(void *handle, uint8_t *data, size_t len);
static uint32_t gpio_write(void *handle, bool cs, bool dc);
static void timer_delay(uint32_t ms);
static void fractal_test(St7735Context *lcd);
static Buttons_t scan_buttons(uint32_t timeout);

int main(void) {
  timer_init();

  // Set the initial state of the LCD control pins.
  set_output_bit(GPIO_OUT, LcdDcPin, 0x0);
  set_output_bit(GPIO_OUT, LcdBlPin, 0x1);
  set_output_bit(GPIO_OUT, LcdCsPin, 0x0);

  // Init spi driver.
  spi_t spi;
  spi_init(&spi, LCD_SPI, SpiSpeedHz);

  // Reset LCD.
  set_output_bit(GPIO_OUT, LcdRstPin, 0x0);
  timer_delay(150);
  set_output_bit(GPIO_OUT, LcdRstPin, 0x1);

  // Init LCD driver and set the SPI driver.
  St7735Context lcd;
  LCD_Interface interface = {
      .handle      = &spi,         // SPI handle.
      .spi_write   = spi_write,    // SPI write callback.
      .gpio_write  = gpio_write,   // GPIO write callback.
      .timer_delay = timer_delay,  // Timer delay callback.
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
  lcd_st7735_draw_rgb565(&lcd, (LCD_rectangle){.origin = {.x = (160 - 105) / 2, .y = 5}, .width = 105, .height = 80},
                         (uint8_t *)lowrisc_logo_105x80);

  lcd_println(&lcd, "Booting...", alined_center, (LCD_Point){.x = 0, .y = 100});
  timer_delay(1000);

  // Show the main menu.
  const char *items[] = {
      "0. Fractal",
      "1. CoreMark",
  };
  Menu_t main_menu = {
      .title          = "Main menu",
      .color          = BGRColorBlue,
      .selected_color = BGRColorRed,
      .background     = BGRColorWhite,
      .items_count    = sizeof(items) / sizeof(items[0]),
      .items          = items,
  };

  bool repaint    = true;
  size_t selected = 0;
  char line_buffer[21];

  // Boot countdown when no button is pressed. Value 0 indicates the countdown is dismissed.
  int boot_countdown_sec = 3;

menu:
  while (1) {
    if (repaint) {
      repaint = false;
      lcd_st7735_clean(&lcd);
      lcd_show_menu(&lcd, &main_menu, selected);

      if (boot_countdown_sec != 0) {
        lcd_st7735_puts(&lcd, (LCD_Point){.x = 8, .y = 102}, "Defaulting to item");
        strcpy(line_buffer, "0 after 0 seconds");
        line_buffer[strlen("0 after ")] += boot_countdown_sec;
        lcd_st7735_puts(&lcd, (LCD_Point){.x = 12, .y = 115}, line_buffer);
      }
    }

    switch (scan_buttons(1000)) {
      case BTN_UP:
        if (selected > 0) {
          selected--;
        } else {
          selected = main_menu.items_count - 1;
        }
        repaint            = true;
        boot_countdown_sec = 0;
        break;
      case BTN_DOWN:
        if (selected < main_menu.items_count - 1) {
          selected++;
        } else {
          selected = 0;
        }
        repaint            = true;
        boot_countdown_sec = 0;
        break;
      // Left/right buttons currently don't do anything.
      case BTN_LEFT:
      case BTN_RIGHT:
        continue;

      case BTN_CLICK:
        goto boot;

      default:
        if (boot_countdown_sec == 0) {
          continue;
        }

        if (--boot_countdown_sec == 0) {
          goto boot;
        }

        repaint = true;
        break;
    }
  };

boot:
  switch (selected) {
    case 0:
      fractal_test(&lcd);
      break;

    case 1:
      lcd_st7735_puts(&lcd, (LCD_Point){.x = 5, .y = 80}, "CoreMark unimplemented");
      break;
  }

  // Wait until navigation button is clicked.
  while (scan_buttons(1000) != BTN_CLICK)
    ;

  // Return to the main menu.
  repaint = true;
  goto menu;

  return 0;
}

static Buttons_t scan_buttons(uint32_t timeout) {
  while (true) {
    // Sample navigation buttons (debounced).
    uint32_t in_val = read_gpio(GPIO_IN_DBNC) & 0x1f;
    if (in_val == 0) {
      // No button pressed, so delay for 20ms and then try again, unless the timeout is reached.
      const uint32_t poll_delay = 20;
      timer_delay(poll_delay);
      if (timeout < poll_delay) {
        // Timeout reached, return 0.
        return 0;
      } else {
        // Timeout not reached yet, decrease it and try again.
        timeout -= poll_delay;
      }
      continue;
    }

    // Some button pressed.
    // Find the most significant bit set.
    in_val |= in_val >> 1;
    in_val |= in_val >> 2;
    in_val |= in_val >> 4;
    in_val = (in_val >> 1) + 1;

    // Wait until the button is released to avoid an event being triggered multiple times.
    while (read_gpio(GPIO_IN_DBNC) & in_val)
      ;

    return in_val;
  }
}

static void fractal_test(St7735Context *lcd) {
  fractal_mandelbrot_float(lcd);
  timer_delay(5000);
  fractal_mandelbrot_fixed(lcd);
  timer_delay(5000);
}

static uint32_t spi_write(void *handle, uint8_t *data, size_t len) {
  spi_tx(handle, data, len);
  spi_wait_idle(handle);
  return len;
}

static uint32_t gpio_write(void *handle, bool cs, bool dc) {
  set_output_bit(GPIO_OUT, LcdDcPin, dc);
  set_output_bit(GPIO_OUT, LcdCsPin, cs);
  return 0;
}

static void timer_delay(uint32_t ms) {
  // Configure timer to trigger every 1 ms
  timer_enable(50000);
  uint32_t timeout = get_elapsed_time() + ms;
  while (get_elapsed_time() < timeout) {
    asm volatile("wfi");
  }
  timer_disable();
}
