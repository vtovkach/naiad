#include <stdint.h>

#define VGA_WIDTH   80
#define VGA_HEIGHT  25 
#define VGA_MEMORY  0xB8000

// I will see later if I want to make cursor data static and expose interface to other translation units  
int cursor_row = 0;
int cursor_column = 0; 

static uint16_t *vga = (uint16_t *) VGA_MEMORY;

void putchar(char ch)
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

void print(const char* str)
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
