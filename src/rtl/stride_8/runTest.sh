#!/bin/bash
set -e

PYTHON_SCRIPT="generate_signals.py"
VERILOG_FILES="stride_8.v tb_stride_8.v"
OUTPUT_EXE="test_stride.vvp"

echo "--- Step 1: Generating test vectors with Python... ---"
python3 $PYTHON_SCRIPT

echo "--- Step 2: Compiling Verilog files with Icarus... ---"
iverilog -o $OUTPUT_EXE $VERILOG_FILES

echo "--- Step 3: Running simulation... ---"
vvp $OUTPUT_EXE