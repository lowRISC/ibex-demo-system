cmake_minimum_required(VERSION 3.12)

if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/gcc_toolchain.cmake")
endif()

project(demo_system_sw LANGUAGES C ASM)

if(CMAKE_BUILD_TYPE STREQUAL "")
  get_property(helpstring CACHE CMAKE_BUILD_TYPE PROPERTY HELPSTRING)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "${helpstring}" FORCE)
endif()

option(SIM_CTRL_OUTPUT
       "Send string output to simulator control rather than UART")

if(SIM_CTRL_OUTPUT)
  add_compile_definitions(SIM_CTRL_OUTPUT)
endif()

add_subdirectory(common)
add_subdirectory(demo)
add_subdirectory(blank)
