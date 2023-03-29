add_definitions(-DSS_VER=1 -DHAL_TYPE=HAL_ibex)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/newae/crypto)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/newae/hal)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/newae/simpleserial)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../common)


add_prog(basic-passwdcheck ${CMAKE_CURRENT_SOURCE_DIR}/../../../vendor/newae/basic-passwdcheck/basic-passwdcheck.c)

target_link_libraries(basic-passwdcheck simpleserial)

