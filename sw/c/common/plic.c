#include "plic.h"
#include "demo_system.h"
#include "dev_access.h"

void plic_init(void) {
    // Enable machine external interrupts
    enable_interrupts(1 << 11);  // Set mie.meie bit
    
    // Set threshold to 0 (allow all priorities)
    plic_set_threshold(0);
}

void plic_set_priority(uint32_t source, uint32_t priority) {
    uint32_t addr = PLIC_BASE + PLIC_PRIORITY_BASE + (source * 4);
    DEV_WRITE(addr, priority & PLIC_PRIORITY_MASK);
}

void plic_enable_interrupt(uint32_t source) {
    uint32_t addr = PLIC_BASE + PLIC_ENABLE_BASE;
    uint32_t current = DEV_READ(addr);
    DEV_WRITE(addr, current | (1 << source));
}

void plic_disable_interrupt(uint32_t source) {
    uint32_t addr = PLIC_BASE + PLIC_ENABLE_BASE;
    uint32_t current = DEV_READ(addr);
    DEV_WRITE(addr, current & ~(1 << source));
}

void plic_set_threshold(uint32_t threshold) {
    DEV_WRITE(PLIC_BASE + PLIC_THRESHOLD_BASE, threshold & PLIC_PRIORITY_MASK);
}

uint32_t plic_claim_interrupt(void) {
    return DEV_READ(PLIC_BASE + PLIC_CLAIM_BASE);
}

void plic_complete_interrupt(uint32_t source) {
    DEV_WRITE(PLIC_BASE + PLIC_CLAIM_BASE, source);
}

void dump_plic_regs(void) {
  // Read the pending register from the PLIC.
  uint32_t pending = DEV_READ(PLIC_BASE + PLIC_PENDING_BASE);
  puts("PLIC pending: ");
  puthex(pending);
  putchar('\n');

  // Read the threshold register from the PLIC.
  uint32_t threshold = DEV_READ(PLIC_BASE + PLIC_THRESHOLD_BASE);
  puts("PLIC threshold: ");
  puthex(threshold);
  putchar('\n');
}
  