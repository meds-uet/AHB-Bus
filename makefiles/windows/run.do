# For this to work Automatically
# Use this convention to name your rtl and testbench
# Design file should be named (design.sv)
# Testbench file should be named (design_tb.sv)
# Replace (set module "") with the name of your design file (set module "design")


# Define variables
set file_path "../../rtl"
set file_tb_path "../../testbench"
set file "ahb_arbiter"
set file_tb "ahb_arbiter_tb"

set module_tb "ahb_arbiter_tb"

vlib work
vlog -sv -stats=none ${file_path}/${file}.sv
vlog -sv -stats=none ${file_tb_path}/${file_tb}.sv

vsim -voptargs="+acc" ${module_tb}

# Add signals to the waveform
add wave sim:/${module_tb}/dut/*

# Run the simulation
run -all

# Automatically open the waveform window
view wave

# Keeps GUI open after sim
quit -f