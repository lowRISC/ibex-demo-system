#ifndef UART_H__
#define UART_H__

#include <stdint.h>

#define UART_RX_REG         0x00
#define UART_TX_REG         0x04
#define UART_STATUS_REG     0x08
#define UART_ENABLE_REG     0x0C
#define UART_PARAMETERS_REG 0x10

#define UART_STATUS_RX_EMPTY 0x01
#define UART_STATUS_TX_FULL 0x02
#define UART_STATUS_RX_NEAR_EMPTY 0x04
#define UART_STATUS_TX_NEAR_FULL 0x08

#define UART_EOF -1

typedef void* uart_t;

#define UART_FROM_BASE_ADDR(addr)((uart_t)(addr))

#define DATA_SIZE_6     0x00
#define DATA_SIZE_7     0x01
#define DATA_SIZE_8     0x02
#define DATA_SIZE_9     0x03

#define PARITY_NONE     0x00
#define PARITY_EVEN     0x04
#define PARITY_ODD      0x0C

#define STOP_BITS_ONE    0x00
#define STOP_BITS_TWO    0x10

#define BAUD_RATE_4800      0x00
#define BAUD_RATE_9600      0x20
#define BAUD_RATE_57600     0x40
#define BAUD_RATE_115200    0x60

#define UART_RX_EN 0x01
#define UART_TX_EN 0x02

void uart_enable_rx_int(void);

void uart_enable_tx_int(void);

int uart_in(uart_t uart);
void uart_out(uart_t uart, char c);

void uart_enable(uart_t uart, char en);
void uart_disable(uart_t uart);
void uart_setup(uart_t uart, char parameters);

int uart_status(uart_t uart);

#endif
