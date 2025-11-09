# RISC-V Branch Instruction Test Suite

A comprehensive assembly test suite for RISC-V branch instructions, designed for hardware verification and CPU validation workflows.

## Overview

This repository contains systematic test cases for all six RISC-V conditional branch instructions from the RV32I base integer instruction set.

### Branch Instruction Coverage

| Instruction | Function | Comparison Type | Opcode |
|------------|----------|-----------------|---------|
| **BEQ** | Branch if Equal | Equality | `000` |
| **BNE** | Branch if Not Equal | Inequality | `001` |
| **BLT** | Branch if Less Than | Signed | `100` |
| **BGE** | Branch if Greater Than or Equal | Signed | `101` |
| **BLTU** | Branch if Less Than | Unsigned | `110` |
| **BGEU** | Branch if Greater Than or Equal | Unsigned | `111` |

All branch instructions use the B-type format:
```
imm[12|10:5] rs2 rs1 funct3 imm[4:1|11] 1100011
```

## Features

- **Comprehensive Test Coverage**: Each instruction has 40-52 test cases covering:
  - Basic comparisons (equal, greater than, less than)
  - Boundary value testing (max/min signed/unsigned values)
  - Negative numbers and sign handling
  - Signed vs unsigned interpretation differences (BLTU/BGEU vs BLT/BGE)
  - Edge cases and corner conditions
  - Register combination testing
  - Data hazards and dependencies
  - Random value verification with RANDIMM macro

- **Automated Workflow**: Makefile-driven build system for:
  - Assembly compilation with RISC-V GCC toolchain
  - Test binary generation for both RTL simulation and Spike ISA simulator
  - Reference data extraction from Spike execution traces
  - Automated test data generation for hardware verification

- **Spike Integration**: Uses the official RISC-V ISA simulator for golden reference generation

- **Hardware-Ready**: Tests produce marker values (0x55/0x66/0xAA/0xBB) that indicate branch taken/not-taken status for easy verification

## Directory Structure

```
.
├── include/                   # SystemVerilog includes
│   ├── axi/                  # AXI protocol definitions
│   │   ├── assign.svh
│   │   ├── port.svh
│   │   └── typedef.svh
│   └── common_cells/
│       └── registers.svh
├── package/                   # SystemVerilog packages
│   ├── ariane_axi_pkg.sv
│   ├── ariane_pkg.sv
│   ├── axi_pkg.sv
│   ├── cf_math_pkg.sv
│   ├── config_pkg.sv
│   ├── defs_div_sqrt_mvp.sv
│   ├── dm_pkg.sv
│   ├── fpnew_pkg.sv
│   ├── riscv_pkg.sv
│   └── std_cache_pkg.sv
├── riscv-tests/              # Test source files
│   ├── rv32i/               # RV32I branch instruction tests
│   │   ├── beq.S            # Branch if equal (39 tests)
│   │   ├── bne.S            # Branch if not equal (49 tests)
│   │   ├── blt.S            # Branch if less than (49 tests)
│   │   ├── bge.S            # Branch if greater/equal (49 tests)
│   │   ├── bltu.S           # Branch if less than unsigned (49 tests)
│   │   └── bgeu.S           # Branch if greater/equal unsigned (49 tests)
│   ├── include/
│   │   └── ss_riscv_asm.S   # Common assembly macros and definitions
│   ├── template.S           # Template for creating new tests
│   └── test_data_extract.py # Python script for test data extraction
├── linker/                   # Linker scripts
│   ├── rtl.ld               # Linker script for RTL simulation
│   └── spike.ld             # Linker script for Spike simulation
├── build/                    # Build output directory (auto-generated)
├── Makefile                  # Build and test automation
├── readme.md                # This file
└── LICENSE                  # MIT License
```

## Prerequisites

### Required Tools

1. **RISC-V GNU Toolchain**
   ```bash
   # Install from: https://github.com/riscv-collab/riscv-gnu-toolchain
   riscv64-unknown-elf-gcc
   riscv64-unknown-elf-objcopy
   riscv64-unknown-elf-objdump
   riscv64-unknown-elf-nm
   ```

2. **Spike ISA Simulator**
   ```bash
   # Install from: https://github.com/riscv-software-src/riscv-isa-sim
   spike
   ```

3. **Python 3** (for test data extraction)

4. **Make** (GNU Make)

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/anindyakchoudhury/riscv-branch-tests.git
cd riscv-branch-tests
```

### 2. Build and Run a Test
```bash
# Build and simulate the BEQ (Branch if Equal) test
make test TEST=rv32i/beq.S

# Build and simulate the BGE (Branch if Greater/Equal) test
make test TEST=rv32i/bge.S

