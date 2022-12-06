// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
#ifndef LCD_ST_7735_FRACTAL
#define LCD_ST_7735_FRACTAL

#include "lcd.h"

void fractal_mandelbrot(St7735Context *lcd, bool by_pixel);

void fractal_bifurcation(St7735Context *lcd);

#endif
