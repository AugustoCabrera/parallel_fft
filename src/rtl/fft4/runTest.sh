#!/bin/bash
set -e

PYTHON_SCRIPT="generate_signals.py"
VERILOG_FILES="fft4.v SatTruncFP.v tb_fft4.v"
OUTPUT_EXE="test_fft.vvp"

echo "--- Step 1: Generating test vectors with Python... ---"
python3 $PYTHON_SCRIPT

echo "--- Step 2: Compiling Verilog files with Icarus... ---"
iverilog -o $OUTPUT_EXE $VERILOG_FILES

echo "--- Step 3: Running simulation... ---"
vvp $OUTPUT_EXE