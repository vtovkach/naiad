ENTRY(_start)

SECTIONS
{
    . = 0x00009600
    .text   : { *(.text*) }
    .rodata : { *(.rodata*) }
    .data   : { *(.data*) }

    .bss : 
    {
        *(COMMON)
        *(.bss*)
    }
}