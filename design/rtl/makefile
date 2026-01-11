SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Lista de tus archivos Verilog
VERILOG_SOURCES += $(PWD)/shift_r4.v
VERILOG_SOURCES += $(PWD)/shift_r2.v
VERILOG_SOURCES += $(PWD)/fft32.v

TOPLEVEL = fft32  # El módulo que quieres testear
MODULE = test_fft # El nombre del archivo python (sin .py)

include $(shell cocotb-config --makefiles)/Makefile.sim