all: build

build:
	@if [ ! -e work ]; then vlib work; fi
	@vlog -sv +incdir+../../../../rtl/verilog/pkg -f mpsoc_verilog.vc
	@vcom -2008 -f mpsoc_vhdl.vc
	vsim -c -do run.do work.riscv_soc
