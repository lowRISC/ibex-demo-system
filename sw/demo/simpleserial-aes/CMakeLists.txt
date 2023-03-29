add_definitions(-DTINYAES128C -DSS_VER=1 -DHAL_TYPE=HAL_ibex)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/newae/crypto)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/newae/hal)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/newae/simpleserial)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/newae/crypto/tiny-AES128-C)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../common)

add_library(simpleserial
${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/newae/simpleserial/simpleserial.c
${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/newae/hal/ibex/ibex_hal.c
)

add_library(tiny-AES128
${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/newae/crypto/aes-independant.c
${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/newae/crypto/tiny-AES128-C/aes.c
)

add_prog(simpleserial-aes ${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/newae/simpleserial-aes/simpleserial-aes.c)

target_link_libraries(simpleserial-aes simpleserial tiny-AES128)

