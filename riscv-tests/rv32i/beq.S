################################################################################
//
//  Author : Anindya Kishore Choudhury
//  Email : anindyakchoudhury@gmail.com
//
//  This is a test for the RISC-V 'beq' (Branch if Equal) instruction.
//  It executes a series of 'beq' operations with various register values
//  and branch conditions, storing branch taken/not-taken results in a
//  dedicated data section.
//  The test passes if the program completes successfully. A verification script
//  would typically check the stored results against expected values.
//
//  Copyright (c) 2025 Tecknoz
//  Licensed under the MIT License
//  See LICENSE file in the project root for full license information
//
################################################################################

// This header file provides macros and definitions for bare-metal RISC-V
// assembly tests, primarily for use in simulation environments like Spike.
#include "ss_riscv_asm.S"

################################################################################
// Macro Define : Local macro definition
################################################################################

// STORE_X31: A macro to store the value of a register to the memory location
// pointed to by x31, and then increment the x31 pointer. This is used to
// save the result of each test case. It's conditionally compiled for RV32
// (using 'sw') and RV64 (using 'sd').
#if __riscv_xlen == 64
#define STORE_X31(REG)                  \
        sd      REG,    0(x31);         \
        addi    x31,    x31,    8;
#else
#define STORE_X31(REG)                  \
        sw      REG,    0(x31);         \
        addi    x31,    x31,    4;
#endif

// BEQ_TAKEN: Macro to test BEQ when branch SHOULD be taken
// Sets a marker value (0xAA) before branch, changes to success value (0x55)
// after branch. If branch fails, marker remains 0xAA.
// 1: is a label (marks a location in code)
// 1f means "forward to the next 1: label"
#define BEQ_TAKEN(RS1, RS2, MARKER_REG)         \
        li      MARKER_REG,     0xAA;           \
        beq     RS1,    RS2,    1f;             \
        j       2f;                             \
1:      li      MARKER_REG,     0x55;           \
2:      STORE_X31(MARKER_REG);

// BEQ_NOT_TAKEN: Macro to test BEQ when branch SHOULD NOT be taken
// Sets a marker value (0xBB) before branch, changes to success value (0x66)
// after correctly NOT taking the branch. If branch incorrectly taken, marker remains 0xBB.
#define BEQ_NOT_TAKEN(RS1, RS2, MARKER_REG)     \
        li      MARKER_REG,     0xBB;           \
        beq     RS1,    RS2,    1f;             \
        li      MARKER_REG,     0x66;           \
        j       2f;                             \
1:      nop;                                    \
2:      STORE_X31(MARKER_REG);

################################################################################
// Program Entry Point
################################################################################

