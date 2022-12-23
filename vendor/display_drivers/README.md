# display_drivers
This driver is designed to be fairly simple to port and use in any platform.
It is completely hardware independent, the access to the necessary hardware is provided by callbacks functions that should be implemented by the application.

Example:
```C
static uint32_t spi_write(void *handle, uint8_t *data, size_t len){
    //Code here.
    return len;
}

static uint32_t gpio_write(void *handle, bool cs, bool dc){
    //Code here.
    return 0;
}

static void sleep_ms(uint32_t ms){
    //Code here.
    return 0;
}

void main(void){
    St7735Context ctx;
    LCD_Interface interface = {
        .handle = NULL,
        .spi_write = spi_write,
        .gpio_write = gpio_write,
        .timer_delay = sleep_ms,
    };

    lcd_st7735_init(&ctx, &interface);
    lcd_st7735_fill_rectangle(&ctx, (LCD_rectangle){.origin = {.x = 0, .y = 0},
        .end = {.x = 160, .y = 128}}, 0x00FF00);
}

```