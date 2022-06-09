// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "stdio.h"
#include "uart.h"
#include "dev_access.h"
#include "super_system.h"

void simple_uart_in_handler(void) __attribute__((interrupt));

void simple_uart_in_handler(void) {
  while (!(DEV_READ(DEFAULT_UART + UART_STATUS_REG) & UART_STATUS_RX_EMPTY)) {
    DEV_WRITE(DEFAULT_UART + UART_TX_REG, DEV_READ(DEFAULT_UART + UART_RX_REG));
  }
}

void uart_init(void) {
  install_exception_handler(16, &simple_uart_in_handler);
}

void uart_enable(void) {
  // enable uart interrupt
  asm volatile("csrs  mie, %0\n" : : "r"(1<<16));
  // enable global interrupt
  asm volatile("csrs  mstatus, %0\n" : : "r"(1<<3));
}

int uart_in(uart_t uart) {
  int res = EOF;
  if (!(DEV_READ(uart + UART_STATUS_REG) & UART_STATUS_RX_EMPTY)) {
    res = DEV_READ(uart + UART_RX_REG);
  }
  return res;
}

void uart_out(uart_t uart, char c) {
  while(DEV_READ(uart + UART_STATUS_REG) & UART_STATUS_TX_FULL);

  DEV_WRITE(uart + UART_TX_REG, c);
}
