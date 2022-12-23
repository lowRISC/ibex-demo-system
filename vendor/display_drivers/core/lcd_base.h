
// Copyright (c) 2022 Douglas Reis.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef DISPLAY_DRIVERS_COMMON_BASE_H_
#define DISPLAY_DRIVERS_COMMON_BASE_H_

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "font.h"

// TODO: define a way to check endianess in multiple platforms.
#define LCD_IS_LITTLE_ENDIAN 1

#if LCD_IS_LITTLE_ENDIAN
#define ENDIANESS_TO_HALF_WORD(_x) (uint16_t)((_x >> 8) | (_x << 8))
#else
#define ENDIANESS_TO_HALF_WORD(_x) (uint16_t)(_x)
#endif

#define MIN(_A, _B) _A > _B ? _B : _A
#define MAX(_A, _B) _A < _B ? _B : _A

typedef enum {
  LCD_Rotate_0  = 0,
  LCD_Rotate90,
  LCD_Rotate180,
  LCD_Rotate270,
} LCD_Orientation;

// TODO: Define error codes.
typedef struct Result_st {
  uint32_t code; /*!< */
} Result;

/**
 * @brief Struct with the callbacks needed by the display driver to access the hardware.
 */
typedef struct LCD_Interface_st {
  void *handle; /*!< Pointer that will passed to the callbacks calls. It is reserved for exclusive use of the
                   application. If not intended to be used it can be `NULL` */

  /**
   * @brief Send data through spi interface.
   *
   * @param data Pointer to data array to be sent.
   * @param len Len of the data to be sent.
   *
   * @return the number of data sent.
   */
  uint32_t (*spi_write)(void *handle, uint8_t *data, size_t len);

  /**
   * @brief Set the state of the chip select and D/C pins.
   *
   * @param cs_high Set chip select pin to 1 if true, otherwise 0.
   * @param dc_high Set D/C pin to 1 if true, otherwise 0.
   *
   */
  uint32_t (*gpio_write)(void *handle, bool cs_high, bool dc_high);

  /**
   * @brief Simple cpu delay
   *
   * @param ms Time the delay should take in milliseconds.
   *
   */
  void (*timer_delay)(uint32_t ms);
} LCD_Interface;

typedef struct LCD_Context_st {
  LCD_Interface *interface;  /*!< */
  uint32_t width;            /*!< */
  uint32_t height;           /*!< */
  const Font *font;          /*!< */
  uint32_t background_color; /*<  */
  uint32_t foreground_color; /*<  */
} LCD_Context;

typedef struct LCD_Point_st {
  uint32_t x; /*!< X coordinate.*/
  uint32_t y; /*!< y coordinate.*/
} LCD_Point;

typedef struct LCD_Line_st {
  LCD_Point origin; /*!< Coordinates of the origin.*/
  size_t length;    /*!< Length of the line from the origin.*/
} LCD_Line;

typedef struct LCD_rectangle_st {
  LCD_Point origin; /*!< Coordinates of the origin.*/
  size_t width;     /*!< Width.*/
  size_t height;    /*!< Height.*/
} LCD_rectangle;

Result LCD_Init(LCD_Context *ctx, LCD_Interface *interface, uint32_t width, uint32_t height);

inline Result LCD_get_resolution(LCD_Context *ctx, size_t *height, size_t *width) {
  *height = ctx->height;
  *width  = ctx->width;
  return (Result){.code = 0};
}

inline Result LCD_set_font_colors(LCD_Context *ctx, uint32_t background_color, uint32_t foreground_color) {
  ctx->background_color = background_color;
  ctx->foreground_color = foreground_color;
  return (Result){.code = 0};
}

inline Result LCD_set_font(LCD_Context *ctx, const Font *font) {
  ctx->font = font;
  LCD_set_font_colors(ctx, 0xffffff, 0x00);
  return (Result){.code = 0};
}

uint16_t LCD_rgb24_to_bgr565(uint32_t color);
uint16_t LCD_rgb565_to_bgr565(const uint8_t rgb[2]);
#endif
