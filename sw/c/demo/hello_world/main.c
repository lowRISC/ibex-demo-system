// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <stdbool.h>

#include "demo_system.h"
#include "gpio.h"
#include "pwm.h"
#include "timer.h"

#define USE_GPIO_SHIFT_REG 0

void test_uart_irq_handler(void) __attribute__((interrupt));

void test_uart_irq_handler(void) {
  int uart_in_char;

  while ((uart_in_char = uart_in(DEFAULT_UART)) != -1) {
    uart_out(DEFAULT_UART, uart_in_char);
    uart_out(DEFAULT_UART, '\r');
    uart_out(DEFAULT_UART, '\n');
  }
}

int main(void) {
  install_exception_handler(UART_IRQ_NUM, &test_uart_irq_handler);
  uart_enable_rx_int();

  // This indicates how often the timer gets updated.
  timer_init();
  timer_enable(5000000);

  uint64_t last_elapsed_time = get_elapsed_time();

  // Reset green LEDs to having just one on
  set_outputs(GPIO_OUT, 0x10); // Bottom 4 bits are LCD control as you can see in top_artya7.sv

  // PWM variables
  uint32_t counter    = UINT8_MAX;
  uint32_t brightness = 0;
  bool ascending      = true;
  // The three least significant bits correspond to RGB, where B is the leas significant.
  uint8_t color = 7;

  while (1) {
    uint64_t cur_time = get_elapsed_time();

    if (cur_time != last_elapsed_time) {
      last_elapsed_time = cur_time;

      // Disable interrupts whilst outputting to prevent output for RX IRQ
      // happening in the middle
      set_global_interrupt_enable(0);

      // Print this to UART (use the screen command to see it).
      puts("Hello World! ");
      puthex(last_elapsed_time);
      puts("   Input Value: ");
      uint32_t in_val = read_gpio(GPIO_IN_DBNC);
      puthex(in_val);
      putchar('\n');

      // Re-enable interrupts with output complete
      set_global_interrupt_enable(1);

      // Cycling through green LEDs
      if (USE_GPIO_SHIFT_REG) {
        // Feed value of BTN0 into the shift register
        set_outputs(GPIO_OUT_SHIFT, in_val);
      } else {
        // Cycle through LEDs unless BTN0 is pressed
        uint32_t out_val = read_gpio(GPIO_OUT);
        out_val = (out_val << 1) & GPIO_LED_MASK;
        if ((in_val & 0x1) || (out_val == 0)) {
          out_val = 0x10;
        }
        set_outputs(GPIO_OUT, out_val);
      }

      // Going from bright to dim on PWM
      for (int i = 0; i < NUM_PWM_MODULES; i++) {
        set_pwm(PWM_FROM_ADDR_AND_INDEX(PWM_BASE, i), ((1 << (i % 3)) & color) ? counter : 0,
                brightness ? 1 << (brightness - 1) : 0);
      }
      if (ascending) {
        brightness++;
        if (brightness >= 5) {
          ascending = false;
        }
      } else {
        brightness--;
        // When LEDs are off cycle through the colors
        if (brightness == 0) {
          ascending = true;
          color++;
          if (color >= 8) {
            color = 1;
          }
        }
      }
    }

    asm volatile("wfi");
  }
}
