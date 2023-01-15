// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "demo_system.h"
#include "fractal.h"
#include "lcd.h"
#include <stdint.h>

#define FP_EXP 12
#define FP_MANT 15
#define MAKE_FP(i, f, f_bits) ((i << FP_EXP) | (f << (FP_EXP - f_bits)))

typedef uint32_t cmplx_packed_t;

static inline cmplx_packed_t cmplx_mul_insn(uint32_t a, uint32_t b) {
  uint32_t result;

  asm (".insn r CUSTOM_0, 0, 0, %0, %1, %2" :
       "=r"(result) :
       "r"(a), "r"(b));

  return result;
}

static inline cmplx_packed_t cmplx_add_insn(uint32_t a, uint32_t b) {
  uint32_t result;

  asm (".insn r CUSTOM_0, 1, 0, %0, %1, %2" :
       "=r"(result) :
       "r"(a), "r"(b));

  return result;
}

static inline int32_t cmplx_abs_sq_insn(uint32_t a) {
  int32_t result;

  asm (".insn r CUSTOM_0, 2, 0, %0, %1, x0" :
       "=r"(result) :
       "r"(a));

  return result;
}

int mandel_iters_cmplx_insn(cmplx_packed_t c, uint32_t max_iters) {
  cmplx_packed_t iter_val;

  iter_val = c;
  for (uint32_t i = 0; i < max_iters; ++i) {
    iter_val = cmplx_add_insn(cmplx_mul_insn(iter_val, iter_val), c);
    if (cmplx_abs_sq_insn(iter_val) > MAKE_FP(4, 0, 0)) {
      return i;
    }
  }

  return max_iters;
}

void fractal_mandelbrot_cmplx_insn(St7735Context *lcd, unsigned int *compute_cycles) {
  cmplx_packed_t cur_p;
  cmplx_packed_t inc_real, inc_imag;

  *compute_cycles = 0;

  LCD_rectangle rectangle = {.origin = {.x = 0, .y = 0},
    .width = 160, .height = 128 };
  lcd_st7735_clean(lcd);
  lcd_st7735_rgb565_start(lcd, rectangle);

  cur_p = (-MAKE_FP(1, 0x3, 2)) << 16 | (MAKE_FP(1, 0, 0) & 0xffff);

  inc_real = (MAKE_FP(0, 0x40, 12)) << 16;
  inc_imag = (-MAKE_FP(0, 0x40, 12)) & 0xffff; // TODO: does this work?

  for(int y = 0;y < 128; ++y) {
    for(int x = 0;x < 160; ++x) {
      reset_mcycle();
      int iters = mandel_iters_cmplx_insn(cur_p, 50);
      *compute_cycles += get_mcycle();

      uint16_t rgb = rgb_iters_palette[iters];
      lcd_st7735_rgb565_put(lcd, (uint8_t*)&rgb, sizeof(rgb));

      cur_p = cmplx_add_insn(cur_p, inc_real);
    }

    cur_p = cmplx_add_insn(cur_p, inc_imag);
    cur_p = (cur_p & 0xffff) | ((-MAKE_FP(1, 0x3, 2)) << 16);
  }

  lcd_st7735_rgb565_finish(lcd);
}
