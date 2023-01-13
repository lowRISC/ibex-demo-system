
add_library(lcd_st7735_lib
${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/display_drivers/core/lcd_base.c
${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/display_drivers/core/lucida_console_10pt.c
${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/display_drivers/core/lucida_console_12pt.c
${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/display_drivers/st7735/lcd_st7735.c
)

string(APPEND CMAKE_C_FLAGS " -O2")

# add_executable(lcd_st7735 main.c)
add_prog(lcd_st7735 "main.c;lcd.c;fractal_fixed.c;fractal_float.c;fractal_palette.c")

# pull in core dependencies and additional i2c hardware support
target_link_libraries(lcd_st7735 lcd_st7735_lib)

target_include_directories(lcd_st7735 PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/display_drivers)
