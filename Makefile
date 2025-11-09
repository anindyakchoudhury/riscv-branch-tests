SHELL := /bin/bash

####################################################################################################
# VARIABLES
####################################################################################################

# Get the root directory
ROOT_DIR = $(shell echo $(realpath .))

# Default goal is to help
.DEFAULT_GOAL := help

# Test specification
TEST ?= default

# Debug mode
DEBUG ?= 0

####################################################################################################
# TOOL CONFIGURATION
####################################################################################################

RISCV64_GCC ?= riscv64-unknown-elf-gcc
RISCV64_OBJCOPY ?= riscv64-unknown-elf-objcopy
RISCV64_NM ?= riscv64-unknown-elf-nm
RISCV64_OBJDUMP ?= riscv64-unknown-elf-objdump
SPIKE ?= spike

####################################################################################################
# TARGETS
####################################################################################################

# Help target: displays help message
.PHONY: help
help:
	@echo -e "\033[1;36mRISC-V Instruction Test Suite\033[0m"
	@echo -e "\033[1;36m==============================\033[0m"
	@echo ""
	@echo -e "\033[1;36mAvailable targets:\033[0m"
	@echo -e "\033[1;33m  test           \033[0m- Build test binary and run Spike to generate reference data"
	@echo -e "\033[1;33m  clean          \033[0m- Remove build directory"
	@echo -e "\033[1;33m  clean_full     \033[0m- Remove both build and log directories"
	@echo -e "\033[1;33m  help           \033[0m- Display this help message"
	@echo ""
	@echo -e "\033[1;36mVariables:\033[0m"
	@echo -e "\033[1;33m  TEST           \033[0m- Test file path (required for 'test' target)"
	@echo -e "                   Example: TEST=rv32i/add.S"
	@echo -e "\033[1;33m  DEBUG          \033[0m- Enable debug mode (default: 0)"
	@echo -e "                   Set to 1 for interactive Spike debugger"
	@echo ""
	@echo -e "\033[1;36mExamples:\033[0m"
	@echo -e "  make test TEST=rv32i/add.S"
	@echo -e "  make test TEST=rv32i/bge.S DEBUG=1"
	@echo -e "  make clean"
	@echo -e "  make clean_full"
	@echo ""

# Build directory target: creates build directory and adds it to gitignore
.PHONY: build
build:
	@mkdir -p build
	@echo "*" > build/.gitignore
	@git add build/.gitignore > /dev/null 2>&1 || true

# Log directory target: creates log directory and adds it to gitignore
.PHONY: log
log:
	@mkdir -p log
	@echo "*" > log/.gitignore
	@git add log/.gitignore > /dev/null 2>&1 || true

# Clean target: removes build directory
.PHONY: clean
clean:
	@echo -e "\033[3;35mCleaning build directory...\033[0m"
	@rm -rf build
	@echo -e "\033[1;32m✓ Build directory cleaned\033[0m"

# Clean full target: removes both build and log directories
.PHONY: clean_full
clean_full:
	@echo -e "\033[3;35mCleaning build and log directories...\033[0m"
	@rm -rf build
	@rm -rf log
	@echo -e "\033[1;32m✓ Build and log directories cleaned\033[0m"

# Test target: builds test binaries using RISC-V toolchain and runs Spike
.PHONY: test
test: build log
	@# Validate TEST parameter
	@if [ "$(TEST)" = "default" ]; then \
		echo -e "\033[1;31m✗ Error: TEST parameter is required\033[0m"; \
		echo -e "\033[1;33m  Usage: make test TEST=rv32i/<instruction>.S\033[0m"; \
		echo -e "\033[1;33m  Example: make test TEST=rv32i/add.S\033[0m"; \
		exit 1; \
	fi
	@if [ ! -f riscv-tests/$(TEST) ]; then \
		echo -e "\033[1;31m✗ Error: Test file 'riscv-tests/$(TEST)' does not exist\033[0m"; \
		exit 1; \
	fi
	@# Build test binaries
	@echo -e "\033[1;36m==> Building test: $(TEST)\033[0m"
	@echo -e "\033[3;35mCompiling for RTL simulation...\033[0m"
	@${RISCV64_GCC} -march=rv64g -nostdlib -nostartfiles \
		-o build/prog.elf riscv-tests/$(TEST) \
		-I riscv-tests/include -T linker/rtl.ld
	@echo -e "\033[3;35mCompiling for Spike simulation...\033[0m"
	@${RISCV64_GCC} -march=rv64g -nostdlib -nostartfiles \
		-o build/spike.elf riscv-tests/$(TEST) \
		-I riscv-tests/include -T linker/spike.ld
	@# Generate auxiliary files
	@echo -e "\033[3;35mGenerating hex file and symbol tables...\033[0m"
	@${RISCV64_OBJCOPY} -O verilog build/prog.elf build/prog.hex
	@${RISCV64_NM} build/prog.elf > build/prog.sym
	@${RISCV64_NM} build/spike.elf > build/spike.sym
	@${RISCV64_OBJDUMP} -d build/prog.elf > build/prog.dump
	@${RISCV64_OBJDUMP} -d build/spike.elf > build/spike.dump
	@# Run Spike simulator
	@echo -e "\033[3;35mRunning Spike ISA simulator...\033[0m"
	@if [ "$(DEBUG)" = "1" ]; then \
		if [ -d build/xsim.dir ]; then \
			${SPIKE} -l --log-commits --isa=rv64g --pc=0x40000000 \
				-m0x40000000:0x8000000 build/spike.elf 2>&1 | tee build/spike; \
		else \
			echo -e "\033[1;33mEntering interactive Spike debugger...\033[0m"; \
			${SPIKE} -l --log-commits -d --isa=rv64g --pc=0x40000000 \
				-m0x40000000:0x8000000 build/spike.elf; \
		fi \
	else \
		${SPIKE} -l --log-commits --isa=rv64g --pc=0x40000000 \
			-m0x40000000:0x8000000 build/spike.elf 2>&1 | tee build/spike; \
	fi
	@# Extract test data
	@echo -e "\033[3;35mExtracting test data...\033[0m"
	@cat build/spike | grep ") mem 0x" | sed "s/.*mem 0x/@/g" > build/mem_writes || echo -n ""
	@python riscv-tests/test_data_extract.py
	@rm -f build/spike build/mem_writes
	@# Success message
	@echo -e "\033[1;32m Test completed successfully!\033[0m"
	@echo -e "\033[1;36m==> Output files in build/ directory:\033[0m"
	@echo -e "  prog.elf       - RTL simulation binary"
	@echo -e "  prog.hex       - Memory initialization file"
	@echo -e "  prog.dump      - Disassembly listing"
	@echo -e "  spike.elf      - Spike simulation binary"
	@echo -e "  test_data      - Extracted reference data"