# Build any branch instruction test
make test TEST=rv32i/<instruction>.S
```

### 3. View Generated Files
After running `make test`, the following files are generated in `build/`:
- `prog.elf` - ELF binary for RTL simulation
- `prog.hex` - Verilog memory initialization file
- `prog.dump` - Disassembly of the program
- `prog.sym` - Symbol table
- `spike.elf` - ELF binary for Spike simulation
- `spike.dump` - Spike disassembly
- `spike.sym` - Spike symbol table
- `test_data` - Extracted reference data from Spike

## Makefile Targets

| Target | Description |
|--------|-------------|
| `help` | Display available targets and variables |
| `test` | Build test binaries and run Spike to generate reference data |
| `clean` | Remove build directory |
| `clean_full` | Remove both build and log directories |

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `TEST` | Test file path under riscv-tests/ | default | Yes (for test target) |
| `DEBUG` | Enable debug mode (verbose Spike output) | 0 | No |

### Examples

```bash
# Run a single test
make test TEST=rv32i/beq.S

# Run test with debug output (interactive Spike)
make test TEST=rv32i/bge.S DEBUG=1

# Clean build artifacts
make clean

# Clean everything (build + logs)
make clean_full

# Run all branch tests (requires complete test infrastructure)
./regression.sh
```

## Test Structure

Each test file follows a consistent structure:

```assembly
################################################################################
//  Author : Anindya Kishore Choudhury
//  Email : anindyakchoudhury@gmail.com
//  Copyright (c) 2025 Tecknoz
//  Licensed under the MIT License
################################################################################

#include "ss_riscv_asm.S"

// Macro definitions for test patterns
#if __riscv_xlen == 64
#define STORE_X31(REG)                  \
        sd      REG,    0(x31);         \
        addi    x31,    x31,    8;
#else
#define STORE_X31(REG)                  \
        sw      REG,    0(x31);         \
        addi    x31,    x31,    4;
#endif

// Instruction-specific macros (e.g., BGE_TAKEN, BGE_NOT_TAKEN)
#define BGE_TAKEN(RS1, RS2, MARKER_REG) ...
#define BGE_NOT_TAKEN(RS1, RS2, MARKER_REG) ...

_start:
    // Initialize result pointer
    la x31, TEST_DATA_BEGIN
    
    // Test categories with multiple test cases
    // Category 1: Basic comparisons
    // Category 2: Boundary values
    // Category 3: Edge cases
    // ... more categories ...
    
    // Exit with success
    EXIT(0)

.data
.align 3
TEST_DATA_BEGIN:
    .zero __riscv_xlen / 8 * <num_tests>
TEST_DATA_END:
```

### Result Markers

Tests use specific marker values to indicate outcomes:
- **0x55** - Branch correctly taken (success)
- **0x66** - Branch correctly not taken (success)
- **0xAA** - Branch incorrectly not taken (failure)
- **0xBB** - Branch incorrectly taken (failure)

## Test Categories

Each branch instruction test includes comprehensive categories:

### Common Categories (All Instructions)
1. **Basic Comparisons** - Fundamental operation verification
2. **Boundary Values** - Max/min value testing for signed/unsigned
3. **Same Register Comparison** - Comparing register with itself
4. **Register Combinations** - Various register pair usage
5. **Small Differences** - Adjacent values (±1)
6. **Dependency Testing** - Back-to-back instruction dependencies
7. **Random Value Tests** - Pseudo-random verification using RANDIMM

### Instruction-Specific Categories

#### BEQ (Branch if Equal)
- Equality tests with positive, negative, and zero values
- Max/min boundary equality tests
- 39 total test cases

#### BNE (Branch if Not Equal)
- Inequality tests across value ranges
- Zero vs non-zero comparisons
- 49 total test cases

#### BLT (Branch if Less Than - Signed)
- Signed comparisons with negative numbers
- Positive < negative vs negative < positive
- 49 total test cases

#### BGE (Branch if Greater/Equal - Signed)
- Signed greater-than-or-equal comparisons
- Negative number ordering
- 49 total test cases

#### BLTU (Branch if Less Than - Unsigned)
- Unsigned interpretation of bit patterns
- High bit set comparisons (no negative numbers in unsigned)
- Tests demonstrating signed vs unsigned differences
- 49 total test cases

#### BGEU (Branch if Greater/Equal - Unsigned)
- Unsigned greater-than-or-equal comparisons
- Mixed bit pattern testing
- Demonstrates how 0xFFFFFFFFFFFFFFFF is MAX_UNSIGNED, not -1
- 49 total test cases

### Key Difference: Signed vs Unsigned Instructions

The unsigned branch instructions (BLTU/BGEU) differ significantly from signed (BLT/BGE):

```assembly
// Example: 0xFFFFFFFFFFFFFFFF vs 0x7FFFFFFFFFFFFFFF

