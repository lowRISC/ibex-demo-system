
// Copyright (c) 2022 Douglas Reis.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef DISPLAY_DRIVERS_ST7735_ST7735_H_
#define DISPLAY_DRIVERS_ST7735_ST7735_H_

#include "../core/font.h"
#include "../core/lcd_base.h"
#include "lcd_st7735_cmds.h"

/**
 * @brief Context struct.
 *
 */
typedef struct stSt7735Context {
  LCD_Context parent; /*!< Base context*/
} St7735Context;

/**
 * @brief Initialize the LCD driver.
 *
 * Example:
 * ```C
 * LCD_Interface interface = {
 *      .handle = NULL,
 *      .spi_write = spi_write,
 *      .gpio_write = gpio_write,
 *      .timer_delay = timer_delay,
 *  };
 * St7735Context ctx;
 * lcd_st7735_init(&ctx, &interface);
 *
 * ```
 *
 * @param ctx Handle.
 * @param interface Callback functions to provide access to the SPI, GPIO and Timer.
 * @return Result of the operation.
 */
Result lcd_st7735_init(St7735Context *ctx, LCD_Interface *interface);

/**
 * @brief Clean the screen by drawing a write rectangle.
 *
 * @param ctx Handle.
 * @return Result of the operation.the operation.
 */
Result lcd_st7735_clean(St7735Context *ctx);

/**
 * @brief Read the display resolution.
 *
 * @param ctx Handle.
 * @param[out] height Pointer to receive the hight in pixels.
 * @param[out] width Pointer to receive the width in pixels.
 * @return Result of the operation.
 */
inline Result lcd_st7735_get_resolution(St7735Context *ctx, size_t *height, size_t *width) {
  return LCD_get_resolution(&ctx->parent, height, width);
}

/**
 * @brief Draw a single pixel.
 *
 * @param ctx Handle.
 * @param pixel Coordinates of the pixel.
 * @param color Color in RGB 24 bits format.
 * @return Result of the operation.
 */
Result lcd_st7735_draw_pixel(St7735Context *ctx, LCD_Point pixel, uint32_t color);

/**
 * @brief Draw a vertical line.
 *
 * @param ctx Handle.
 * @param line Coordinates and size of the line.
 * @param color Color in RGB 24 bits format.
 * @return Result of the operation.
 */
Result lcd_st7735_draw_vertical_line(St7735Context *ctx, LCD_Line line, uint32_t color);

/**
 * @brief Draw a horizontal line.
 *
 * @param ctx Handle.
 * @param line Coordinates and size of the line.
 * @param color Color in RGB 24 bits format.
 * @return Result of the operation.
 */
Result lcd_st7735_draw_horizontal_line(St7735Context *ctx, LCD_Line line, uint32_t color);

/**
 * @brief Draw a image in bgr 24bits format.
 *
 * @param ctx Handle.
 * @param rectangle Definition of the area used by the image.
 * @param bgr Pointer to a buffer containing the image. Each pixel is defined by 3 bytes.
 * @return Result of the operation.
 */
Result lcd_st7735_draw_bgr(St7735Context *ctx, LCD_rectangle rectangle, const uint8_t *bgr);

/**
 * @brief Draw a image in rgb 16bits format.
 *
 * @param ctx Handle.
 * @param rectangle Definition of the area used by the image.
 * @param bgr Pointer to a buffer containing the image. Each pixel is defined by 2 bytes.
 * @return Result of the operation.
 */
Result lcd_st7735_draw_rgb565(St7735Context *ctx, LCD_rectangle rectangle, const uint8_t *rgb);

/**
 * @brief Starts the iterative draw session.
 *
 * @param ctx Handle.
 * @param rectangle Definition of the area used by the image.
 * @return Result of the operation.
 */
Result lcd_st7735_rgb565_start(St7735Context *ctx, LCD_rectangle rectangle);

/**
 * @brief Starts a session to draw a RGB BMP iteratively.
 *
 * @param ctx Handle.
 * @param rectangle Definition of the area used by the image.
 * @param bgr Pointer to a buffer containing the image. Each pixel is defined by 2 bytes.
 * @param size Size of the buffer in bytes.
 * @return Result of the operation.
 */
Result lcd_st7735_rgb565_put(St7735Context *ctx, const uint8_t *rgb, size_t size);

/**
 * @brief Finish the iterative draw session.
 *
 * @param ctx Handle.
 * @return Result of the operation.
 */
Result lcd_st7735_rgb565_finish(St7735Context *ctx);

/**
 * @brief Draw a solid rectangle.
 *
 * @param ctx Handle.
 * @param rectangle Definition of the rectangle area.
 * @param color Color in RGB 24 bits format.
 * @return Result of the operation.
 */
Result lcd_st7735_fill_rectangle(St7735Context *ctx, LCD_rectangle rectangle, uint32_t color);

/**
 * @brief Set the font to be used to print text.
 *
 * @param ctx Handle.
 * @param font Pointer to the font to be used.
 * @return Result of the operation.
 */
inline Result lcd_st7735_set_font(St7735Context *ctx, const Font *font) { return LCD_set_font(&ctx->parent, font); }

/**
 * @brief Set the background and foreground colors for text printing.
 *
 * @param ctx Handle.
 * @param background_color  Color in RGB 24 bits format.
 * @param foreground_color  Color in RGB 24 bits format.
 * @return Result of the operation.
 */
inline Result lcd_st7735_set_font_colors(St7735Context *ctx, uint32_t background_color, uint32_t foreground_color) {
  return LCD_set_font_colors(&ctx->parent, LCD_rgb24_to_bgr565(background_color),
                             LCD_rgb24_to_bgr565(foreground_color));
}

/**
 * @brief Draw an ASCII character.
 *
 * @param ctx Handle.
 * @param origin The origin coordinate of the character.
 * @param character The ASCII character to be printed.
 * @return Result of the operation.
 */
Result lcd_st7735_putchar(St7735Context *ctx, LCD_Point origin, char character);

/**
 * @brief Draw a string using ASCII characters.
 *
 * @param ctx Handle.
 * @param origin The origin coordinate of the first character.
 * @param text Pointer to a null terminated string.
 * @return Result of the operation.
 */
Result lcd_st7735_puts(St7735Context *ctx, LCD_Point origin, const char *text);

/**
 * @brief Set the display orientation
 *
 * @param ctx Handle.
 * @param orientation The orientation to be set.
 * @return Result of the operation
 */
Result lcd_st7735_set_orientation(St7735Context *ctx, LCD_Orientation orientation);

/**
 * @brief Finish.
 *
 * @param ctx Handle.
 * @return Result of the operation.
 */
Result lcd_st7735_close(St7735Context *ctx);

#endif