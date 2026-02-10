

int kernel_main(void)
{
    while(1) { __asm__ volatile ("hlt"); };

    return 0;
}