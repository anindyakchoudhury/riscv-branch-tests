################################################################################
//
//  Author : Anindya Kishore Choudhury
//  Email : anindyakchoudhury@gmail.com
//
//  This is a test for the RISC-V 'blt' (Branch if Less Than) instruction.
//  It executes a series of 'blt' operations with various register values
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

// BLT_TAKEN: Macro to test BLT when branch SHOULD be taken
// Sets a marker value (0xAA) before branch, changes to success value (0x55)
// after branch. If branch fails, marker remains 0xAA.
// 1: is a label (marks a location in code)
// 1f means "forward to the next 1: label"
#define BLT_TAKEN(RS1, RS2, MARKER_REG)         \
        li      MARKER_REG,     0xAA;           \
        blt     RS1,    RS2,    1f;             \
        j       2f;                             \
1:      li      MARKER_REG,     0x55;           \
2:      STORE_X31(MARKER_REG);

// BLT_NOT_TAKEN: Macro to test BLT when branch SHOULD NOT be taken
// Sets a marker value (0xBB) before branch, changes to success value (0x66)
// after correctly NOT taking the branch. If branch incorrectly taken, marker remains 0xBB.
#define BLT_NOT_TAKEN(RS1, RS2, MARKER_REG)     \
        li      MARKER_REG,     0xBB;           \
        blt     RS1,    RS2,    1f;             \
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

        // Test cases for the 'blt' instruction.
        // The results are stored sequentially in memory.
        // Expected values: 0x55 = branch correctly taken
        //                  0x66 = branch correctly not taken
        // BLT performs SIGNED comparison: rs1 < rs2

        //-----------------------------------------------------------------------
        // Category 1: Basic Less Than Tests (Positive Numbers)
        //-----------------------------------------------------------------------

        // Test 1: 10 < 20 (should branch)
        li      x1,     10
        li      x2,     20
        BLT_TAKEN(x1, x2, x3)

        // Test 2: 1 < 100 (should branch)
        li      x1,     1
        li      x2,     100
        BLT_TAKEN(x1, x2, x3)

        // Test 3: 0 < 1 (should branch)
        li      x1,     0
        li      x2,     1
        BLT_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 2: Basic Greater Than or Equal Tests (Positive Numbers)
        //-----------------------------------------------------------------------

        // Test 4: 20 >= 10 (should NOT branch)
        li      x1,     20
        li      x2,     10
        BLT_NOT_TAKEN(x1, x2, x3)

        // Test 5: 100 >= 1 (should NOT branch)
        li      x1,     100
        li      x2,     1
        BLT_NOT_TAKEN(x1, x2, x3)

        // Test 6: 10 >= 10 (equal, should NOT branch)
        li      x1,     10
        li      x2,     10
        BLT_NOT_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 3: Negative Number Tests
        //-----------------------------------------------------------------------

        // Test 7: -20 < -10 (should branch)
        li      x1,     -20
        li      x2,     -10
        BLT_TAKEN(x1, x2, x3)

        // Test 8: -10 >= -20 (should NOT branch)
        li      x1,     -10
        li      x2,     -20
        BLT_NOT_TAKEN(x1, x2, x3)

        // Test 9: -10 < 10 (negative < positive, should branch)
        li      x1,     -10
        li      x2,     10
        BLT_TAKEN(x1, x2, x3)

        // Test 10: 10 >= -10 (positive >= negative, should NOT branch)
        li      x1,     10
        li      x2,     -10
        BLT_NOT_TAKEN(x1, x2, x3)

        // Test 11: -1 < 0 (should branch)
        li      x1,     -1
        li      x2,     0
        BLT_TAKEN(x1, x2, x3)

        // Test 12: 0 >= -1 (should NOT branch)
        li      x1,     0
        li      x2,     -1
        BLT_NOT_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 4: Boundary Values
        //-----------------------------------------------------------------------

        // Test 13: Min < Max (most negative < most positive, should branch)
        li      x1,     0x8000000000000000
        li      x2,     0x7FFFFFFFFFFFFFFF
        BLT_TAKEN(x1, x2, x3)

        // Test 14: Max >= Min (most positive >= most negative, should NOT branch)
        li      x1,     0x7FFFFFFFFFFFFFFF
        li      x2,     0x8000000000000000
        BLT_NOT_TAKEN(x1, x2, x3)

        // Test 15: Max >= Max (should NOT branch)
        li      x1,     0x7FFFFFFFFFFFFFFF
        li      x2,     0x7FFFFFFFFFFFFFFF
        BLT_NOT_TAKEN(x1, x2, x3)

        // Test 16: Min >= Min (should NOT branch)
        li      x1,     0x8000000000000000
        li      x2,     0x8000000000000000
        BLT_NOT_TAKEN(x1, x2, x3)

        // Test 17: Max-1 < Max (should branch)
        li      x1,     0x7FFFFFFFFFFFFFFE
        li      x2,     0x7FFFFFFFFFFFFFFF
        BLT_TAKEN(x1, x2, x3)

        // Test 18: Min < Min+1 (should branch)
        li      x1,     0x8000000000000000
        li      x2,     0x8000000000000001
        BLT_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 5: Zero Comparisons
        //-----------------------------------------------------------------------

        // Test 19: 0 >= 0 (should NOT branch)
        li      x1,     0
        li      x2,     0
        BLT_NOT_TAKEN(x1, x2, x3)

        // Test 20: -1 < 0 (should branch)
        li      x1,     -1
        li      x2,     0
        BLT_TAKEN(x1, x2, x3)

        // Test 21: 0 >= -1 (should NOT branch)
        li      x1,     0
        li      x2,     -1
        BLT_NOT_TAKEN(x1, x2, x3)

        // Test 22: 0 < 1 (should branch)
        li      x1,     0
        li      x2,     1
        BLT_TAKEN(x1, x2, x3)

        // Test 23: 1 >= 0 (should NOT branch)
        li      x1,     1
        li      x2,     0
        BLT_NOT_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 6: Same Register Comparison
        //-----------------------------------------------------------------------

        // Test 24: x0 >= x0 (always equal, should NOT branch)
        BLT_NOT_TAKEN(x0, x0, x3)

        // Test 25: Same non-zero register (should NOT branch)
        li      x5,     12345
        BLT_NOT_TAKEN(x5, x5, x3)

        // Test 26: Same negative register (should NOT branch)
        li      x5,     -12345
        BLT_NOT_TAKEN(x5, x5, x3)

        //-----------------------------------------------------------------------
        // Category 7: Small Differences
        //-----------------------------------------------------------------------

        // Test 27: Difference of 1 (positive, should branch)
        li      x1,     100
        li      x2,     101
        BLT_TAKEN(x1, x2, x3)

        // Test 28: Difference of -1 (positive, should NOT branch)
        li      x1,     101
        li      x2,     100
        BLT_NOT_TAKEN(x1, x2, x3)

        // Test 29: Difference of 1 (negative, should branch)
        li      x1,     -101
        li      x2,     -100
        BLT_TAKEN(x1, x2, x3)

        // Test 30: Difference of -1 (negative, should NOT branch)
        li      x1,     -100
        li      x2,     -101
        BLT_NOT_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 8: Register Combinations
        //-----------------------------------------------------------------------

        // Test 31-36: Different register pairs
        li      x1,     5
        li      x2,     10
        BLT_TAKEN(x1, x2, x3)

        li      x4,     -5
        li      x5,     5
        BLT_TAKEN(x4, x5, x3)

        li      x6,     50
        li      x7,     25
        BLT_NOT_TAKEN(x6, x7, x3)

        li      x8,     -25
        li      x9,     -50
        BLT_NOT_TAKEN(x8, x9, x3)

        li      x10,    0
        li      x11,    100
        BLT_TAKEN(x10, x11, x3)

        li      x12,    -100
        li      x13,    0
        BLT_TAKEN(x12, x13, x3)

        //-----------------------------------------------------------------------
        // Category 9: Forward Branch Distance Tests
        //-----------------------------------------------------------------------

        // Test 37: Short forward branch (taken)


        // Test 38: Medium forward branch (taken)


        //-----------------------------------------------------------------------
        // Category 10: Backward Branch Tests
        //-----------------------------------------------------------------------

        // Test 39: Backward branch (taken)

        //-----------------------------------------------------------------------
        // Category 11: Dependency Testing 
        // Not really necessary
        //-----------------------------------------------------------------------

        // Test 40: Result of previous instruction used in BLT
        li      x1,     50
        addi    x2,     x1,     10
        BLT_TAKEN(x1, x2, x3)

        // Test 41: Back-to-back dependencies
        li      x1,     30
        addi    x2,     x1,     5
        addi    x1,     x2,     -10
        BLT_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 12: Large Magnitude Differences
        //-----------------------------------------------------------------------

        // Test 42: Very large positive difference
        li      x1,     1
        li      x2,     0x7FFFFFFFFFFFFFFF
        BLT_TAKEN(x1, x2, x3)

        // Test 43: Very large negative difference
        li      x1,     0x8000000000000000
        li      x2,     -1
        BLT_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 13: Random Value Tests
        //-----------------------------------------------------------------------

        // Test 44-52: Random comparison tests (9 tests)
        li      x1,     RANDIMM
        li      x2,     RANDIMM
        blt     x1,     x2,     1f
        li      x3,     0x66
        j       2f
