#ifndef UART_H__
#define UART_H__

#define UART_TX_REG 0
#define UART_STATUS_REG 4

#define UART_STATUS_TX_FULL 1

typedef void* uart_t;

#define UART_FROM_BASE_ADDR(addr)((uart_t)(addr))

void uart_out(uart_t uart, char c);

#endif // UART_H__
