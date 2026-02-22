/*
 * IDTR Structure (32-bit Protected Mode)
 *
 *  Bits   Field   Size
 *  -----------------------
 *  0–15   Limit   2 bytes
 * 16–47   Base    4 bytes
 *
 *  Total size: 6 bytes
 */

#include <stdint.h>

#define IDT_BASE        0x0000BE80
#define IDT_ENTRIES     32 
#define IDT_DESC_SIZE   8

struct __attribute__((packed)) idtr 
{
    uint16_t limit; 
    uint32_t base; 
};

void idt_init(void)
{
    struct idtr idt = {.limit = (IDT_ENTRIES * IDT_DESC_SIZE) - 1, .base = IDT_BASE};

    __asm__ __volatile__ 
    (
        "lidt %0"
        :
        : "m"(idt)
        : "memory"
    );
}