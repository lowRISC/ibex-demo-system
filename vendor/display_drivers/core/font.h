

// Copyright (c) 2022 Douglas Reis.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef COMMON_FONT_H
#define COMMON_FONT_H

#include <stdint.h>

typedef struct FontCharInfo_st {
  unsigned char width;
  unsigned short position;
} FontCharInfo;

typedef struct Font_st {
  unsigned char height;                 /*<  */
  unsigned char startCharacter;         /*< first char of the  ASCII table found in the bitmap array. */
  unsigned char endCharacter;           /*< last char of the ASCII table found in the bitmap array. */
  const FontCharInfo *descriptor_table; /*< Character descriptor array. */
  const unsigned char *bitmap_table;    /*< Character bitmap array. */
} Font;

#endif