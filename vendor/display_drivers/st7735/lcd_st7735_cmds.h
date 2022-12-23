// This is a library for several Adafruit displays based on ST77* drivers.

//   Works with the Adafruit 1.8" TFT Breakout w/SD card
//     ----> http://www.adafruit.com/products/358
//   The 1.8" TFT shield
//     ----> https://www.adafruit.com/product/802
//   The 1.44" TFT breakout
//     ----> https://www.adafruit.com/product/2088
//   as well as Adafruit raw 1.8" TFT display
//     ----> http://www.adafruit.com/products/618
 
// Check out the links above for our tutorials and wiring diagrams.
// These displays use SPI to communicate, 4 or 5 pins are required to
// interface (RST is optional).

// Adafruit invests time and resources providing this open source code,
// please support Adafruit and open-source hardware by purchasing
// products from Adafruit!

// Written by Limor Fried/Ladyada for Adafruit Industries.
// MIT license, all text above must be included in any redistribution.

// Recent Arduino IDE releases include the Library Manager for easy installation. Otherwise, to download, click the DOWNLOAD ZIP button, uncompress and rename the uncompressed folder Adafruit_ST7735. Confirm that the Adafruit_ST7735 folder contains Adafruit_ST7735.cpp, Adafruit_ST7735.h and related source files. Place the Adafruit_ST7735 library folder your ArduinoSketchFolder/Libraries/ folder. You may need to create the Libraries subfolder if its your first library. Restart the IDE.

// Also requires the Adafruit_GFX library for Arduino.

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
