// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "fractal.h"
#include "lcd.h"
#include <stdint.h>

typedef struct {
  float real;
  float imag;
} cmplx_float_t;

float cmplx_float_abs_sq(cmplx_float_t c) {
  return c.real * c.real + c.imag * c.imag;
}

cmplx_float_t cmplx_float_mul(cmplx_float_t c1, cmplx_float_t c2) {
  cmplx_float_t res;

  res.real = c1.real * c2.real - c1.imag * c2.imag;
  res.imag = c1.real * c2.imag + c1.imag * c2.real;

  return res;
}

cmplx_float_t cmplx_float_add(cmplx_float_t c1, cmplx_float_t c2) {
  cmplx_float_t res;

  res.real = c1.real + c2.real;
  res.imag = c1.imag + c2.imag;

  return res;
}

int mandel_iters_float(cmplx_float_t c, uint32_t max_iters) {
  cmplx_float_t iter_val;

  iter_val = c;
  for (uint32_t i = 0; i < max_iters; ++i) {
    iter_val = cmplx_float_add(cmplx_float_mul(iter_val, iter_val), c);
    if (cmplx_float_abs_sq(iter_val) > 4.0f) {
      return i;
    }
  }

  return max_iters;
}

void fractal_mandelbrot_float(St7735Context *lcd) {
  cmplx_float_t cur_p;
  float real_inc;
  float imag_inc;

  LCD_rectangle rectangle = {.origin = {.x = 0, .y = 0},
    .width = 160, .height = 128 };
  lcd_st7735_clean(lcd);
  lcd_st7735_rgb565_start(lcd, rectangle);

  cur_p.real = -1.75f;
  cur_p.imag = 1.0f;

  real_inc = 2.5f / 160.0f;
  imag_inc = -2.0f / 128.0f;

  for(int y = 0;y < 128; ++y) {
    for(int x = 0;x < 160; ++x) {
      int iters = mandel_iters_float(cur_p, 50);

      uint16_t rgb = rgb_iters_palette[iters];
      lcd_st7735_rgb565_put(lcd, (uint8_t*)&rgb, sizeof(rgb));

      cur_p.real += real_inc;
    }

    cur_p.imag += imag_inc;
    cur_p.real = -1.75f;
  }

  lcd_st7735_rgb565_finish(lcd);
}
