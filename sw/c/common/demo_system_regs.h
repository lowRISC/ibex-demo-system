// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef DEMO_SYSTEM_REGS_H__
#define DEMO_SYSTEM_REGS_H__

#define UART0_BASE 0x80001000

#define GPIO_BASE 0x80000000

#define TIMER_BASE 0x80002000

#define PWM_BASE 0x80003000

#define SPI0_BASE 0x80004000

#define SIM_CTRL_BASE 0x20000
#define SIM_CTRL_OUT 0x0
#define SIM_CTRL_CTRL 0x8

// Add PLIC definitions
#define PLIC_BASE               0x80001000

// PLIC Register offsets
#define PLIC_PRIORITY_BASE      0x000000
#define PLIC_PENDING_BASE       0x001000
#define PLIC_ENABLE_BASE        0x002000
#define PLIC_THRESHOLD_BASE     0x200000
#define PLIC_CLAIM_BASE         0x200004

// PLIC configuration
#define PLIC_MAX_PRIORITY       7
#define PLIC_PRIORITY_MASK      0x7

// Source IDs
#define PLIC_SOURCE_UART0       0

#endif
