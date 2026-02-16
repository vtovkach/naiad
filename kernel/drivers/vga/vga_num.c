#include <stdint.h>

#include "../../include/drivers/vga/vga_text.h"

void print_uint32_b10(uint32_t x)
{
    if(x < 10)
    {   
        char ch = '0' + x % 10;
        putchar(ch);

        return; 
    }

    print_uint32_b10(x / 10);
    char ch = '0' + x % 10; 
    putchar(ch);

    return;
}


void print_uint64_b16(uint64_t x)
{
    static const char* d = "0123456789ABCDEF";

    print("0x");

    for (int i = 15; i >= 0; --i)
    {
        uint8_t nib = (x >> (i * 4)) & 0xF;
        putchar(d[nib]);
    }
}
