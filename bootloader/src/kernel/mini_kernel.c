#include <stdint.h>

#define VGA_MEMORY 0xB8000
#define VGA_WIDTH  80
#define VGA_HEIGHT 25

struct e820_entry
{

    uint64_t base;
    uint64_t length; 
    uint32_t type; 
    uint32_t acpi;

} __attribute__((packed));

extern struct e820_entry *e820_ptr;

extern uint32_t e820_count;

static uint16_t* const vga = (uint16_t*) VGA_MEMORY;

// Cursor Row is set to 1 due to Protected Mode message from bootloader stage 2  
static uint8_t cursor_row = 1; 
static uint8_t cursor_column = 0;

static void clear_screen(void)
{
    int screen_resolution = VGA_HEIGHT * VGA_WIDTH;

    uint16_t blank = (0x0F << 8) | ' ';

    for(int i = 0; i < screen_resolution; i++)
    {
        vga[i] = blank;
    }
}

static void putchar(char ch)
{
    if(ch == '\0')
    {
        return;
    }
    else if(ch == '\n')
    {
        cursor_row++; 
        cursor_column = 0;
    }
    else
    {
        uint16_t char_to_print = ((uint16_t)0x0F << 8) | (uint8_t)ch;
        uint16_t pos = (uint16_t)(cursor_row * VGA_WIDTH + cursor_column);
        vga[pos] = char_to_print;
        cursor_column++; 
    }

    // Check column cursor bound
    if(cursor_column >= VGA_WIDTH)
    {
        cursor_row++; 
        cursor_column = 0;
    }

    // Check row cursor bound 
    if(cursor_row >= VGA_HEIGHT)
    {
        //clear_screen();
        cursor_row = 0;
    }

    return; 
}

static void print(const char* str)
{
    while (*str)
    {
        char c = *str++;

        if (c == '\n')
        {
            cursor_column = 0;
            cursor_row++;
        }
        else
        {
            uint16_t cur_pos = (uint16_t)(VGA_WIDTH * cursor_row + cursor_column);
            vga[cur_pos] = ((uint16_t)0x0F << 8) | (uint8_t)c;

            cursor_column++;
            if (cursor_column >= VGA_WIDTH)
            {
                cursor_column = 0;
                cursor_row++;
            }
        }

        if (cursor_row >= VGA_HEIGHT)
        {
            // temporary behavior (no scroll yet): just wrap to top for now, will add scroll later 
            cursor_row = 0;
        }
    }

    // Will probably add later 
    // Sync the blinking hardware cursor with your cursor 
}

static void print_uint32_b10(uint32_t num)
{
    if(num < 10)
    {   
        char ch = '0' + num % 10;
        putchar(ch);

        return; 
    }

    print_uint32_b10(num / 10);
    char ch = '0' + num % 10; 
    putchar(ch);

    return;
}

static void print_uint64_b16(uint64_t x)
{
    static const char* d = "0123456789ABCDEF";

    print("0x");

    for (int i = 15; i >= 0; --i)
    {
        uint8_t nib = (x >> (i * 4)) & 0xF;
        putchar(d[nib]);
    }
}

static inline void outb(uint16_t port, uint8_t val) 
{
    __asm__ volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) 
{
    uint8_t ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

void vga_disable_cursor(void)
{
    outb(0x3D4, 0x0A);                  // cursor start register
    outb(0x3D5, inb(0x3D5) | 0x20);     // set bit 5 -> disable
}

void display_e820()
{   
    print("\nE820 Memory Layout Information\n");
    print("===============================================\n");
    print(" Address Range                            Type\n");
    print("===============================================\n");

    for(int i = 0; i < e820_count; i++)
    {
        struct e820_entry cur_entry = e820_ptr[i];

        if(cur_entry.type == 0)
            break; 

        print_uint64_b16(cur_entry.base);
        print("--");
        print_uint64_b16(cur_entry.base + cur_entry.length);
        print("     ");
        print_uint32_b10(cur_entry.type);
        putchar('\n');
    }
}

int kernel_main(void)
{
    vga_disable_cursor();
    print("Kernel Loaded Successfully\n");

    print("Number of e820 entries: ");
    print_uint32_b10(e820_count);
    putchar('\n');
    display_e820();


    // Halt CPU at the end 
    while (1)
    {
        __asm__ volatile ("hlt");
    }

    return 0;
}