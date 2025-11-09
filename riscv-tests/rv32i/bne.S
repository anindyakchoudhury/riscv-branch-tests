################################################################################
//
//  Author : Anindya Kishore Choudhury
//  Email : anindyakchoudhury@gmail.com
//
//  This is a test for the RISC-V 'bne' (Branch if Not Equal) instruction.
//  It executes a series of 'bne' operations with various register values
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

// BNE_TAKEN: Macro to test BNE when branch SHOULD be taken
// Sets a marker value (0xAA) before branch, changes to success value (0x55)
// after branch. If branch fails, marker remains 0xAA.
// 1: is a label (marks a location in code)
// 1f means "forward to the next 1: label"
#define BNE_TAKEN(RS1, RS2, MARKER_REG)         \
        li      MARKER_REG,     0xAA;           \
        bne     RS1,    RS2,    1f;             \
        j       2f;                             \
1:      li      MARKER_REG,     0x55;           \
2:      STORE_X31(MARKER_REG);

// BNE_NOT_TAKEN: Macro to test BNE when branch SHOULD NOT be taken
// Sets a marker value (0xBB) before branch, changes to success value (0x66)
// after correctly NOT taking the branch. If branch incorrectly taken, marker remains 0xBB.
#define BNE_NOT_TAKEN(RS1, RS2, MARKER_REG)     \
        li      MARKER_REG,     0xBB;           \
        bne     RS1,    RS2,    1f;             \
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

        // Test cases for the 'bne' instruction.
        // The results are stored sequentially in memory.
        // Expected values: 0x55 = branch correctly taken
        //                  0x66 = branch correctly not taken

        //-----------------------------------------------------------------------
        // Category 1: Basic Inequality Tests
        //-----------------------------------------------------------------------

        // Test 1: Different positive values (should branch)
        li      x1,     10
        li      x2,     20
        BNE_TAKEN(x1, x2, x3)

        // Test 2: Different negative values (should branch)
        li      x1,     -10
        li      x2,     -20
        BNE_TAKEN(x1, x2, x3)

        // Test 3: Positive vs Negative (should branch)
        li      x1,     10
        li      x2,     -10
        BNE_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 2: Basic Equality Tests
        //-----------------------------------------------------------------------

        // Test 4: Zero == Zero (should NOT branch)
        li      x1,     0
        li      x2,     0
        BNE_NOT_TAKEN(x1, x2, x3)

        // Test 5: Positive == Positive (should NOT branch)
        li      x1,     100
        li      x2,     100
        BNE_NOT_TAKEN(x1, x2, x3)

        // Test 6: Negative == Negative (should NOT branch)
        li      x1,     -50
        li      x2,     -50
        BNE_NOT_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 3: Boundary Values
        //-----------------------------------------------------------------------

        // Test 7: Max vs Min (should branch)
        // This is the LARGEST possible difference in 64-bit signed numbers
        li      x1,     0x7FFFFFFFFFFFFFFF
        li      x2,     0x8000000000000000
        BNE_TAKEN(x1, x2, x3)

        // Test 8: Max positive value (should NOT branch)
        li      x1,     0x7FFFFFFFFFFFFFFF
        li      x2,     0x7FFFFFFFFFFFFFFF
        BNE_NOT_TAKEN(x1, x2, x3)

        // Test 9: Max negative value (should NOT branch)
        li      x1,     0x8000000000000000
        li      x2,     0x8000000000000000
        BNE_NOT_TAKEN(x1, x2, x3)

        // Test 10: Max positive vs slightly different (should branch)
        li      x1,     0x7FFFFFFFFFFFFFFF
        li      x2,     0x7FFFFFFFFFFFFFFE
        BNE_TAKEN(x1, x2, x3)

        // Test 11: Min negative vs slightly different (should branch)
        li      x1,     0x8000000000000000
        li      x2,     0x8000000000000001
        BNE_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 4: Same Register Comparison
        //-----------------------------------------------------------------------

        // Test 12: x0 == x0 (always equal, should NOT branch)
        BNE_NOT_TAKEN(x0, x0, x3)

        // Test 13: Same non-zero register (should NOT branch)
        li      x5,     12345
        BNE_NOT_TAKEN(x5, x5, x3)

        //-----------------------------------------------------------------------
        // Category 5: Zero vs Non-Zero
        //-----------------------------------------------------------------------

        // Test 14: Zero vs Positive (should branch)
        li      x1,     0
        li      x2,     1
        BNE_TAKEN(x1, x2, x3)

        // Test 15: Zero vs Negative (should branch)
        li      x1,     0
        li      x2,     -1
        BNE_TAKEN(x1, x2, x3)

        // Test 16: Positive vs Zero (should branch)
        li      x1,     1
        li      x2,     0
        BNE_TAKEN(x1, x2, x3)

        // Test 17: Negative vs Zero (should branch)
        li      x1,     -1
        li      x2,     0
        BNE_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 6: Register Combinations
        //-----------------------------------------------------------------------

        // Test 18-23: Different register pairs with unequal values
        li      x1,     42
        li      x2,     43
        BNE_TAKEN(x1, x2, x3)

        li      x4,     42
        li      x5,     41
        BNE_TAKEN(x4, x5, x3)

        li      x6,     -42
        li      x7,     42
        BNE_TAKEN(x6, x7, x3)

        li      x8,     100
        li      x9,     101
        BNE_TAKEN(x8, x9, x3)

        li      x10,    -100
        li      x11,    -101
        BNE_TAKEN(x10, x11, x3)

        li      x12,    1000
        li      x13,    2000
        BNE_TAKEN(x12, x13, x3)

        //-----------------------------------------------------------------------
        // Category 7: Forward Branch Distance Tests
        //-----------------------------------------------------------------------

        // Test 24: Short forward branch (taken)


        // Test 25: Medium forward branch (taken)


        //-----------------------------------------------------------------------
        // Category 8: Backward Branch Tests
        //-----------------------------------------------------------------------

        // Test 26: Backward branch (taken)

        //-----------------------------------------------------------------------
        // Category 9: Dependency Testing
        //-----------------------------------------------------------------------

        // Test 27: Result of previous instruction used in BNE
        li      x1,     50
        addi    x2,     x1,     10
        BNE_TAKEN(x1, x2, x3)

        // Test 28: Back-to-back dependencies
        li      x1,     30
        addi    x2,     x1,     0
        addi    x1,     x2,     1
        BNE_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 10: Small Differences
        //-----------------------------------------------------------------------

        // Test 29: Difference of 1 (positive)
        li      x1,     100
        li      x2,     101
        BNE_TAKEN(x1, x2, x3)

        // Test 30: Difference of 1 (negative)
        li      x1,     -100
        li      x2,     -101
        BNE_TAKEN(x1, x2, x3)

        // Test 31: Difference of -1 (positive)
        li      x1,     101
        li      x2,     100
        BNE_TAKEN(x1, x2, x3)

        // Test 32: Difference of -1 (negative)
        li      x1,     -101
        li      x2,     -100
        BNE_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 11: Random Value Tests
        //-----------------------------------------------------------------------

        // Test 33-52: Random inequality tests (20 tests)
        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BNE_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BNE_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BNE_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BNE_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BNE_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BNE_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BNE_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BNE_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BNE_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BNE_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BNE_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BNE_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BNE_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BNE_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BNE_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BNE_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BNE_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BNE_NOT_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        BNE_TAKEN(x1, x2, x3)

        li      x1,     RANDIMM
        mv      x2,     x1
        BNE_NOT_TAKEN(x1, x2, x3)

        // Exit the test with a success code (0).
        EXIT(0)

################################################################################
// Macro Undefine : Undefine the local macro to prevent accidental use later.
################################################################################

#undef BNE_TAKEN
#undef BNE_NOT_TAKEN
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
//     BNE instructions
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
        .zero __riscv_xlen / 8 * 49
TEST_DATA_END:

// __riscv_xlen / 8 * 52 (three tests are not written as of now)
//  = 64 / 8 * 52
//  = 8 * 52
//  = 416 bytes