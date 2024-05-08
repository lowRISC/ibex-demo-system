// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "fbcon.h"

static St7735Context *ctx;
static LCD_Point pos = {.x = 0, .y = 0};

void fbcon_init(St7735Context* st_ctx) {
    ctx = st_ctx;
}

static void newline() {
  pos.x = 0;
  pos.y += ctx->parent.font->height;

  // Warp to the top if the screen is full.
  if (pos.y + ctx->parent.font->height > ctx->parent.height) {
    pos.y = 0;
  }

  // Clear the content on the new line.
  lcd_st7735_fill_rectangle(
      ctx,
      (LCD_rectangle){
          .origin = pos, .width = ctx->parent.width, .height = ctx->parent.font->height},
      0xffffff);
}

void fbcon_putstr(const char *str) {
  while (*str) {
    char ch = *str++;
    switch (ch) {
      case '\r':
        pos.x = 0;
        break;
      case '\n':
        newline();
        break;
      case '\f':
        lcd_st7735_clean(ctx);
        pos.x = 0;
        pos.y = 0;
        break;
      default: {
        int width = ctx->parent.font->descriptor_table[ch - ctx->parent.font->startCharacter].width;
        if (pos.x + width > ctx->parent.width) {
          newline();
        }

        lcd_st7735_putchar(ctx, pos, ch);
        pos.x += width;
        break;
      }
    }
  }
}
