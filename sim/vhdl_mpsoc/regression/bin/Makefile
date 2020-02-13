all: build

build:
	@if [ ! -e work ]; then vlib work; fi
	@vcom -2008 -f mpsoc.vc
	vsim -c -do run.do work.riscv_misd
