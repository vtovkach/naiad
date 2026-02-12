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

static void put_char(char ch)
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
        put_char(ch);

        return; 
    }

    print_uint32_b10(num / 10);
    char ch = '0' + num % 10; 
    put_char(ch);

    return;
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

}

int kernel_main(void)
{
    vga_disable_cursor();
    print("Kernel Loaded Successfully\n");

    print("\n");
    print("E820 Memory Layout Information\n");
    print("==============================\n");
    display_e820();


    // Halt CPU at the end 
    while (1)
    {
        __asm__ volatile ("hlt");
    }

    return 0;
}