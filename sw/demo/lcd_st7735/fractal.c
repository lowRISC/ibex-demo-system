// MIT License

// Copyright (c) 2022 Aras Güngöre

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include "string.h"
#include "fractal.h"
#include "lcd.h"

#define WIDTH 128
#define HEIGHT 160

#define RGB_COMPONENT_COLOR 255		// each component of the RGB color model defines the intensity of the color between 0-255

// Function to draw fractal_mandelbrot set
void fractal_mandelbrot(St7735Context *lcd, bool by_pixel)
{
    lcd_st7735_clean(lcd);
    LCD_rectangle rectangle = {.origin = {.x = 0, .y = 0},
    .width = HEIGHT, .height =WIDTH };
    // If drawing in the LCD pixel by pixel rather then line by line, initialize the pixel engine.
    if ( by_pixel ){
      lcd_st7735_rgb565_start(lcd, rectangle);
    }

	unsigned int iX, iY, iterator, counter = 0;
	const unsigned int iterationMax = 200;
	const double MinRe = -2.5, MaxRe = 1.5, MinIm = -2.0, escapeRadius = 2;
	const double MaxIm = MinIm + (MaxRe - MinRe) * WIDTH / HEIGHT ;
	const double Re_factor = (MaxRe - MinRe) / HEIGHT;
	const double Im_factor = (MaxIm - MinIm) / WIDTH;
	const double ER2 = escapeRadius*escapeRadius;
    uint16_t buffer[WIDTH];
	for(iY=0;iY<WIDTH;iY++) {
		double c_im = MaxIm - iY*Im_factor;
		for(iX=0;iX<HEIGHT;iX++) {
			double c_re = MinRe + iX*Re_factor;
			double Z_re = c_re, Z_im = c_im;
			for(iterator=0;iterator<iterationMax;iterator++) {
				double Z_re2 = Z_re*Z_re, Z_im2 = Z_im*Z_im;
				if(Z_re2 + Z_im2 > ER2)
					break;
				Z_im = 2*Z_re*Z_im + c_im;
            	Z_re = Z_re2 - Z_im2 + c_re;
			}
			double x = (double)iterator / iterationMax * RGB_COMPONENT_COLOR;
            uint32_t color = 0;
			if(x < RGB_COMPONENT_COLOR/2) {
				color = (int)(15*x/8 + 16) << 16 | 0 << 8 | 0;
			}
			else if(x < RGB_COMPONENT_COLOR) {
                color = RGB_COMPONENT_COLOR << 16 | (int)(2*x - RGB_COMPONENT_COLOR) << 8 |  (int)(2*x - RGB_COMPONENT_COLOR);
			}
            // Send the pixel If we are drawing in the LCD pixel by pixel, 
            // otherwise we buffer it to write the whole line latter.
            if ( by_pixel ){
              uint16_t bgr = LCD_rgb24_to_bgr565(color);
              lcd_st7735_rgb565_put(lcd, (uint8_t*)&bgr, sizeof(bgr));
            }else {
              buffer[iX] = LCD_rgb24_to_bgr565(color);
            }
			counter++;
		}
        // Send the buffered line.
        if ( !by_pixel ){
            rectangle.origin.x = iY;
            rectangle.origin.y = 0;
            rectangle.width = 1;
            rectangle.height = HEIGHT;
            lcd_st7735_draw_rgb565(lcd, rectangle, (uint8_t*)buffer);
        }
	}
    lcd_st7735_rgb565_finish(lcd);
}

void fractal_bifurcation(St7735Context *lcd){
    size_t w, h;
    lcd_st7735_get_resolution(lcd, &h, &w);

    lcd_st7735_fill_rectangle(lcd, (LCD_rectangle){.origin = {.x = 0, .y = 0},
    .width = w, .height = h}, BGRColorBlack);

}
