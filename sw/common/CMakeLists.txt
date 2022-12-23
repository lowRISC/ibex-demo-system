add_library(common OBJECT demo_system.c uart.c timer.c gpio.c pwm.c spi.c crt0.S)
set_property(SOURCE crt0.S PROPERTY LANGUAGE C)
target_include_directories(common PUBLIC "${CMAKE_CURRENT_LIST_DIR}")
