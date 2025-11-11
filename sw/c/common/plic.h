#ifndef PLIC_H__
#define PLIC_H__

#include <stdint.h>

// Initialize PLIC
void plic_init(void);

// Set priority for an interrupt source
void plic_set_priority(uint32_t source, uint32_t priority);

// Enable/disable interrupt source
void plic_enable_interrupt(uint32_t source);
void plic_disable_interrupt(uint32_t source);

// Set priority threshold
void plic_set_threshold(uint32_t threshold);

// Claim and complete interrupts
uint32_t plic_claim_interrupt(void);
void plic_complete_interrupt(uint32_t source);

// Check register values
void dump_plic_regs(void);


#endif  // PLIC_H__ 