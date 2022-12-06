
// Copyright (c) 2022 Douglas Reis.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef DISPLAY_DRIVERS_ST7735_ST7735_CMD_H_
#define DISPLAY_DRIVERS_ST7735_ST7735_CMD_H_

typedef enum {
  ST7735_NOP     = 0x00,
  ST7735_SWRESET = 0x01,
  ST7735_RDDID   = 0x04,
  ST7735_RDDST   = 0x09,
  ST7735_SLPIN   = 0x10,
  ST7735_SLPOUT  = 0x11,
  ST7735_PTLON   = 0x12,
  ST7735_NORON   = 0x13,
  ST7735_INVOFF  = 0x20,
  ST7735_INVON   = 0x21,
  ST7735_DISPOFF = 0x28,
  ST7735_DISPON  = 0x29,
  ST7735_CASET   = 0x2A,
  ST7735_RASET   = 0x2B,
  ST7735_RAMWR   = 0x2C,
  ST7735_RAMRD   = 0x2E,
  ST7735_PTLAR   = 0x30,
  ST7735_COLMOD  = 0x3A,
  ST7735_MADCTL  = 0x36,
  ST7735_FRMCTR1 = 0xB1,
  ST7735_FRMCTR2 = 0xB2,
  ST7735_FRMCTR3 = 0xB3,
  ST7735_INVCTR  = 0xB4,
  ST7735_DISSET5 = 0xB6,
  ST7735_PWCTR1  = 0xC0,
  ST7735_PWCTR2  = 0xC1,
  ST7735_PWCTR3  = 0xC2,
  ST7735_PWCTR4  = 0xC3,
  ST7735_PWCTR5  = 0xC4,
  ST7735_VMCTR1  = 0xC5,
  ST7735_RDID1   = 0xDA,
  ST7735_RDID2   = 0xDB,
  ST7735_RDID3   = 0xDC,
  ST7735_RDID4   = 0xDD,
  ST7735_PWCTR6  = 0xFC,
  ST7735_GMCTRP1 = 0xE0,
  ST7735_GMCTRN1 = 0xE1,
} ST7735_Cmd;

typedef enum {
  ST77_MADCTL_MX  = 0x01 << 7, //Column Address Order
  ST77_MADCTL_MV  = 0x01 << 6, //Row/Column Exchange 
  ST77_MADCTL_MY  = 0x01 << 5, //Row Address Order
  ST77_MADCTL_ML  = 0x01 << 4,
  ST77_MADCTL_RGB = 0x01 << 3,
  ST77_MADCTL_MH  = 0x01 << 2
}ST77_MADCTL_Bits;

// Color definitions
typedef enum {
  ST7735_ColorBlack   = 0x0000,
  ST7735_ColorBlue    = 0x001F,
  ST7735_ColorRed     = 0xF800,
  ST7735_ColorGreen   = 0xE007,
  ST7735_ColorCyan    = 0x07FF,
  ST7735_ColorMagenta = 0xF81F,
  ST7735_ColorYellow  = 0xFFE0,
  ST7735_ColorWhite   = 0xFFFF,
} ST7735_Color;

#endif