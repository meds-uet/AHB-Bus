# Makefile for compiling and simulating SystemVerilog files using ModelSim on Linux

# Variables (modify these if needed)
RTL_DIR := ../../rtl
TB_DIR := ../../testbench

DESIGN := ahb_arbiter
TESTBENCH := ahb_arbiter_tb
MODULE := ahb_arbiter_tb

WORK_LIB := work

# Default target
all: simulate

# Create work library
$(WORK_LIB):
	vlib $(WORK_LIB)

# Compile design and testbench
compile: $(WORK_LIB)
	vlog -sv -stats=none $(RTL_DIR)/$(DESIGN).sv
	vlog -sv -stats=none $(TB_DIR)/$(TESTBENCH).sv

# Simulate using ModelSim
simulate: compile
	vsim -c -voptargs="+acc" $(MODULE) -do "run -all; quit"

# GUI Simulation with waveform
wave: compile
	vsim -voptargs="+acc" $(MODULE) -do "add wave sim:/$(MODULE)/dut/*; view wave; run -all"

# Clean compiled outputs
clean:
	rm -rf transcript vsim.wlf work *.vcd wlf*

.PHONY: all compile simulate wave clean
