#include "demo_system.h"
#include "timer.h"
#include "gpio.h"

void test_uart_irq_handler(void) __attribute__((interrupt));

void test_uart_irq_handler(void) {
  int uart_in_char;

  while ((uart_in_char = uart_in(DEFAULT_UART)) != -1) {
    uart_out(DEFAULT_UART, uart_in_char);
    uart_out(DEFAULT_UART, '\r');
    uart_out(DEFAULT_UART, '\n');
  }
}

int main(void) {
  uart_enable_rx_int();
  install_exception_handler(UART_IRQ, &test_uart_irq_handler);

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
      // Disable interrupts whilst outputting to prevent output for RX IRQ
      // happening in the middle
      set_global_interrupt_enable(0);

      puts("Hello World! ");
      puthex(last_elapsed_time);
      putchar('\n');

      // Re-enable interrupts with output complete
      set_global_interrupt_enable(1);
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
