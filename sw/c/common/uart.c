#include "uart.h"
#include "dev_access.h"
#include "demo_system.h"

void uart_enable_rx_int(void) {
  enable_interrupts(UART_RX_IRQ);
  set_global_interrupt_enable(1);
}

void uart_enable_tx_int(void) {
  enable_interrupts(UART_TX_IRQ);
  set_global_interrupt_enable(1);
}

int uart_in(uart_t uart) {
  int res = UART_EOF;

  if (!(DEV_READ(uart + UART_STATUS_REG) & UART_STATUS_RX_EMPTY)) {
    res = DEV_READ(uart + UART_RX_REG);
  }

  return res;
}

void uart_out(uart_t uart, char c) {
  while(DEV_READ(uart + UART_STATUS_REG) & UART_STATUS_TX_FULL);

  DEV_WRITE(uart + UART_TX_REG, c);
}

void uart_enable(uart_t uart, char en) {

  DEV_WRITE(uart + UART_ENABLE_REG, en);
}

void uart_disable(uart_t uart) {

  DEV_WRITE(uart + UART_ENABLE_REG, 0x00);
}

void uart_setup(uart_t uart, char parameters) {

  DEV_WRITE(uart + UART_PARAMETERS_REG, parameters);
}

int uart_status(uart_t uart) {
  return DEV_READ(DEFAULT_UART + UART_STATUS_REG);
}