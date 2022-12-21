#include "demo_system.h"
#include "timer.h"
#include "gpio.h"
#include "pwm.h"
#include <stdbool.h>

#define USE_GPIO_SHIFT_REG 0

int main(void) {
  // This indicates how often the timer gets updated.
  timer_init();
  timer_enable(5000000);

  uint64_t last_elapsed_time = get_elapsed_time();

  // Reset green LEDs to off
  set_outputs(GPIO_OUT, 0x0);

  // PWM variables
  uint32_t counter = UINT8_MAX;
  uint32_t brightness = 0;
  bool ascending = true;
  // The three least significant bits correspond to RGB, where B is the leas significant.
  uint8_t color = 7;

  while(1) {
    uint64_t cur_time = get_elapsed_time();

    if (cur_time != last_elapsed_time) {
      last_elapsed_time = cur_time;

      // Print this to UART (use the screen command to see it).
      puts("Hello World! ");
      puthex(last_elapsed_time);
      puts("   Input Value: ");
      uint32_t in_val = read_gpio(GPIO_IN_DBNC);
      puthex(in_val);
      putchar('\n');

      // Cycling through green LEDs when BTN0 is pressed
      if (USE_GPIO_SHIFT_REG) {
        set_outputs(GPIO_OUT_SHIFT, in_val);
      } else {
        uint32_t out_val = read_gpio(GPIO_OUT);
        out_val = ((out_val << 1) & GPIO_OUT_MASK) | (in_val & 0x1);
        set_outputs(GPIO_OUT, out_val);
      }

      // Going from bright to dim on PWM
      for(int i = 0; i < NUM_PWM_MODULES; i++) {
        set_pwm(PWM_FROM_ADDR_AND_INDEX(PWM_BASE, i),
            ((1 << (i%3)) & color) ? counter : 0,
            brightness ? 1 << (brightness - 1) : 0);
      }
      if (ascending) {
        brightness++;
        if (brightness >= 5) {
          ascending = false;
        }
      } else {
        brightness--;
        // When LEDs are off cycle through the colors
        if (brightness == 0) {
          ascending = true;
          color++;
          if (color >= 8) {
            color = 1;
          }
        }
      }
    }

    asm volatile ("wfi");
  }
}
