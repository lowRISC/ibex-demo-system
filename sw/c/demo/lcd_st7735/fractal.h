// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
#ifndef LCD_ST_7735_FRACTAL
#define LCD_ST_7735_FRACTAL

#include "lcd.h"

void fractal_mandelbrot_float(St7735Context *lcd);
void fractal_mandelbrot_fixed(St7735Context *lcd);
extern uint16_t rgb_iters_palette[51];

#endif
