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

// Local functions declaration.
static uint32_t spi_write(void *handle, uint8_t *data, size_t len);
static uint32_t gpio_write(void *handle, bool cs, bool dc);
static void timer_delay(uint32_t ms);
static void fractal_test(St7735Context *lcd);
static void pwm_test(St7735Context *lcd);
static void led_test(St7735Context *lcd);

// Buttons
typedef enum {
  BTN0,
  BTN1,
  BTN2,
  BTN3,
}Buttons_t;

static Buttons_t scan_buttons(uint32_t timeout);

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
    const char * items[] = {"0. LED","1. Fractal","2. PWM",};
    Menu_t main_menu = {
      .title = "Main menu",
      .color = BGRColorBlue,
      .selected_color = BGRColorRed,
      .background = BGRColorWhite,
      .items_count = sizeof(items)/sizeof(items[0]),
      .items = items,
    };
    lcd_show_menu(&lcd, &main_menu);

    // TODO: Read the buttons.
    switch(scan_buttons(1000)){
      case BTN0:
        led_test(&lcd);
      break;
      case BTN1:
        // Run the fractal examples.
        fractal_test(&lcd);
      break;
      case BTN2:
        // Run the pwm example.
        pwm_test(&lcd);
      break;
      case BTN3:
      break;
      default:
      break;
    }
  } while(1);
}

static void fractal_test(St7735Context *lcd){
    fractal_bifurcation(lcd);
    timer_delay(2000); 

    fractal_mandelbrot(lcd, true);
    timer_delay(5000); 
}


static void pwm_test(St7735Context *lcd){
  //TODO
}

static void led_test(St7735Context *lcd){
  //TODO
}

static Buttons_t scan_buttons(uint32_t timeout){
  //TODO
  timer_delay(timeout); 
  return BTN1;
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

