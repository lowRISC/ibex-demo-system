// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef LCD_ST_7735_LCD
#define LCD_ST_7735_LCD

#include "st7735/lcd_st7735.h"
#include "string.h"

// Color codes in BGR format.
enum {
  BGRColorBlack = 0x000000,
  BGRColorBlue  = 0xFF0000,
  BGRColorGreen = 0x00FF00,
  BGRColorRed   = 0x0000FF,
  BGRColorWhite = 0xFFFFFF,
};

// Text alignment.
typedef enum TextAlignment {
  alined_right,
  alined_center,
  alined_left,
} TextAlignment_t;

/**
 * @brief Draw a NULL terminated string in the screen.
 *
 * @param lcd LCD handle.
 * @param str NULL terminated string.
 * @param alignment Text horizontal alignment in the screen.
 * @param pos Position of the line. The x component indicates horizontal padding.
 */
void lcd_println(St7735Context *lcd, const char *str, TextAlignment_t alignment, LCD_Point pos);

typedef struct Menu {
  const char *title;        // Pointer to a NULL terminated string to be used as the title.
  const char **items;       // Pointer to a array of NULL terminated strings with the menus.
  size_t items_count;       // Size of the items array.
  uint32_t color;           // Foreground color (text color).
  uint32_t background;      // Background color.
  uint32_t selected_color;  // Color of the selection box.
} Menu_t;

/**
 * @brief Draw a menu in the screen.
 *
 * @param lcd LCD handle.
 * @param menu Menu configuration.
 * @param selected Index of the selected menu item
 */
void lcd_show_menu(St7735Context *lcd, Menu_t *menu, size_t selected);
#endif
