#include "demo_system.h"
#include "timer.h"
#include "gpio.h"

// Comment out the line below to disable the RX interrupt and
// have the ibex_super_system generate the text written to TX
#define UART_RX_ENABLED

#ifdef UART_RX_ENABLED
void test_uart_irq_handler(void) __attribute__((interrupt));

void test_uart_irq_handler(void) {
  int uart_in_char;

  while ((uart_in_char = uart_in(DEFAULT_UART)) != -1) {
    uart_out(DEFAULT_UART, uart_in_char);
    uart_out(DEFAULT_UART, '\r');
    uart_out(DEFAULT_UART, '\n');
  }
}
#endif

int main(void) {
  #ifdef UART_RX_ENABLED
  uart_enable_rx_int();
  install_exception_handler(16, &test_uart_irq_handler);
  #endif
  // enable global interrupt
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
      #ifndef UART_RX_ENABLED
      puts("Hello World! ");
      puthex(last_elapsed_time);
      putchar('\n');
      #endif
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
