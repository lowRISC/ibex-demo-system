// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "fractal.h"
#include "lcd.h"
#include <stdint.h>

#define FP_EXP 12
#define FP_MANT 15
#define MAKE_FP(i, f, f_bits) ((i << FP_EXP) | (f << (FP_EXP - f_bits)))

typedef uint32_t cmplx_fixed_packed_t;

typedef struct {
  int32_t real;
  int32_t imag;
} cmplx_fixed_t;

int32_t fp_clamp(int32_t x) {
  if ((x < 0) && (x < -(1 << FP_MANT))) {
      return -(1 << FP_MANT);
  }

  if ((x > 0) && (x >= (1 << FP_MANT))) {
    return (1 << FP_MANT) - 1;
  }

  return x;
}

int32_t to_fp(int32_t x) {
  int32_t res;
  res = fp_clamp(x << FP_EXP);

  return res;
}

int32_t fp_add(int32_t a, int32_t b) {
  return fp_clamp(a + b);
}

int32_t fp_mul(int32_t a, int32_t b) {
  return fp_clamp((a * b) >> FP_EXP);
}

int32_t cmplx_fixed_abs_sq(cmplx_fixed_t c) {
  return fp_mul(c.real, c.real) + fp_mul(c.imag, c.imag);
}

cmplx_fixed_t cmplx_fixed_mul(cmplx_fixed_t c1, cmplx_fixed_t c2) {
  cmplx_fixed_t res;

  res.real = fp_add(fp_mul(c1.real, c2.real), -fp_mul(c1.imag, c2.imag));
  res.imag = fp_add(fp_mul(c1.real, c2.imag), fp_mul(c1.imag, c2.real));

  return res;
}

cmplx_fixed_t cmplx_fixed_add(cmplx_fixed_t c1, cmplx_fixed_t c2) {
  cmplx_fixed_t res;

  res.real = fp_add(c1.real, c2.real);
  res.imag = fp_add(c1.imag, c2.imag);

  return res;
}

int mandel_iters_fixed(cmplx_fixed_t c, uint32_t max_iters) {
  cmplx_fixed_t iter_val;

  iter_val = c;
  for (uint32_t i = 0; i < max_iters; ++i) {
    iter_val = cmplx_fixed_add(cmplx_fixed_mul(iter_val, iter_val), c);
    if (cmplx_fixed_abs_sq(iter_val) > MAKE_FP(4, 0, 0)) {
      return i;
    }
  }

  return max_iters;
}

void fractal_mandelbrot_fixed(St7735Context *lcd) {
  cmplx_fixed_t cur_p;
  int32_t inc;

  LCD_rectangle rectangle = {.origin = {.x = 0, .y = 0},
    .width = 160, .height = 128 };
  lcd_st7735_clean(lcd);
  lcd_st7735_rgb565_start(lcd, rectangle);

  cur_p.real = -MAKE_FP(1, 0x3, 2);
  cur_p.imag = MAKE_FP(1, 0, 0);

  inc = MAKE_FP(0, 0x40, 12);

  for(int y = 0;y < 128; ++y) {
    for(int x = 0;x < 160; ++x) {
      int iters = mandel_iters_fixed(cur_p, 50);

      uint16_t rgb = rgb_iters_palette[iters];
      lcd_st7735_rgb565_put(lcd, (uint8_t*)&rgb, sizeof(rgb));

      cur_p.real += inc;
    }

    cur_p.imag -= inc;
    cur_p.real = -MAKE_FP(1, 0x3, 2);
  }

  lcd_st7735_rgb565_finish(lcd);
}
