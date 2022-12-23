// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "string.h"
#include "fractal.h"
#include "lcd.h"

#define WIDTH 128
#define HEIGHT 160

const uint32_t colors[] = {
  0x000000, //BLACK
  0x0000AA, //BLUE
  0x00AA00, //GREEN
  0x00AAAA, //CYAN
  0xAA0000, //RED
  0xAA00AA, //MAGENTA
  0xAA5500, //BROWN
  0xAAAAAA, //LIGHT_GREY
  0x555555, //DARK_GREY
  0x5555FF, //BRIGHT_BLUE
  0x55FF55, //BRIGHT_GREEN
  0x55FFFF, //BRIGHT_CYAN
  0xFF5555, //BRIGHT_RED
  0xFF55FF, //BRIGHT_MAGENTA
  0xFFFF55, //YELLOW
  0xFFFFFF, //WHITE
};

const int colornum = sizeof(colors) / sizeof(colors[0]);

// Function to draw fractal_mandelbrot set
void fractal_mandelbrot(St7735Context *lcd, bool by_pixel)
{
    int max_iterations = 512;
    int max_size = 4;
  
    /*
     * dimensions of the complex plane
     */
    float x_min = -2.0;
    float x_max = 2.0;
    float y_min = -2.0;
    float y_max = 2.0;
  
    // calling rectangle function
    // where required image will be seen

    lcd_st7735_clean(lcd);
  
     /*
     * For each row and each column set real and imag parts of the complex
     * number to be used in iteration
     */
    float delta_x = (x_max - x_min) / WIDTH;
    float delta_y = (y_max - y_min) / HEIGHT;

    float Q[HEIGHT] = { y_max };
    float P[WIDTH] = { x_min };
    for (int row = 1; row < HEIGHT; row++)
        Q[row] = Q[row - 1] - delta_y;
    for (int col = 1; col < WIDTH; col++ )
        P[col] = P[col - 1] + delta_x;
    LCD_rectangle rectangle = {.origin = {.x = 0, .y = 0},
        .width = HEIGHT, .height =WIDTH };
    
    // If drawing in the LCD pixel by pixel rather then line by line, initialize the pixel engine.
    if ( by_pixel ){
      lcd_st7735_rgb565_start(lcd, rectangle);
    }

    /*
     * For every pixel calculate resulting value until the number becomes too
     * big, or we run out of iterations
     */
    uint16_t buffer[WIDTH];
    for (int col = 0; col < WIDTH; col++ ) {
        for (int row = 0; row < HEIGHT; row++ ) {
            float x_square = 0.0;
            float y_square = 0.0;
            float x = 0.0;
            float y = 0.0;

            int color = 1;
            while (color < max_iterations && x_square + y_square < max_size) {
                x_square = x * x;
                y_square = y * y;
                y = 2 * x * y + Q[row];
                x = x_square - y_square + P[col];
                color++;
            }


            // Send the pixel If we are drawing in the LCD pixel by pixel, 
            // otherwise we buffer it to write the whole line latter.
            if ( by_pixel ){
              uint16_t rgb = LCD_rgb24_to_bgr565(colors[color % colornum]);
              lcd_st7735_rgb565_put(lcd, (uint8_t*)&rgb, sizeof(rgb));
            }else {
              buffer[row] = LCD_rgb24_to_bgr565(colors[color % colornum]);
            }
        }

        // Send the buffered line.
         if ( !by_pixel ){
            rectangle.origin.x = col;
            rectangle.origin.y = 0;
            rectangle.width = 1;
            rectangle.height = HEIGHT;
            lcd_st7735_draw_rgb565(lcd, rectangle, (uint8_t*)buffer);
         }
    }
    lcd_st7735_rgb565_finish(lcd);
}

void fractal_bifurcation(St7735Context *lcd){
    float r = .995, x_init = 0.5;
    size_t w, h;
    lcd_st7735_get_resolution(lcd, &h, &w);

    lcd_st7735_fill_rectangle(lcd, (LCD_rectangle){.origin = {.x = 0, .y = 0},
    .width = w, .height = h}, BGRColorBlack);
    /* Population equation */
    float delta_r = 0.005;
    for (int col = 0; col < 639; col++) {
        float x = x_init;
        r += delta_r;
        for (int i = 0; i < 256; ++i) {
            x = r * x * (1 - x);
            if ((x > 1000000) || (x < -1000000))
                break;

            int row = 349 - (x * 350);
            if (i > 64 && row < 349 && row >= 0 && col >= 0 && col < 639) {
                // ppm_dot_safe(ppm, col, row, PPM_WHITE);
                lcd_st7735_draw_pixel(lcd, (LCD_Point){.x = col%w, .y = row%h}, BGRColorWhite);
            }
        }
    }

}