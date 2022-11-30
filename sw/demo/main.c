#include "demo_system.h"
#include "timer.h"
#include "gpio.h"

int main(void) {
  timer_init();
  timer_enable(50000000);

  uint64_t last_elapsed_time = get_elapsed_time();
  uint32_t cur_output_bit = 1;
  uint32_t cur_output_bit_index = 0;

  set_outputs(GPIO0, 0x0);

  while(1) {
    uint64_t cur_time = get_elapsed_time();

    if (cur_time != last_elapsed_time) {
      last_elapsed_time = cur_time;
      puts("Hello World! ");
      puthex(last_elapsed_time);
      putchar('\n');
      set_output_bit(GPIO0, cur_output_bit_index, cur_output_bit);

      cur_output_bit_index++;
      if (cur_output_bit_index >= 16) {
        cur_output_bit_index = 0;
        cur_output_bit = !cur_output_bit;
      }
    }

    asm volatile ("wfi");
  }
}
