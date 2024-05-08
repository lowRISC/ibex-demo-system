// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef FBCON_H__
#define FBCON_H__

#include <st7735/lcd_st7735.h>

/**
 * Initialize the framebuffer console.
 *
 * @param ctx The ST7735 context to display on.
 */
void fbcon_init(St7735Context* ctx);

/**
 * Print a string to the framebuffer console.
 *
 * @param str The string to print.
 */
void fbcon_putstr(const char *str);

#endif
