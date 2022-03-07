#ifndef GPIO_H__
#define GPIO_H__

#include <stdint.h>

#define GPIO_OUT_REG 0x0

typedef void* gpio_t;

#define GPIO_FROM_BASE_ADDR(addr)((gpio_t)addr)

void set_outputs(gpio_t gpio, uint32_t outputs);
uint32_t get_outputs(gpio_t gpio);

void set_output_bit(gpio_t gpio, uint32_t output_bit_index,
    uint32_t output_bit);

uint32_t get_output_bit(gpio_t gpio, uint32_t output_bit_index);

#endif
