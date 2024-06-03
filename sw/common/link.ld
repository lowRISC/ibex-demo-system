/* Copyright lowRISC contributors.
   Licensed under the Apache License, Version 2.0, see LICENSE for details.
   SPDX-License-Identifier: Apache-2.0 */

OUTPUT_ARCH(riscv)

MEMORY
{
    /* 124 KiB should be enough for anybody... */
    ram         : ORIGIN = 0x00100000, LENGTH = 0x1E000 /* 124 KiB */
    stack       : ORIGIN = 0x0011E000, LENGTH = 0x02000 /*   4 KiB */
}

/* Stack information variables */
_min_stack      = 0x1000;   /* 4K - minimum stack space to reserve */
_stack_len     = LENGTH(stack);
_stack_start   = ORIGIN(stack) + LENGTH(stack);

_entry_point = _vectors_start + 0x80;
ENTRY(_entry_point)

/* Rust dependency */
PROVIDE(_stext = ORIGIN(ram));
PROVIDE(_stack_start = ORIGIN(stack) + LENGTH(stack));
PROVIDE(_max_hart_id = 0);
PROVIDE(_hart_stack_size = LENGTH(stack));
PROVIDE(_heap_size = 0);
PROVIDE(UserSoft = DefaultHandler);
PROVIDE(SupervisorSoft = DefaultHandler);
PROVIDE(MachineSoft = DefaultHandler);
PROVIDE(UserTimer = DefaultHandler);
PROVIDE(SupervisorTimer = DefaultHandler);
PROVIDE(MachineTimer = DefaultHandler);
PROVIDE(UserExternal = DefaultHandler);
PROVIDE(SupervisorExternal = DefaultHandler);
PROVIDE(MachineExternal = DefaultHandler);
PROVIDE(DefaultHandler = DefaultInterruptHandler);
PROVIDE(ExceptionHandler = DefaultExceptionHandler);
PROVIDE(__pre_init = default_pre_init);
PROVIDE(_mp_hook = default_mp_hook);
PROVIDE(_start_trap = default_start_trap);
PROVIDE(_setup_interrupts = default_setup_interrupts);

SECTIONS
{
    .text : {
        . = ALIGN(4);

		_vectors_start = .;
        KEEP(*(.vectors))
		_vectors_end = .;
        
        /* Rust dependency */
        KEEP(*(.init));
        KEEP(*(.init.rust));

        *(.text)
        *(.text.*)
        . = ALIGN(4);
    }  > ram

    .rodata : {
        . = ALIGN(4);
        /* Small RO data before large RO data */
        *(.srodata)
        *(.srodata.*)
        *(.rodata);
        *(.rodata.*)
        . = ALIGN(4);
    } > ram

    .data : {
        . = ALIGN(4);
        _sidata = LOADADDR(.data);
        _sdata = .;

        /* Small data before large data */
        *(.sdata)
        *(.sdata.*)
        *(.data);
        *(.data.*)
        . = ALIGN(4);
        _edata = .;
    } > ram

    .bss :
    {
        . = ALIGN(4);
        _bss_start = .;
        /* Small BSS before large BSS */
        *(.sbss)
        *(.sbss.*)
        *(.bss)
        *(.bss.*)
        *(COMMON)
        _bss_end = .;
        . = ALIGN(4);
    } > ram
    /* Rust dependency */
    _sbss = _bss_start;
    _ebss = _bss_end;

    /* ensure there is enough room for stack */
    .stack (NOLOAD): {
        . = ALIGN(4);
        . = . + _min_stack ;
        . = ALIGN(4);
        stack = . ;
        _stack = . ;
    } > stack
}

