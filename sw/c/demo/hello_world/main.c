// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
#include "uart.h"
#include "demo_system.h"
#include "timer.h"
#include "gpio.h"
#include "pwm.h"
#include <stdbool.h>
#include <stdint.h>

#define USE_GPIO_SHIFT_REG 0

void test_uart_rx_irq_handler(void) __attribute__((interrupt));
void test_uart_tx_irq_handler(void) __attribute__((interrupt));


void test_uart_rx_irq_handler(void) {
    unsigned char u;
    u = getchar();
    putchar(u);
}

void test_uart_tx_irq_handler(void) {
    volatile int i;
    do
    {
      for(i=0; i < 100; i++){};
    } while (uart_status(DEFAULT_UART) & UART_STATUS_TX_NEAR_FULL);  
}

int main(void) {
  install_exception_handler(UART_RX_IRQ_NUM, &test_uart_rx_irq_handler);
  install_exception_handler(UART_TX_IRQ_NUM, &test_uart_tx_irq_handler);
  uart_enable_rx_int();
  uart_enable_tx_int();

  
  uart_enable(DEFAULT_UART, UART_RX_EN | UART_TX_EN);
  uart_setup(DEFAULT_UART, DATA_SIZE_8 | PARITY_NONE | STOP_BITS_ONE | BAUD_RATE_115200);

  // This indicates how often the timer gets updated.
  timer_init();
  timer_enable(5000000);

  uint64_t last_elapsed_time = get_elapsed_time();

  // Reset green LEDs to off
  set_outputs(GPIO_OUT, 0x0);

  // PWM variables
  uint32_t counter = UINT8_MAX;
  uint32_t brightness = 0;
  bool ascending = true;
  // The three least significant bits correspond to RGB, where B is the leas significant.
  uint8_t color = 7;
  
  const char str[] = " Hello World ";
  uint32_t c = 0;
  while(1) {
    uint64_t cur_time = get_elapsed_time();

    if (cur_time != last_elapsed_time) {
      last_elapsed_time = cur_time;
      
      set_global_interrupt_enable(0);
      puts(str);
      puthex(c++);
      puts("\r\n");
      set_global_interrupt_enable(1);
      
      // Going from bright to dim on PWM
      for(int i = 0; i < NUM_PWM_MODULES; i++) {
        set_pwm(PWM_FROM_ADDR_AND_INDEX(PWM_BASE, i),
            ((1 << (i%3)) & color) ? counter : 0,
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
    asm volatile ("wfi");
  }
}