1:      li      x3,     0x55
2:      STORE_X31(x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        blt     x1,     x2,     1f
        li      x3,     0x66
        j       2f
1:      li      x3,     0x55
2:      STORE_X31(x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        blt     x1,     x2,     1f
        li      x3,     0x66
        j       2f
1:      li      x3,     0x55
2:      STORE_X31(x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        blt     x1,     x2,     1f
        li      x3,     0x66
        j       2f
1:      li      x3,     0x55
2:      STORE_X31(x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        blt     x1,     x2,     1f
        li      x3,     0x66
        j       2f
1:      li      x3,     0x55
2:      STORE_X31(x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        blt     x1,     x2,     1f
        li      x3,     0x66
        j       2f
1:      li      x3,     0x55
2:      STORE_X31(x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        blt     x1,     x2,     1f
        li      x3,     0x66
        j       2f
1:      li      x3,     0x55
2:      STORE_X31(x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        blt     x1,     x2,     1f
        li      x3,     0x66
        j       2f
1:      li      x3,     0x55
2:      STORE_X31(x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        blt     x1,     x2,     1f
        li      x3,     0x66
        j       2f
1:      li      x3,     0x55
2:      STORE_X31(x3)

        // Exit the test with a success code (0).
        EXIT(0)

################################################################################
// Macro Undefine : Undefine the local macro to prevent accidental use later.
################################################################################

#undef BLT_TAKEN
#undef BLT_NOT_TAKEN
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
//     BLT instructions
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
