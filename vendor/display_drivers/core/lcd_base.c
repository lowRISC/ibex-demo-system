
// Copyright (c) 2022 Douglas Reis.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "lcd_base.h"

#include "font.h"

Result LCD_Init(LCD_Context *ctx, LCD_Interface *interface, uint32_t width, uint32_t height) {
  ctx->interface = interface;
  ctx->height    = height;
  ctx->width     = width;
  return (Result){.code = 0};
}

inline uint16_t LCD_rgb24_to_bgr565(uint32_t rgb) {
  uint8_t b = (rgb >> 16) & 0xFF, g = (rgb >> 8) & 0xFF, r = rgb & 0xFF;
  uint16_t color = ((b & 0xF8) << 8) | ((g & 0xFC) << 3) | (r >> 3);
  return ENDIANESS_TO_HALF_WORD(color);
}

inline uint16_t LCD_rgb565_to_bgr565(const uint8_t rgb[2]) {
  // |        B0              |           B1           |
  // | r  r  r  r  r  g  g  g |  g  g  g  b  b  b  b  b|
  // | 0              5     7 |  0        3           7|

  // |                half word                       |
  // |b  b  b  b  b  g  g  g  g  g  g  r  r  r  r  r  |5f0d
  // |15          11                5              0  |
  uint8_t b = (rgb[1] >> 3), g = (rgb[1] & 0x7) << 3 | rgb[0] >> 5, r = rgb[0] & 0x1F;
  uint16_t color = b | g << 5 | r << 11;
  return ENDIANESS_TO_HALF_WORD(color);
}

extern inline Result LCD_get_resolution(LCD_Context *ctx, size_t *height, size_t *width);

extern Result LCD_set_font_colors(LCD_Context *ctx, uint32_t background_color, uint32_t foreground_color);

extern Result LCD_set_font(LCD_Context *ctx, const Font *font);