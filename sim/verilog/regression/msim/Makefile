all: build simulate

build:
	if [ ! -e work ]; then vlib work; fi
	vlog -sv -f soc.vc

simulate:
	vsim -c -do run.do work.riscv_tile_testbench
