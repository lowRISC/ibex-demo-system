// Copyright (c) 2022 Douglas Reis.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "lcd_st7735.h"

#include <stdint.h>
#include <stdlib.h>

#include "lcd_st7735_cmds.h"
#define NEXT_BYTE(addr) (*(const uint8_t *)(addr++))

#define DELAY 0x80

// clang-format off
/* Initialization commands for 7735B screens */
static const uint8_t init_script_b[] =
{
    18,                       // 18 commands in list:
    ST7735_SWRESET,   DELAY,  //  1: Software reset, no args, w/delay
      50,                     //     50 ms delay
    ST7735_SLPOUT ,   DELAY,  //  2: Out of sleep mode, no args, w/delay
      255,                    //     255 = 500 ms delay
    ST7735_COLMOD , 1+DELAY,  //  3: Set color mode, 1 arg + delay:
      0x05,                   //     16-bit color
      10,                     //     10 ms delay
    ST7735_FRMCTR1, 3+DELAY,  //  4: Frame rate control, 3 args + delay:
      0x00,                   //     fastest refresh
      0x06,                   //     6 lines front porch
      0x03,                   //     3 lines back porch
      10,                     //     10 ms delay
    ST7735_MADCTL , 1      ,  //  5: Memory access ctrl (directions), 1 arg:
      0x68,                   //     Row addr/col addr, bottom to top refresh
    ST7735_DISSET5, 2      ,  //  6: Display settings #5, 2 args, no delay:
      0x15,                   //     1 clk cycle nonoverlap, 2 cycle gate
                              //     rise, 3 cycle osc equalize
      0x02,                   //     Fix on VTL
    ST7735_INVCTR , 1      ,  //  7: Display inversion control, 1 arg:
      0x0,                    //     Line inversion
    ST7735_PWCTR1 , 2+DELAY,  //  8: Power control, 2 args + delay:
      0x02,                   //     GVDD = 4.7V
      0x70,                   //     1.0uA
      10,                     //     10 ms delay
    ST7735_PWCTR2 , 1      ,  //  9: Power control, 1 arg, no delay:
      0x05,                   //     VGH = 14.7V, VGL = -7.35V
    ST7735_PWCTR3 , 2      ,  // 10: Power control, 2 args, no delay:
      0x01,                   //     Opamp current small
      0x02,                   //     Boost frequency
    ST7735_VMCTR1 , 2+DELAY,  // 11: Power control, 2 args + delay:
      0x3C,                   //     VCOMH = 4V
      0x38,                   //     VCOML = -1.1V
      10,                     //     10 ms delay
    ST7735_PWCTR6 , 2      ,  // 12: Power control, 2 args, no delay:
      0x11, 0x15,
    ST7735_GMCTRP1,16      ,  // 13: Magical unicorn dust, 16 args, no delay:
      0x09, 0x16, 0x09, 0x20, //     (seriously though, not sure what
      0x21, 0x1B, 0x13, 0x19, //      these config values represent)
      0x17, 0x15, 0x1E, 0x2B,
      0x04, 0x05, 0x02, 0x0E,
    ST7735_GMCTRN1,16+DELAY,  // 14: Sparkles and rainbows, 16 args + delay:
      0x0B, 0x14, 0x08, 0x1E, //     (ditto)
      0x22, 0x1D, 0x18, 0x1E,
      0x1B, 0x1A, 0x24, 0x2B,
      0x06, 0x06, 0x02, 0x0F,
      10,                     //     10 ms delay
    ST7735_CASET  , 4      ,  // 15: Column addr set, 4 args, no delay:
      0x00, 0x02,             //     XSTART = 2
      0x00, 0x81,             //     XEND = 129
    ST7735_RASET  , 4      ,  // 16: Row addr set, 4 args, no delay:
      0x00, 0x02,             //     XSTART = 1
      0x00, 0x81,             //     XEND = 160
    ST7735_NORON  ,   DELAY,  // 17: Normal display on, no args, w/delay
      10,                     //     10 ms delay
    ST7735_DISPON ,   DELAY,  // 18: Main screen turn on, no args, w/delay
      255 	                  //     255 = 500 ms delay
};