_start:
        // Initialize x31 (t6) to be the pointer to the results data area.
        la      x31,    TEST_DATA_BEGIN

        // Test cases for the 'beq' instruction.
        // The results are stored sequentially in memory.
        // Expected values: 0x55 = branch correctly taken
        //                  0x66 = branch correctly not taken

        //-----------------------------------------------------------------------
        // Category 1: Basic Equality Tests
        //-----------------------------------------------------------------------

        // Test 1: Zero == Zero (should branch)
        li      x1,     0
        li      x2,     0
        BEQ_TAKEN(x1, x2, x3)

        // Test 2: Positive == Positive (should branch)
        li      x1,     100
        li      x2,     100
        BEQ_TAKEN(x1, x2, x3)

        // Test 3: Negative == Negative (should branch)
        li      x1,     -50
        li      x2,     -50
        BEQ_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 2: Basic Inequality Tests
        //-----------------------------------------------------------------------

        // Test 4: Different positive values (should NOT branch)
        li      x1,     10
        li      x2,     20
        BEQ_NOT_TAKEN(x1, x2, x3)

        // Test 5: Different negative values (should NOT branch)
        li      x1,     -10
        li      x2,     -20
        BEQ_NOT_TAKEN(x1, x2, x3)

        // Test 6: Positive vs Negative (should NOT branch)
        li      x1,     10
        li      x2,     -10
        BEQ_NOT_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 3: Boundary Values
        //-----------------------------------------------------------------------

        // Test 7: Max positive value (should branch)
        li      x1,     0x7FFFFFFFFFFFFFFF
        li      x2,     0x7FFFFFFFFFFFFFFF
        BEQ_TAKEN(x1, x2, x3)

        // Test 8: Max negative value (should branch)
        li      x1,     0x8000000000000000
        li      x2,     0x8000000000000000
        BEQ_TAKEN(x1, x2, x3)

        // Test 9: Max vs Min (should NOT branch)
        // This is the LARGEST possible difference in 64-bit signed numbers
        li      x1,     0x7FFFFFFFFFFFFFFF
        li      x2,     0x8000000000000000
        BEQ_NOT_TAKEN(x1, x2, x3)
        // For 64-bit signed integers (two's complement):
        //
        // Maximum positive: 0x7FFFFFFFFFFFFFFF = +9,223,372,036,854,775,807
        // Minimum negative: 0x8000000000000000 = -9,223,372,036,854,775,808
        //
        //
        // ### Binary Representation
        //
        // Maximum Positive (0x7FFFFFFFFFFFFFFF):
        // Bit 63: 0 (sign bit = positive)
        // Bits 62-0: 1111111111...111 (all ones)
        // Binary: 0111 1111 1111 1111 ... 1111 1111 1111 1111
        //
        // Minimum Negative (0x8000000000000000):
        // Bit 63: 1 (sign bit = negative)
        // Bits 62-0: 0000000000...000 (all zeros)
        // Binary: 1000 0000 0000 0000 ... 0000 0000 0000 0000

        //-----------------------------------------------------------------------
        // Category 4: Same Register Comparison
        //-----------------------------------------------------------------------

        // Test 10: x0 == x0 (always equal, should branch)
        BEQ_TAKEN(x0, x0, x3)

        // Test 11: Same non-zero register (should branch)
        li      x5,     12345
        BEQ_TAKEN(x5, x5, x3)

        //-----------------------------------------------------------------------
        // Category 5: Register Combinations
        //-----------------------------------------------------------------------

        // Test 12-17: Different register pairs with equal values
        li      x1,     42
        li      x2,     42
        BEQ_TAKEN(x1, x2, x3)

        li      x4,     42
        li      x5,     42
        BEQ_TAKEN(x4, x5, x3)

        li      x6,     42
        li      x7,     42
        BEQ_TAKEN(x6, x7, x3)

        li      x8,     42
        li      x9,     42
        BEQ_TAKEN(x8, x9, x3)

        li      x10,    42
        li      x11,    42
        BEQ_TAKEN(x10, x11, x3)

        li      x12,    42
        li      x13,    42
        BEQ_TAKEN(x12, x13, x3)

        //-----------------------------------------------------------------------
        // Category 6: Forward Branch Distance Tests
        //-----------------------------------------------------------------------

        // Test 18: Short forward branch (taken)


        // Test 19: Medium forward branch (taken)


        //-----------------------------------------------------------------------
        // Category 7: Backward Branch Tests
        //-----------------------------------------------------------------------

        // Test 20: Backward branch (taken)

        //-----------------------------------------------------------------------
        // Category 8: Dependency Testing
        //-----------------------------------------------------------------------

        // Test 21: Result of previous instruction used in BEQ
        li      x1,     50
        addi    x2,     x1,     0
        BEQ_TAKEN(x1, x2, x3)

        // Test 22: Back-to-back dependencies
        li      x1,     30
        addi    x2,     x1,     0
        addi    x1,     x2,     0
        BEQ_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 9: Random Value Tests
        //-----------------------------------------------------------------------

        // Test 23-52: Random equality tests (30 tests)
        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BEQ_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BEQ_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BEQ_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BEQ_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BEQ_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BEQ_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BEQ_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BEQ_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BEQ_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BEQ_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BEQ_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BEQ_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BEQ_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BEQ_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BEQ_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BEQ_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BEQ_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BEQ_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BEQ_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BEQ_TAKEN(x1, x2, x3)

        // Exit the test with a success code (0).
        EXIT(0)

################################################################################
// Macro Undefine : Undefine the local macro to prevent accidental use later.
################################################################################

#undef BEQ_TAKEN
#undef BEQ_NOT_TAKEN
#undef STORE_X31

################################################################################
// Data section for storing test results.
################################################################################

// Data section for storing test results.
.section .data
// Switches from code section (.text) to data section
// Everything after this goes into data memory (RAM)
// Writable memory region

// Memory layout:
//
// .text section (code):
//     _start:
//     ...
//     BEQ instructions
//     ...
//
// .data section (data):
//     TEST_DATA_BEGIN:
//     ...
//     Space for results
//     ...



.align 3
// Aligns next address to 2^3 = 8-byte boundary
// Ensures address is a multiple of 8

// Reserve space for 52 test results. The size of each result depends on
// the architecture's word length (__riscv_xlen).
TEST_DATA_BEGIN:
        .zero __riscv_xlen / 8 * 39
TEST_DATA_END:

// __riscv_xlen / 8 * 42
//  = 64 / 8 * 42
//  = 8 * 42
//  = 336 bytes