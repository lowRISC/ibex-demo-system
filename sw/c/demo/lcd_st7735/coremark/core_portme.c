// Copyright 2018 Embedded Microprocessor Benchmark Consortium (EEMBC)
// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "core_portme.h"
#include "coremark.h"

#include "demo_system.h"
#include "timer.h"

#define ITERATIONS 100

#if VALIDATION_RUN
volatile ee_s32 seed1_volatile = 0x3415;
volatile ee_s32 seed2_volatile = 0x3415;
volatile ee_s32 seed3_volatile = 0x66;
#endif
#if PERFORMANCE_RUN
volatile ee_s32 seed1_volatile = 0x0;
volatile ee_s32 seed2_volatile = 0x0;
volatile ee_s32 seed3_volatile = 0x66;
#endif
#if PROFILE_RUN
volatile ee_s32 seed1_volatile = 0x8;
volatile ee_s32 seed2_volatile = 0x8;
volatile ee_s32 seed3_volatile = 0x8;
#endif
volatile ee_s32 seed4_volatile = ITERATIONS;
volatile ee_s32 seed5_volatile = 0;

static uint64_t start_time_val, stop_time_val;

void start_time(void) {
    start_time_val = timer_read();
}

void stop_time(void) {
    stop_time_val = timer_read();
}

CORE_TICKS get_time(void) {
    return (CORE_TICKS)(stop_time_val - start_time_val);
}

secs_ret time_in_secs(CORE_TICKS ticks) {
  secs_ret retval = ((secs_ret)ticks) / (secs_ret)SYSCLK_FREQ;
  return retval;
}

ee_u32 default_num_contexts = 1;

void portable_init(core_portable *p, int *argc, char *argv[]) {
  p->portable_id = 1;
}

void portable_fini(core_portable *p) {
  CORE_TICKS elapsed = get_time();
  float coremark_mhz;

  coremark_mhz = (1000000.0f * (float)ITERATIONS) / elapsed;

  ee_printf("CoreMark / MHz: %f", coremark_mhz);

  p->portable_id = 0;
}