// Init for 7735R, part 1 (red or green tab)
static const uint8_t init_script_r[] =
{
    15,                       // 15 commands in list:
    ST7735_SWRESET,   DELAY,  //  1: Software reset, 0 args, w/delay
      150,                    //     150 ms delay
    ST7735_SLPOUT ,   DELAY,  //  2: Out of sleep mode, 0 args, w/delay
      255,                    //     500 ms delay
    ST7735_FRMCTR1, 3      ,  //  3: Frame rate ctrl - normal mode, 3 args:
      0x00, 0x02, 0x02,       //     Rate = fosc/(1x2+40) * (LINE+2C+2D)  Era 0x01, 0x2C, 0x2D,
    ST7735_FRMCTR2, 3      ,  //  4: Frame rate control - idle mode, 3 args:
      0x00, 0x02, 0x02,       //     Rate = fosc/(1x2+40) * (LINE+2C+2D)  Era 0x01, 0x2C, 0x2D
    ST7735_FRMCTR3, 6      ,  //  5: Frame rate ctrl - partial mode, 6 args:
      0x00, 0x02, 0x02,       //     Dot inversion mode  Era 0x01, 0x2C, 0x2D,
      0x00, 0x02, 0x02,       //     Line inversion mode  Era 0x01, 0x2C, 0x2D,
    ST7735_INVCTR , 1      ,  //  6: Display inversion ctrl, 1 arg, no delay:
      0x07,                   //     No inversion
    ST7735_PWCTR1 , 3      ,  //  7: Power control, 3 args, no delay:
      0xA2,
      0x02,                   //     -4.6V
      0x84,                   //     AUTO mode
    ST7735_PWCTR2 , 1      ,  //  8: Power control, 1 arg, no delay:
      0xC5,                   //     VGH25 = 2.4C VGSEL = -10 VGH = 3 * AVDD
    ST7735_PWCTR3 , 2      ,  //  9: Power control, 2 args, no delay:
      0x0A,                   //     Opamp current small
      0x00,                   //     Boost frequency
    ST7735_PWCTR4 , 2      ,  // 10: Power control, 2 args, no delay:
      0x8A,                   //     BCLK/2, Opamp current small & Medium low
      0x2A,
    ST7735_PWCTR5 , 2      ,  // 11: Power control, 2 args, no delay:
      0x8A, 0xEE,
    ST7735_VMCTR1 , 1      ,  // 12: Power control, 1 arg, no delay:
      0x0E,
    ST7735_INVOFF , 0      ,  // 13: Don't invert display, no args, no delay
    ST7735_MADCTL , 1      ,  // 14: Memory access control (directions), 1 arg:
      0x68,                   //     row addr/col addr, bottom to top refresh
    ST7735_COLMOD , 1      ,  // 15: set color mode, 1 arg, no delay:
      0x05 					  // 16-bit color
};

// Init for 7735R, part 3 (red or green tab)
static const uint8_t init_script_r3[] = {
    4,                       	//  4 commands in list:
    ST7735_GMCTRP1, 16      ,	//  1: Magical unicorn dust, 16 args, no delay:
      0x02, 0x1c, 0x07, 0x12,
      0x37, 0x32, 0x29, 0x2d,
      0x29, 0x25, 0x2B, 0x39,
      0x00, 0x01, 0x03, 0x10,
    ST7735_GMCTRN1, 16      ,	//  2: Sparkles and rainbows, 16 args, no delay:
      0x03, 0x1d, 0x07, 0x06,
      0x2E, 0x2C, 0x29, 0x2D,
      0x2E, 0x2E, 0x37, 0x3F,
      0x00, 0x00, 0x02, 0x10,
    ST7735_NORON  ,    DELAY, 	//3: Normal display on, no args, w/delay
      10,                     	//10 ms delay
    ST7735_DISPON ,    DELAY, 	//4: Main screen turn on, no args w/delay
      100 						//100 ms delay
};

