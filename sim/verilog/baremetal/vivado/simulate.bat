@echo off
call ../../../../settings64_vivado.bat

xvlog -prj soc.prj \
-i ../../../../pu/rtl/verilog/pkg \
-i ../../../../rtl/verilog/soc/bootrom \
-i ../../../../dma/rtl/verilog/ahb3/pkg
xelab riscv_tile
xsim -R riscv_tile
pause
