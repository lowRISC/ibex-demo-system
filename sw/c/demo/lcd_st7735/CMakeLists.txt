# This is the same sets of compilation flags used in ibex CoreMark core_portme.mak.
set(CMAKE_C_FLAGS "-mtune=sifive-3-series -O3 -falign-functions=16 -funroll-all-loops -finline-functions -falign-jumps=4 -mstrict-align")

add_library(lcd_st7735_lib
${CMAKE_CURRENT_SOURCE_DIR}/../../../../vendor/display_drivers/core/lcd_base.c
${CMAKE_CURRENT_SOURCE_DIR}/../../../../vendor/display_drivers/core/lucida_console_10pt.c
${CMAKE_CURRENT_SOURCE_DIR}/../../../../vendor/display_drivers/core/lucida_console_12pt.c
${CMAKE_CURRENT_SOURCE_DIR}/../../../../vendor/display_drivers/core/m3x6_16pt.c
${CMAKE_CURRENT_SOURCE_DIR}/../../../../vendor/display_drivers/st7735/lcd_st7735.c
)

add_library(coremark
${CMAKE_CURRENT_SOURCE_DIR}/../../../../vendor/lowrisc_ibex/vendor/eembc_coremark/core_list_join.c
${CMAKE_CURRENT_SOURCE_DIR}/../../../../vendor/lowrisc_ibex/vendor/eembc_coremark/core_main.c
${CMAKE_CURRENT_SOURCE_DIR}/../../../../vendor/lowrisc_ibex/vendor/eembc_coremark/core_matrix.c
${CMAKE_CURRENT_SOURCE_DIR}/../../../../vendor/lowrisc_ibex/vendor/eembc_coremark/core_state.c
${CMAKE_CURRENT_SOURCE_DIR}/../../../../vendor/lowrisc_ibex/vendor/eembc_coremark/core_util.c
${CMAKE_CURRENT_SOURCE_DIR}/../../../../vendor/lowrisc_ibex/vendor/eembc_coremark/barebones/cvt.c
coremark/core_portme.c
coremark/ee_printf.c
)

# core_main defines a `main` function, rename it to `coremark_main` instead.
set_source_files_properties(
  ${CMAKE_CURRENT_SOURCE_DIR}/../../../../vendor/lowrisc_ibex/vendor/eembc_coremark/core_main.c
  PROPERTIES COMPILE_FLAGS -Dmain=coremark_main
)

target_include_directories(coremark PRIVATE
${CMAKE_CURRENT_SOURCE_DIR}/../../../../vendor/lowrisc_ibex/vendor/eembc_coremark
${CMAKE_CURRENT_SOURCE_DIR}/../../../../vendor/lowrisc_ibex/examples/sw/benchmarks/coremark/ibex
)

target_link_libraries(coremark common)

# add_executable(lcd_st7735 main.c)
add_executable(lcd_st7735 main.c lcd.c fractal_fixed.c fractal_float.c fractal_palette.c fbcon.c)

# pull in core dependencies and additional i2c hardware support
target_link_libraries(lcd_st7735 common lcd_st7735_lib coremark)

target_include_directories(lcd_st7735 PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../../../vendor/display_drivers)