// clang-format on
static void write_command(St7735Context *ctx, uint8_t command) {
  uint16_t value = (command & 0x00FF);
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, false, false);
  ctx->parent.interface->spi_write(ctx->parent.interface->handle, (uint8_t *)&value, 1);
}

static void write_buffer(St7735Context *ctx, const uint8_t *buffer, size_t length) {
  if (length) {
    ctx->parent.interface->spi_write(ctx->parent.interface->handle, (uint8_t *)buffer, length);
  }
}

static void delay(St7735Context *ctx, uint32_t millisecond) { ctx->parent.interface->timer_delay(millisecond); }

static void run_script(St7735Context *ctx, const uint8_t *addr) {
  uint8_t numCommands, numArgs;
  uint16_t delay_ms;

  numCommands = NEXT_BYTE(addr);  // Number of commands to follow

  while (numCommands--) {  // For each command...
    write_command(ctx, NEXT_BYTE(addr));

    numArgs  = NEXT_BYTE(addr);  // Number of args to follow
    delay_ms = numArgs & DELAY;  // If hibit set, delay follows args
    numArgs &= ~DELAY;           // Mask out delay bit

    ctx->parent.interface->gpio_write(ctx->parent.interface->handle, false, true);
    write_buffer(ctx, addr, numArgs);
    ctx->parent.interface->gpio_write(ctx->parent.interface->handle, true, true);
    addr += numArgs;

    if (delay_ms) {
      delay_ms = NEXT_BYTE(addr);                     // Read post-command delay time (ms)
      delay_ms = (delay_ms == 255) ? 500 : delay_ms;  // If 255, delay for 500 ms
      delay(ctx, delay_ms);
    }
  }
}

static void set_address(St7735Context *ctx, uint8_t x0, uint8_t y0, uint8_t x1, uint8_t y1) {
  uint32_t coordinate = 0;

  coordinate = x0 << 8 | x1 << 24;
  write_command(ctx, ST7735_CASET);  // Column addr set
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, false, true);
  write_buffer(ctx, (uint8_t *)&coordinate, sizeof(coordinate));
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, true, true);

  coordinate = y0 << 8 | y1 << 24;
  write_command(ctx, ST7735_RASET);  // Row addr set
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, false, true);
  write_buffer(ctx, (uint8_t *)&coordinate, sizeof(coordinate));
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, true, true);

  write_command(ctx, ST7735_RAMWR);  // write to RAM
}

static void write_register(St7735Context *ctx, uint8_t addr, uint8_t value) {
  write_command(ctx, addr);
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, false, true);
  write_buffer(ctx, (uint8_t *)&value, sizeof(value));
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, true, true);
}

Result lcd_st7735_init(St7735Context *ctx, LCD_Interface *interface) {
  LCD_Init(&ctx->parent, interface, 160, 128);
  int result = 0;

  run_script(ctx, init_script_b);
  run_script(ctx, init_script_r);
  run_script(ctx, init_script_r3);

  return (Result){.code = result};
}

Result lcd_st7735_set_orientation(St7735Context *ctx, LCD_Orientation orientation) {
  const static uint8_t st7735_orientation_map[] = {
      0,
      ST77_MADCTL_MX | ST77_MADCTL_MV,
      ST77_MADCTL_MX | ST77_MADCTL_MY,
      ST77_MADCTL_MY | ST77_MADCTL_MV,
  };

  write_register(ctx, ST7735_MADCTL, st7735_orientation_map[orientation] | ST77_MADCTL_RGB);
}

Result lcd_st7735_clean(St7735Context *ctx) {
  size_t w, h;
  lcd_st7735_get_resolution(ctx, &h, &w);
  lcd_st7735_fill_rectangle(ctx, (LCD_rectangle){.origin = {.x = 0, .y = 0}, .width = w, .height = h}, 0xffffff);
  return (Result){.code = 0};
}