// Signed interpretation (BLT/BGE):
// 0xFFFFFFFFFFFFFFFF = -1
// 0x7FFFFFFFFFFFFFFF = +9,223,372,036,854,775,807
// Result: -1 < MAX_POSITIVE

// Unsigned interpretation (BLTU/BGEU):
// 0xFFFFFFFFFFFFFFFF = 18,446,744,073,709,551,615 (MAX_UNSIGNED)
// 0x7FFFFFFFFFFFFFFF = 9,223,372,036,854,775,807
// Result: MAX_UNSIGNED > (MAX_UNSIGNED/2)
```

## Integration with Hardware Verification

The test suite is designed to integrate with hardware verification flows:

1. **Memory Initialization**: Use `prog.hex` to initialize instruction memory
2. **Execution**: Run the test on your RTL simulation or FPGA
3. **Result Verification**: Compare memory contents at `TEST_DATA_BEGIN` with expected values
4. **Reference Data**: Use Spike-generated data as golden reference from `build/test_data`

### Verification Flow

```
┌─────────────────┐
│  Assembly Test  │
│   (*.S file)    │
└────────┬────────┘
         │
         ├─────────────┬──────────────┐
         ▼             ▼              ▼
    ┌────────┐   ┌─────────┐   ┌──────────┐
    │prog.elf│   │prog.hex │   │spike.elf │
    └────┬───┘   └────┬────┘   └─────┬────┘
         │            │              │
         ▼            ▼              ▼
    ┌────────┐   ┌─────────┐   ┌──────────┐
    │  RTL   │   │ Memory  │   │  Spike   │
    │  Sim   │   │  Init   │   │Simulator │
    └────┬───┘   └─────────┘   └─────┬────┘
         │                           │
         │                           ▼
         │                      ┌──────────┐
         │                      │Reference │
         │                      │   Data   │
         │                      └─────┬────┘
         │                            │
         └────────────┬───────────────┘
                      ▼
              ┌───────────────┐
              │   Compare &   │
              │    Verify     │
              └───────────────┘
```

## Contributing

Contributions are welcome! To add new tests:

1. Use the template: `riscv-tests/template.S`
2. Follow the existing test structure and naming conventions
3. Include comprehensive test categories (aim for 40+ test cases)
4. Ensure tests pass with Spike before submitting
5. Update this README if adding new instruction categories
6. Submit a pull request with clear description

### Coding Standards

- Use consistent indentation (8 spaces for assembly code)
- Include descriptive comments for each test case
- Group related tests into categories with clear headers
- Use meaningful register names when possible
- Follow the existing macro patterns

## Project Status

**Current Coverage**: Complete RISC-V branch instruction set (6 instructions)

**Tested Instructions**: 6/6 ✓

| Instruction | Status | Test Cases | Notes |
|-------------|--------|------------|-------|
| BEQ | ✓ Complete | 39 | Equality testing |
| BNE | ✓ Complete | 49 | Inequality testing |
| BLT | ✓ Complete | 49 | Signed less than |
| BGE | ✓ Complete | 49 | Signed greater/equal |
| BLTU | ✓ Complete | 49 | Unsigned less than |
| BGEU | ✓ Complete | 49 | Unsigned greater/equal |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author of Branch Test Files

**Anindya Kishore Choudhury**  
Email: anindyakchoudhury@gmail.com  
Copyright (c) 2025 Tecknoz


## Acknowledgments

- Based on the RISC-V ISA specification
- Uses the official RISC-V toolchain and Spike ISA simulator
- Designed for use with the CVA6 (Ariane) processor verification environment
- Test methodology inspired by industry-standard verification practices
- Reviewed by Foez Ahmed, Tecknoz

## References

- [RISC-V ISA Specification](https://riscv.org/technical/specifications/)
- [RISC-V Instruction Set Manual](https://github.com/riscv/riscv-isa-manual)
- [RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
- [Spike ISA Simulator](https://github.com/riscv-software-src/riscv-isa-sim)
- [CVA6 RISC-V CPU](https://github.com/openhwgroup/cva6)

## Support

For questions, issues, or suggestions:
- Open an issue on GitHub
- Contact: anindyakchoudhury@gmail.com

---

**Note**: This test suite focuses on functional correctness of RISC-V branch instructions. The tests verify both signed (BLT/BGE) and unsigned (BLTU/BGEU) comparison semantics, with special attention to boundary conditions and the differences in signed vs unsigned interpretation of bit patterns.