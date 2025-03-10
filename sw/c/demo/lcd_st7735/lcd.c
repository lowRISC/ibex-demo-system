// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "lcd.h"

#include "st7735/lcd_st7735.h"
#include "string.h"

void lcd_show_menu(St7735Context *lcd, Menu_t *menu, size_t selected) {
  // Include 2 pixels for borders.
  uint32_t line_height = lcd->parent.font->height + 2;

  // Clean the screen.
  lcd_st7735_fill_rectangle(
      lcd, (LCD_rectangle){.origin = {.x = 0, .y = 0}, .width = lcd->parent.width, .height = line_height}, menu->color);

  // Invert background and foreground colors for the title.
  lcd_st7735_set_font_colors(lcd, menu->color, menu->background);
  lcd_println(lcd, menu->title, alined_center, (LCD_Point){.x = 0, .y = 1});
  // Set the colors for the menu items.
  lcd_st7735_set_font_colors(lcd, menu->background, menu->color);
  // Draw the menu items.
  for (int i = 0; i < menu->items_count; ++i) {
    lcd_println(lcd, menu->items[i], alined_left, (LCD_Point){.x = 1, .y = (i + 1) * line_height + 1});
  }

  // Draw a boarder around the selected item.
  // Increment `selected` to skip the title bar.
  selected++;
  lcd_st7735_draw_horizontal_line(
      lcd, (LCD_Line){{.x = 0, .y = line_height * selected}, lcd->parent.width}, menu->selected_color);
  lcd_st7735_draw_horizontal_line(
      lcd, (LCD_Line){{.x = 0, .y = line_height * (selected + 1) - 1}, lcd->parent.width},
      menu->selected_color);
  lcd_st7735_draw_vertical_line(
      lcd, (LCD_Line){{.x = 0, .y = line_height * selected}, line_height - 1},
      menu->selected_color);
  lcd_st7735_draw_vertical_line(
      lcd,
      (LCD_Line){{.x = lcd->parent.width - 1, .y = line_height * selected}, line_height - 1},
      menu->selected_color);
}

void lcd_println(St7735Context *lcd, const char *str, TextAlignment_t alignment, LCD_Point pos) {
  if (alignment != alined_left) {
    uint32_t line_width = 0;
    for (const char *ptr = str; *ptr; ptr++) {
      line_width += lcd->parent.font->descriptor_table[*ptr - lcd->parent.font->startCharacter].width;
    }

    if (alignment == alined_center) {
      pos.x = (lcd->parent.width - line_width) / 2;
    } else {
      pos.x = lcd->parent.width - pos.x - line_width;
    }
  }

  // Draw the text.
  lcd_st7735_puts(lcd, pos, str);
}
