################################################################################
//
//  Author : Anindya Kishore Choudhury
//  Email : anindyakchoudhury@gmail.com
//
//  This is a test for the RISC-V 'bgeu' (Branch if Greater Than or Equal Unsigned) instruction.
//  It executes a series of 'bgeu' operations with various register values
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

// BGEU_TAKEN: Macro to test BGEU when branch SHOULD be taken
// Sets a marker value (0xAA) before branch, changes to success value (0x55)
// after branch. If branch fails, marker remains 0xAA.
// 1: is a label (marks a location in code)
// 1f means "forward to the next 1: label"
#define BGEU_TAKEN(RS1, RS2, MARKER_REG)        \
        li      MARKER_REG,     0xAA;           \
        bgeu    RS1,    RS2,    1f;             \
        j       2f;                             \
1:      li      MARKER_REG,     0x55;           \
2:      STORE_X31(MARKER_REG);

// BGEU_NOT_TAKEN: Macro to test BGEU when branch SHOULD NOT be taken
// Sets a marker value (0xBB) before branch, changes to success value (0x66)
// after correctly NOT taking the branch. If branch incorrectly taken, marker remains 0xBB.
#define BGEU_NOT_TAKEN(RS1, RS2, MARKER_REG)    \
        li      MARKER_REG,     0xBB;           \
        bgeu    RS1,    RS2,    1f;             \
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

        // Test cases for the 'bgeu' instruction.
        // The results are stored sequentially in memory.
        // Expected values: 0x55 = branch correctly taken
        //                  0x66 = branch correctly not taken
        // BGEU performs UNSIGNED comparison: rs1 >= rs2
        // In unsigned comparison, there are no negative numbers.
        // All bit patterns represent positive values from 0 to 2^64-1

        //-----------------------------------------------------------------------
        // Category 1: Basic Unsigned Greater Than or Equal Tests
        //-----------------------------------------------------------------------

        // Test 1: 20 >= 10 (should branch)
        li      x1,     20
        li      x2,     10
        BGEU_TAKEN(x1, x2, x3)

        // Test 2: 100 >= 1 (should branch)
        li      x1,     100
        li      x2,     1
        BGEU_TAKEN(x1, x2, x3)

        // Test 3: 1 >= 0 (should branch)
        li      x1,     1
        li      x2,     0
        BGEU_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 2: Basic Unsigned Equality Tests
        //-----------------------------------------------------------------------

        // Test 4: 10 >= 10 (equal, should branch)
        li      x1,     10
        li      x2,     10
        BGEU_TAKEN(x1, x2, x3)

        // Test 5: 0 >= 0 (equal, should branch)
        li      x1,     0
        li      x2,     0
        BGEU_TAKEN(x1, x2, x3)

        // Test 6: MAX >= MAX (equal, should branch)
        li      x1,     0xFFFFFFFFFFFFFFFF
        li      x2,     0xFFFFFFFFFFFFFFFF
        BGEU_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 3: Basic Unsigned Less Than Tests (should NOT branch)
        //-----------------------------------------------------------------------

        // Test 7: 10 < 20 (should NOT branch)
        li      x1,     10
        li      x2,     20
        BGEU_NOT_TAKEN(x1, x2, x3)

        // Test 8: 1 < 100 (should NOT branch)
        li      x1,     1
        li      x2,     100
        BGEU_NOT_TAKEN(x1, x2, x3)

        // Test 9: 0 < 1 (should NOT branch)
        li      x1,     0
        li      x2,     1
        BGEU_NOT_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 4: Unsigned vs Signed Interpretation
        // This is where BGEU differs significantly from BGE
        //-----------------------------------------------------------------------

        // In 64-bit integers:
        // Signed interpretation: Values range from -2^63 to 2^63-1
        // Unsigned interpretation: Values range from 0 to 2^64-1

        // 0x7FFFFFFFFFFFFFFF = +9,223,372,036,854,775,807 (MAX_POSITIVE) = 9,223,372,036,854,775,807 (Unsigned)
        // 0x8000000000000000 = -9,223,372,036,854,775,808 (MIN_NEGATIVE) = 9,223,372,036,854,775,808 (Unsigned)
        // 0xFFFFFFFFFFFFFFFF = -1 (2's Complement) = 18,446,744,073,709,551,615 (MAX_UNSIGNED)


        // Test 10: 0xFFFFFFFFFFFFFFFF vs 0x7FFFFFFFFFFFFFFF
        // Signed: -1 < MAX_POSITIVE (would NOT branch in BGE)
        // Unsigned: MAX_UNSIGNED >= MAX_POSITIVE/2 (should branch in BGEU)
        li      x1,     0xFFFFFFFFFFFFFFFF
        li      x2,     0x7FFFFFFFFFFFFFFF
        BGEU_TAKEN(x1, x2, x3)

        // Test 11: 0x8000000000000000 vs 0x7FFFFFFFFFFFFFFF
        // Signed: MIN_NEGATIVE < MAX_POSITIVE (would NOT branch in BGE)
        // Unsigned: Large positive >= smaller positive (should branch in BGEU)
        li      x1,     0x8000000000000000
        li      x2,     0x7FFFFFFFFFFFFFFF
        BGEU_TAKEN(x1, x2, x3)

        // Test 12: 0x7FFFFFFFFFFFFFFF vs 0x8000000000000000
        // Signed: MAX_POSITIVE >= MIN_NEGATIVE (would branch in BGE)
        // Unsigned: Smaller positive < larger positive (should NOT branch in BGEU)
        li      x1,     0x7FFFFFFFFFFFFFFF
        li      x2,     0x8000000000000000
        BGEU_NOT_TAKEN(x1, x2, x3)

        // Test 13: 0 vs 0xFFFFFFFFFFFFFFFF
        // Signed: 0 > -1 (would branch in BGE)
        // Unsigned: 0 < MAX_UNSIGNED (should NOT branch in BGEU)
        li      x1,     0
        li      x2,     0xFFFFFFFFFFFFFFFF
        BGEU_NOT_TAKEN(x1, x2, x3)

        // Test 14: 0xFFFFFFFFFFFFFFFF vs 0
        // Signed: -1 < 0 (would NOT branch in BGE)
        // Unsigned: MAX_UNSIGNED >= 0 (should branch in BGEU)
        li      x1,     0xFFFFFFFFFFFFFFFF
        li      x2,     0
        BGEU_TAKEN(x1, x2, x3)

        // Test 15: 0x8000000000000000 vs 0
        // Signed: MIN_NEGATIVE < 0 (would NOT branch in BGE)
        // Unsigned: Large positive >= 0 (should branch in BGEU)
        li      x1,     0x8000000000000000
        li      x2,     0
        BGEU_TAKEN(x1, x2, x3)

        // Test 16: 0 vs 0x8000000000000000
        // Signed: 0 > MIN_NEGATIVE (would branch in BGE)
        // Unsigned: 0 < large positive (should NOT branch in BGEU)
        li      x1,     0
        li      x2,     0x8000000000000000
        BGEU_NOT_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 5: Boundary Values (Unsigned Interpretation)
        //-----------------------------------------------------------------------

        // Test 17: MAX_UNSIGNED >= 0 (should branch)
        li      x1,     0xFFFFFFFFFFFFFFFF
        li      x2,     0
        BGEU_TAKEN(x1, x2, x3)

        // Test 18: 0 < MAX_UNSIGNED (should NOT branch)
        li      x1,     0
        li      x2,     0xFFFFFFFFFFFFFFFF
        BGEU_NOT_TAKEN(x1, x2, x3)

        // Test 19: MAX_UNSIGNED >= MAX_UNSIGNED (should branch)
        li      x1,     0xFFFFFFFFFFFFFFFF
        li      x2,     0xFFFFFFFFFFFFFFFF
        BGEU_TAKEN(x1, x2, x3)

        // Test 20: 0 >= 0 (should branch)
        li      x1,     0
        li      x2,     0
        BGEU_TAKEN(x1, x2, x3)

        // Test 21: MAX_UNSIGNED >= MAX_UNSIGNED-1 (should branch)
        li      x1,     0xFFFFFFFFFFFFFFFF
        li      x2,     0xFFFFFFFFFFFFFFFE
        BGEU_TAKEN(x1, x2, x3)

        // Test 22: MAX_UNSIGNED-1 < MAX_UNSIGNED (should NOT branch)
        li      x1,     0xFFFFFFFFFFFFFFFE
        li      x2,     0xFFFFFFFFFFFFFFFF
        BGEU_NOT_TAKEN(x1, x2, x3)

        // Test 23: 1 >= 0 (should branch)
        li      x1,     1
        li      x2,     0
        BGEU_TAKEN(x1, x2, x3)

        // Test 24: 0 < 1 (should NOT branch)
        li      x1,     0
        li      x2,     1
        BGEU_NOT_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 6: Same Register Comparison
        //-----------------------------------------------------------------------

        // Test 25: x0 >= x0 (always equal, should branch)
        BGEU_TAKEN(x0, x0, x3)

        // Test 26: Same non-zero register (should branch)
        li      x5,     12345
        BGEU_TAKEN(x5, x5, x3)

        // Test 27: Same register with high bit set (should branch)
        li      x5,     0x8000000000000000
        BGEU_TAKEN(x5, x5, x3)

        //-----------------------------------------------------------------------
        // Category 7: Small Differences
        //-----------------------------------------------------------------------

        // Test 28: Difference of -1 (should branch)
        li      x1,     101
        li      x2,     100
        BGEU_TAKEN(x1, x2, x3)

        // Test 29: Difference of 1 (should NOT branch)
        li      x1,     100
        li      x2,     101
        BGEU_NOT_TAKEN(x1, x2, x3)

        // Test 30: Very large values, difference of -1 (should branch)
        li      x1,     0xFFFFFFFFFFFFFFFF
        li      x2,     0xFFFFFFFFFFFFFFFE
        BGEU_TAKEN(x1, x2, x3)

        // Test 31: Very large values, difference of 1 (should NOT branch)
        li      x1,     0xFFFFFFFFFFFFFFFE
        li      x2,     0xFFFFFFFFFFFFFFFF
        BGEU_NOT_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 8: Register Combinations
        //-----------------------------------------------------------------------

        // Test 32-37: Different register pairs
        li      x1,     10
        li      x2,     5
        BGEU_TAKEN(x1, x2, x3)

        li      x4,     0x8000000000000001
        li      x5,     0x8000000000000000
        BGEU_TAKEN(x4, x5, x3)

        li      x6,     25
        li      x7,     50
        BGEU_NOT_TAKEN(x6, x7, x3)

        li      x8,     0x7FFFFFFFFFFFFFFF
        li      x9,     0xFFFFFFFFFFFFFFFF
        BGEU_NOT_TAKEN(x8, x9, x3)

        li      x10,    100
        li      x11,    0
        BGEU_TAKEN(x10, x11, x3)

        li      x12,    0
        li      x13,    100
        BGEU_NOT_TAKEN(x12, x13, x3)

        //-----------------------------------------------------------------------
        // Category 9: High Bit Set Comparisons
        //-----------------------------------------------------------------------

        // Test 38: Both high bits set, compare magnitude (should branch)
        li      x1,     0x8000000000000001
        li      x2,     0x8000000000000000
        BGEU_TAKEN(x1, x2, x3)

        // Test 39: Both high bits set, reverse (should NOT branch)
        li      x1,     0x8000000000000000
        li      x2,     0x8000000000000001
        BGEU_NOT_TAKEN(x1, x2, x3)

        // Test 40: Both high bits set, equal (should branch)
        li      x1,     0x8000000000000000
        li      x2,     0x8000000000000000
        BGEU_TAKEN(x1, x2, x3)

        // Test 41: High bit vs no high bit (should branch)
        li      x1,     0x8000000000000000
        li      x2,     0x7FFFFFFFFFFFFFFF
        BGEU_TAKEN(x1, x2, x3)

        // Test 42: No high bit vs high bit (should NOT branch)
        li      x1,     0x7FFFFFFFFFFFFFFF
        li      x2,     0x8000000000000000
        BGEU_NOT_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 10: Forward Branch Distance Tests
        //-----------------------------------------------------------------------

        // Test 43: Short forward branch (taken)


        // Test 44: Medium forward branch (taken)


        //-----------------------------------------------------------------------
        // Category 11: Backward Branch Tests
        //-----------------------------------------------------------------------

        // Test 45: Backward branch (taken)

        //-----------------------------------------------------------------------
        // Category 12: Dependency Testing
        //-----------------------------------------------------------------------

        // Test 46: Result of previous instruction used in BGEU
        li      x1,     60
        addi    x2,     x1,     -10
        BGEU_TAKEN(x1, x2, x3)

        // Test 47: Back-to-back dependencies
        li      x1,     30
        addi    x2,     x1,     -5
        addi    x1,     x2,     10
        BGEU_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 13: Mixed Bit Patterns
        //-----------------------------------------------------------------------

        // Test 48: Alternating bit pattern comparison (should branch)
        li      x1,     0xAAAAAAAAAAAAAAAA
        li      x2,     0x5555555555555555
        BGEU_TAKEN(x1, x2, x3)

        // Test 49: Reverse alternating bit pattern (should NOT branch)
        li      x1,     0x5555555555555555
        li      x2,     0xAAAAAAAAAAAAAAAA
        BGEU_NOT_TAKEN(x1, x2, x3)

        // Test 50: All ones vs all zeros except LSB (should branch)
        li      x1,     0xFFFFFFFFFFFFFFFF
        li      x2,     0x0000000000000001
        BGEU_TAKEN(x1, x2, x3)

        //-----------------------------------------------------------------------
        // Category 14: Random Value Tests
        //-----------------------------------------------------------------------

        // Test 51-52: Random comparison tests (2 tests)
        li      x1,     RANDIMM
        li      x2,     RANDIMM
        bgeu    x1,     x2,     1f
        li      x3,     0x66
        j       2f
1:      li      x3,     0x55
2:      STORE_X31(x3)

        li      x1,     RANDIMM
        li      x2,     RANDIMM
        bgeu    x1,     x2,     1f
        li      x3,     0x66
        j       2f
1:      li      x3,     0x55
2:      STORE_X31(x3)

        // Exit the test with a success code (0).
        EXIT(0)

################################################################################
// Macro Undefine : Undefine the local macro to prevent accidental use later.
################################################################################

#undef BGEU_TAKEN
#undef BGEU_NOT_TAKEN
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
//     BGEU instructions
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

// __riscv_xlen / 8 * 52 (Three Tests are left off for now)
//  = 64 / 8 * 52
//  = 8 * 52
//  = 416 bytes