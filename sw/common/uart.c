// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "uart.h"
#include "dev_access.h"

void uart_out(void* uart_ptr, char c) {
  while(DEV_READ(uart_ptr + UART_STATUS_REG) & UART_STATUS_TX_FULL);

  DEV_WRITE(uart_ptr + UART_TX_REG, c);
}