Result lcd_st7735_draw_pixel(St7735Context *ctx, LCD_Point pixel, uint32_t color) {
  if ((pixel.x < 0) || (pixel.x >= ctx->parent.width) || (pixel.y < 0) || (pixel.y >= ctx->parent.height)) {
    return (Result){.code = -1};
  }
  color = LCD_rgb24_to_bgr565(color);

  set_address(ctx, pixel.x, pixel.y, pixel.x + 1, pixel.y + 1);

  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, false, true);
  write_buffer(ctx, (uint8_t *)&color, 2);
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, true, true);
  return (Result){.code = 0};
}

Result lcd_st7735_draw_vertical_line(St7735Context *ctx, LCD_Line line, uint32_t color) {
  // Rudimentary clipping
  if ((line.origin.x >= ctx->parent.width) || (line.origin.y >= ctx->parent.height)) {
    return (Result){.code = -1};
  }

  if ((line.origin.y + line.length - 1) >= ctx->parent.height) {
    line.length = ctx->parent.height - line.origin.y;
  }

  color = LCD_rgb24_to_bgr565(color);
  set_address(ctx, line.origin.x, line.origin.y, line.origin.x, line.origin.y + line.length - 1);

  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, false, true);
  while (line.length--) {
    write_buffer(ctx, (uint8_t *)&color, 2);
  }
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, true, true);
  return (Result){.code = 0};
}

Result lcd_st7735_draw_horizontal_line(St7735Context *ctx, LCD_Line line, uint32_t color) {
  // Rudimentary clipping
  if ((line.origin.x >= ctx->parent.width) || (line.origin.y >= ctx->parent.height)) {
    return (Result){.code = -1};
  }

  if ((line.origin.x + line.length - 1) >= ctx->parent.width) {
    line.length = ctx->parent.height - line.origin.y;
  }

  set_address(ctx, line.origin.x, line.origin.y, line.origin.x + line.length - 1, line.origin.y);

  color = LCD_rgb24_to_bgr565(color);

  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, false, true);
  while (line.length--) {
    write_buffer(ctx, (uint8_t *)&color, 2);
  }
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, true, true);
  return (Result){.code = 0};
}

Result lcd_st7735_fill_rectangle(St7735Context *ctx, LCD_rectangle rectangle, uint32_t color) {
  // rudimentary clipping (drawChar w/big text requires this)
  if ((rectangle.origin.x >= ctx->parent.width) || (rectangle.origin.y >= ctx->parent.height) ||
      (rectangle.origin.x + rectangle.width > ctx->parent.width) ||
      (rectangle.origin.y + rectangle.height > ctx->parent.height)) {
    return (Result){.code = -1};
  }

  uint16_t w = MIN(rectangle.origin.x + rectangle.width, ctx->parent.width) - rectangle.origin.x;
  uint16_t h = MIN(rectangle.origin.y + rectangle.height, ctx->parent.height) - rectangle.origin.y;

  color = LCD_rgb24_to_bgr565(color);

  // Create an array with the pixes for the lines.
  uint16_t row[w];
  for (int i = 0; i < w; ++i) {
    row[i] = color;
  }

  set_address(ctx, rectangle.origin.x, rectangle.origin.y, rectangle.origin.x + w - 1, rectangle.origin.y + h - 1);

  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, false, true);
  // Iterate through the lines.
  for (int x = h; x > 0; x--) {
    write_buffer(ctx, (uint8_t *)row, sizeof(row));
  }
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, true, true);
  return (Result){.code = 0};
}

