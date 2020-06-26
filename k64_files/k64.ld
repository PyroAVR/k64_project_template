/*
 * Original Source:
 * K64F ARM GCC linker script file, ARMmbed target-kinetis-k64-gcc
 * Modified: Andy Meyer <ahm7197@rit.edu>
 *  - Removed mbed-specific code to allow baremetal development.
 *  - Removed C++ specific support code.
 */
/*
 * Some convenient globals
 * K64 MEMORY LAYOUT (LOW ADDRESSES AT BOTTOM)
 * ====== END OF 32-BIT ADDRESS SPACE ======
 * NOT MAPPED        |
 * ====== END RAM ======
 * RAM_HIGH_ADDR     | STACK_TOP
 * STACK_LOW_ADDR    | END OF GLOBAL STACK
 * HEAP_HIGH_ADDR    | END OF GLOBAL HEAP
 * HEAP_LOW_ADDR     | 
 * ====== END MMIO ======
 * MEMORY-MAPPED IO  |
 * ====== END FLASH MEMORY ======
 * FLASH_HIGH_ADDR   | FLASH MEMORY HIGH ADDR
 *                   | CONSTANTS, ETC.
 *    - FLASH -      | PROGRAM CODE + LITERAL POOLS
 *                   |
 * FLASH PROTECTION  |
 * VECTOR_TABLE_SIZE | FLASH PROT. START
 * 0x0               | VECTOR TABLE START
 */

/*We use *_LOW_ADDR and *_HIGH_ADDR to denote PHYSICAL deliminations, and
 * *_START, *_STOP to denote software-definied deliminations.  START and STOP
 * are chosen such that they align with the typical growth direction for the
 * given memory segment.
 */
VECTOR_TABLE_SIZE = 0x400;

FLASH_PROTECTION_LOW_ADDR = VECTOR_TABLE_SIZE;
FLASH_PROECTION_SIZE = 0x10;

FLASH_HIGH_ADDR = 0x00100000;
FLASH_LOW_ADDR = (VECTOR_TABLE_SIZE + FLASH_PROECTION_SIZE);
FLASH_SIZE = FLASH_HIGH_ADDR - (VECTOR_TABLE_SIZE + FLASH_PROECTION_SIZE);

RAM_LOW_ADDR = 0x1FFF0000;
RAM_HIGH_ADDR = 0x20030000;
RAM_SIZE = RAM_HIGH_ADDR - RAM_LOW_ADDR;

/* Remember that the stack growns DOWN, so the START of the stack is at the TOP
 * of memory. _stack_top points to this, and is the initial value of $sp.
 */
STACK_START = RAM_HIGH_ADDR;
STACK_SIZE = 0xfe00;
STACK_STOP = STACK_START - STACK_SIZE;

/* The heap grows UP, but it's easier to define it relative to the BOTTOM of the
 * stack, which is the TOP of the heap.
 */
HEAP_STOP = STACK_STOP;
HEAP_SIZE = 0x00030200;
HEAP_START = HEAP_STOP - HEAP_SIZE;

/* With the above information, we can now inform LD of our memory layout. */

MEMORY
{
  VECTORS(rx): ORIGIN = 0x00000000, LENGTH = VECTOR_TABLE_SIZE
  FLASH_PROTECTION(rx): ORIGIN = FLASH_PROTECTION_LOW_ADDR, LENGTH = FLASH_PROECTION_SIZE
  FLASH(rx): ORIGIN = FLASH_LOW_ADDR, LENGTH = FLASH_SIZE
  RAM_STACK(rwx): ORIGIN = STACK_STOP, LENGTH = STACK_SIZE
  RAM_HEAP(rwx): ORIGIN = HEAP_START, LENGTH = HEAP_SIZE 
}

/* Linker script to place sections and symbol values. Should be used together
 * with other linker script that defines memory regions FLASH and RAM.
 * It references following symbols, which must be defined in code:
 * _reset_init : Entry of reset handler
 *
 * It defines following symbols, which code can use without definition:
 * __exidx_start
 * __exidx_end
 * __etext
 * __data_start__
 * __preinit_array_start
 * __preinit_array_end
 * __data_end__
 * __bss_start__
 * __bss_end__
 * __end__
 * end
 * __HeapLimit
 * __StackLimit
 * __StackTop
 * __stack
 */
ENTRY(Reset_Handler)

SECTIONS
{
    /* asm-defined .section .vector_table from core files*/
    .isr_vector :
    {
        __vector_table = .;
        KEEP(*(.vector_table))
         . = ALIGN(4);
    } > VECTORS

    /* Flash protection bits (kinetis-specific, defined in the core files)
     * These also get their own .section .kinetis_flash_config_field
     */
    .flash_protect :
    {
        KEEP(*(.kinetis_flash_config_field))
         . = ALIGN(4);
    } > FLASH_PROTECTION

    /* Program code (and literal pools, .rodata) */
    .text :
    {
        *(.text*)

        *(.rodata*)

        /*
         * This is for debugging on embedded, and stack unwinding with an OS.
         * It is also used to implement exceptions in C++.
         */
        /*
         *KEEP(*(.eh_frame*))
         */
        
        /* Note that we have no .glue_* sections because M4 is Thumb only. */
    } > FLASH

    /* This is just reserving stack space and defining related symbols. */
    .stack (NOLOAD):
    {
        __StackLimit = .;
        *(.stack*);
        . += (ORIGIN(RAM_STACK) + LENGTH(RAM_STACK) - .);
        __StackTop = .;
    } > RAM_STACK

    PROVIDE(__stack = __StackTop);

    .data :
    {
        PROVIDE( __etext = LOADADDR(.data) );

        __data_start__ = .;
        *(.data*)

        /* These are all C-runtime related */
        . = ALIGN(4);
        /* preinit data*/
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);

        . = ALIGN(4);
        /* init data */
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE_HIDDEN (__init_array_end = .);

        . = ALIGN(4);
        /* finit data */
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE_HIDDEN (__fini_array_end = .);

        /* All data end */
        . = ALIGN(32);
        __data_end__ = .;

    } >RAM_HEAP AT>FLASH
    /* Strange syntax which makes the relocation address for this section the
     * heap, but stores it in the flash.  The C runtime copies this initialized
     * data over to RAM on startup, apparently.
     */

    /*
     * Uninitialized variables can go wherever in the heap (but are contiguous!)
     */
    .uninitialized (NOLOAD):
    {
        . = ALIGN(32);
        __uninitialized_start = .;
        *(.uninitialized)
        KEEP(*(.keep.uninitialized))
        . = ALIGN(32);
        __uninitialized_end = .;
    } > RAM_HEAP

    /*
     * Zero-initialized variables go in the heap (and are contiguous)
     */
    .bss (NOLOAD):
    {
        __bss_start__ = .;
        *(.bss*)
        *(COMMON)
        __bss_end__ = .;
    } > RAM_HEAP

    /*
     * Here we insert all other variables to the heap and define some symbols
     * related to it.
     */
    .heap (NOLOAD):
    {
        __end__ = .;
        end = __end__;
        *(.heap*);
        . += (ORIGIN(RAM_HEAP) + LENGTH(RAM_HEAP) - .);
        __HeapLimit = .;
    } > RAM_HEAP
    PROVIDE(__heap_size = SIZEOF(.heap));
    PROVIDE(_heap_start = end );
    . = . + __heap_size;
    PROVIDE(_heap_end = .);
}
