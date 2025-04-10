cmake_minimum_required(VERSION 3.24)

project(primordial ASM)
enable_language(ASM)

if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
        include(CTest)
endif()

set(CMAKE_ASM_COMPILER riscv64-unknown-elf-gcc)
set(
        CMAKE_ASM_FLAGS
        "-O0 -ggdb3 -Wl,-T${CMAKE_SOURCE_DIR}/linker.ld -Wa,--fatal-warnings -mcmodel=medlow -nostdlib -static"
)
set(LINKER_SCRIPT linker.ld)

add_library(
        entrypoint STATIC
        lib/entrypoint/entrypoint.S
)
target_include_directories(entrypoint PUBLIC inc)

add_library(
        millicode STATIC
        lib/millicode/frame_0.S
        lib/millicode/frame_1.S
        lib/millicode/frame_2.S
        lib/millicode/frame_3.S
        lib/millicode/frame_4.S
        lib/millicode/frame_5.S
        lib/millicode/frame_6.S
        lib/millicode/frame_7.S
        lib/millicode/frame_8.S
        lib/millicode/frame_9.S
        lib/millicode/frame_10.S
        lib/millicode/frame_11.S
)

add_library(
        p0 STATIC
        lib/p0/ascii/ascii.S
        lib/p0/forever/allocate.S
        lib/p0/format/unsigned.S
        lib/p0/io/write.S
        lib/p0/mem/clone.S
        lib/p0/mem/copy.S
        lib/p0/mem/eq.S
        lib/p0/mem/index.S
        lib/p0/mem/shortlex.S
        lib/p0/os/exit.S
        lib/p0/strintern/strintern.S
)
target_include_directories(p0 PUBLIC inc)
target_link_libraries(p0 PUBLIC millicode)

add_library(
        testing STATIC
        lib/testing/testing.S
)
target_include_directories(testing PUBLIC inc)

add_executable(
        true
        cmd/true/true.S
)
target_include_directories(true PUBLIC inc)
target_link_libraries(true PUBLIC p0 entrypoint millicode)

add_executable(
        unsigned_test
        lib/p0/format/unsigned_test.S
)
set_target_properties(
        unsigned_test PROPERTIES
        LINK_DEPENDS ${CMAKE_SOURCE_DIR}/linker.ld
)
target_link_libraries(unsigned_test PUBLIC p0 entrypoint testing millicode)
add_test(unsigned_test unsigned_test)