Result lcd_st7735_putchar(St7735Context *ctx, LCD_Point origin, char character) {
  const Font *font                    = ctx->parent.font;
  const FontCharInfo *char_descriptor = &font->descriptor_table[character - font->startCharacter];
  uint16_t buffer[char_descriptor->width];

  set_address(ctx, origin.x, origin.y, origin.x + char_descriptor->width - 1, origin.y + font->height - 1);
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, false, true);
  const uint8_t *char_bitmap = &font->bitmap_table[char_descriptor->position - 1];
  for (int row = 0; row < font->height; row++) {
    for (int column = 0; column < char_descriptor->width; column++) {
      uint8_t bit = column % 8;
      char_bitmap += (uint8_t)(bit == 0);
      buffer[column] = (*char_bitmap & (0x01 << bit)) ? ctx->parent.foreground_color : ctx->parent.background_color;
    }
    write_buffer(ctx, (uint8_t *)buffer, sizeof(buffer));
  }
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, true, true);
  return (Result){.code = 0};
}

Result lcd_st7735_puts(St7735Context *ctx, LCD_Point pos, const char *text) {
  int count = 0;
  int width = ctx->parent.font->descriptor_table[text[0] - ctx->parent.font->startCharacter].width;

  while (*text) {
    if ((pos.x + width) > ctx->parent.width) {
      return (Result){.code = 0};
    }

    lcd_st7735_putchar(ctx, pos, *text);

    pos.x = pos.x + width;

    text++;
    count++;
  }

  return (Result){.code = count};  // number of chars printed
}

Result lcd_st7735_draw_bgr(St7735Context *ctx, LCD_rectangle rectangle, const uint8_t *bgr) {
  set_address(ctx, rectangle.origin.x, rectangle.origin.y, rectangle.origin.x + rectangle.width - 1,
              rectangle.origin.y + rectangle.height - 1);

  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, false, true);
  for (int i = 0; i < rectangle.width * rectangle.height * 3; i += 3) {
    uint16_t color = LCD_rgb24_to_bgr565(bgr[i] << 16 | bgr[i + 1] << 8 | bgr[i + 2]);
    write_buffer(ctx, (uint8_t *)&color, 2);
  }
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, true, true);
  return (Result){.code = 0};
}

Result lcd_st7735_draw_rgb565(St7735Context *ctx, LCD_rectangle rectangle, const uint8_t *rgb) {
  set_address(ctx, rectangle.origin.x, rectangle.origin.y, rectangle.origin.x + rectangle.width - 1,
              rectangle.origin.y + rectangle.height - 1);
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, false, true);
  for (int i = 0; i < rectangle.width * rectangle.height * 2; i += 2, rgb += 2) {
    uint16_t color = LCD_rgb565_to_bgr565(rgb);
    write_buffer(ctx, (uint8_t *)&color, 2);
  }
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, true, true);
  return (Result){.code = 0};
}

Result lcd_st7735_rgb565_start(St7735Context *ctx, LCD_rectangle rectangle) {
  set_address(ctx, rectangle.origin.x, rectangle.origin.y, rectangle.origin.x + rectangle.width - 1,
              rectangle.origin.y + rectangle.height - 1);
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, false, true);
  return (Result){.code = 0};
}

Result lcd_st7735_rgb565_put(St7735Context *ctx, const uint8_t *rgb, size_t size) {
  for (int i = 0; i < size; i += 2, rgb += 2) {
    uint16_t color = LCD_rgb565_to_bgr565(rgb);
    write_buffer(ctx, (uint8_t *)&color, 2);
  }
  return (Result){.code = 0};
}

Result lcd_st7735_rgb565_finish(St7735Context *ctx) {
  ctx->parent.interface->gpio_write(ctx->parent.interface->handle, true, true);
  return (Result){.code = 0};
}

extern Result lcd_st7735_set_font(St7735Context *ctx, const Font *font);

extern Result lcd_st7735_set_font_colors(St7735Context *ctx, uint32_t background_color, uint32_t foreground_color);

extern Result lcd_st7735_get_resolution(St7735Context *ctx, size_t *height, size_t *width);

Result lcd_st7735_close(St7735Context *ctx) { return (Result){.code = 0}; }