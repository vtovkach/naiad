#include <stdint.h>

#include "include/drivers/vga/vga_num.h"
#include "include/drivers/vga/vga_text.h"

#define GDT_BASE 0x0000BE00

int kmain()
{

    vga_print("Kernel loaded successfully!\n");
    vga_print_uint32_b10(2026);
    vga_putchar('\n');
    vga_print_uint64_b16(2026);
    
    return 0;
}