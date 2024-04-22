set(LINKER_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/../common/link.ld")
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_C_COMPILER riscv32-unknown-elf-gcc)
set(CMAKE_OBJCOPY riscv32-unknown-elf-objcopy)
set(CMAKE_C_FLAGS_INIT
    "-march=rv32imc -mabi=ilp32 -mcmodel=medany -Wall -fvisibility=hidden -ffreestanding")
set(CMAKE_ASM_FLAGS_INIT "-march=rv32imc")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-nostartfiles -T \"${LINKER_SCRIPT}\"")
