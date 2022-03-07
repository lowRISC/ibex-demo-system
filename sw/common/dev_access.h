#ifndef DEV_ACCESS_H_
#define DEV_ACCESS_H_

#include <stdint.h>

#define DEV_WRITE(addr, val) (*((volatile uint32_t *)(addr)) = val)
#define DEV_READ(addr) (*((volatile uint32_t *)(addr)))

#endif // DEV_ACCESS_H_
