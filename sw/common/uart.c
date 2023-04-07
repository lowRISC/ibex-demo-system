#include "uart.h"

void uart_putc(char c) {
    UART_TX_DATA_ADDR = c;
}

void uart_puts(const char *str) {
    while (*str) {
        UART_TX_DATA_ADDR = *str;
        str++;
    }
}

void uart_puth(uint32_t h) {
    int cur_digit;
    for (int i = 0; i < 8; i++) {
        cur_digit = h >> 28;

        if (cur_digit < 10)
        uart_putc('0' + cur_digit);
        else
        uart_putc('A' - 10 + cur_digit);

        h <<= 4;
    }
}

char uart_getc() {
    return UART_RX_DATA_ADDR;
}

void uart_enable(unsigned char en) {
    UART_EN_ADDR = en;
}

void uart_disable() {
    UART_EN_ADDR =  0x00;
}

void uart_setup(unsigned char parameters) {
    UART_PARAMETER_SETUP_ADDR = parameters;
}
