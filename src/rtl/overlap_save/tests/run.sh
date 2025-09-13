#!/bin/bash

set -e

V_FILES="overlap_save.v tb_overlap_save.v"
OUTPUT_EXE="test.vvp"
VCD_FILE="tb_overlap_save.vcd"

echo "[1] Cleaning old files..."
rm -f $OUTPUT_EXE $VCD_FILE

echo "[2] Compiling verilog..."
iverilog -o $OUTPUT_EXE $V_FILES

echo "[3] Running simulation..."
vvp $OUTPUT_EXE

echo "[4] Loading waveforms..."
gtkwave $VCD_FILE