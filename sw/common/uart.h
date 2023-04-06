#include <stdint.h>

#define UART_DEFAULT_BASE_ADDR 0x80001000

#define UART_RX_DATA_ADDR (*(volatile uint32_t *)(UART_DEFAULT_BASE_ADDR + 0x00))
#define UART_TX_DATA_ADDR (*(volatile uint32_t *)(UART_DEFAULT_BASE_ADDR + 0x04))

#define UART_STATE_ADDR (*(volatile uint32_t *)(UART_DEFAULT_BASE_ADDR + 0x08))

#define UART_EN_ADDR (*(volatile uint32_t *)(UART_DEFAULT_BASE_ADDR + 0x0C))

#define UART_PARAMETER_SETUP_ADDR (*(volatile uint32_t *)(UART_DEFAULT_BASE_ADDR + 0x10))

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

/**
 * Writes character to UART.
 *
 *
 * @param c Character to output
 * @returns Nothing
 */
void uart_putc(char c);

/**
 * Writes string to UART.
 *
 *
 * @param str String to output
 * @returns Nothing
 */
void uart_puts(const char *str);

/**
 * Writes hex to UART.
 *
 *
 * @param h Hex to output
 * @returns Nothing
 */
void uart_puth(uint32_t h);

/**
 * Reads character from UART.
 *
 *
 * @returns Character from the uart rx fifo
 */
char uart_getc();

/**
 * Enables UART.
 *
 *
 * @returns Nothing
 */
void uart_enable(unsigned char en);

/**
 * Disables UART.
 *
 *
 * @returns Nothing
 */
void uart_disable();

/**
 * Writes the protocol parameters and initializes UART.
 *
 * @param parameters bitwise or of parameters
 * @returns Nothing
 */
void uart_setup(unsigned char parameters);