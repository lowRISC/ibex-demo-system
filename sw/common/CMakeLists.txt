add_library(common OBJECT demo_system.c uart.c timer.c gpio.c pwm.c spi.c crt0.S)
target_include_directories(common INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}")
