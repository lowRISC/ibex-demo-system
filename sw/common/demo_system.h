// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef DEMO_SYSTEM_H_
#define DEMO_SYSTEM_H_

#include <stdint.h>

#include "uart.h"
#include "gpio.h"

#define UART0_BASE 0x80001000
#define DEFAULT_UART UART_FROM_BASE_ADDR(UART0_BASE)

#define GPIO0_BASE 0x80000000
#define GPIO0 GPIO_FROM_BASE_ADDR(GPIO0_BASE)

#define TIMER_BASE 0x80002000

/**
 * Writes character to default UART. Signature matches c stdlib function
 * of the same name.
 *
 * @param c Character to output
 * @returns Character output (never fails so no EOF ever returned)
 */
int putchar(int c);

/**
 * Reads character from default UART. Signature matches c stdlib function
 * of the same name.
 *
 * @returns Character from the uart rx fifo
 */
int getchar(void);

/**
 * Writes string to default UART. Signature matches c stdlib function of
 * the same name.
 *
 * @param str String to output
 * @returns 0 always (never fails so no error)
 */
int puts(const char *str);

/**
 * Writes ASCII hex representation of number to default UART.
 *
 * @param h Number to output in hex
 */
void puthex(uint32_t h);

int install_exception_handler(uint32_t vector_num, void(*handler_fn)(void));

unsigned int get_mepc();
unsigned int get_mcause();
unsigned int get_mtval();

#endif
