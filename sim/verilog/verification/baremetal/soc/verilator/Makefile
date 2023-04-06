###################################################################################
##                                            __ _      _     _                  ##
##                                           / _(_)    | |   | |                 ##
##                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |                 ##
##               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |                 ##
##              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |                 ##
##               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|                 ##
##                  | |                                                          ##
##                  |_|                                                          ##
##                                                                               ##
##                                                                               ##
##              Architecture                                                     ##
##              QueenField                                                       ##
##                                                                               ##
###################################################################################

###################################################################################
##                                                                               ##
## Copyright (c) 2019-2020 by the author(s)                                      ##
##                                                                               ##
## Permission is hereby granted, free of charge, to any person obtaining a copy  ##
## of this software and associated documentation files (the "Software"), to deal ##
## in the Software without restriction, including without limitation the rights  ##
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     ##
## copies of the Software, and to permit persons to whom the Software is         ##
## furnished to do so, subject to the following conditions:                      ##
##                                                                               ##
## The above copyright notice and this permission notice shall be included in    ##
## all copies or substantial portions of the Software.                           ##
##                                                                               ##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    ##
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      ##
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   ##
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        ##
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, ##
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN     ##
## THE SOFTWARE.                                                                 ##
##                                                                               ##
## ============================================================================= ##
## Author(s):                                                                    ##
##   Paco Reina Campo <pacoreinacampo@queenfield.tech>                           ##
##                                                                               ##
###################################################################################

all: hardware-mpsoc2d software-mpsoc2d

hardware-tile:
	verilator -f soc.vc --trace -Wno-fatal -Wno-lint -Wno-UNOPTFLAT -Wno-COMBDLY -CFLAGS "-std=c++11" -LDFLAGS "-pthread"
	make -f Vsoc_riscv_tile_testbench.mk

hardware-mpsoc2d:
	verilator -f mpsoc2d.vc --trace -Wno-fatal -Wno-lint -Wno-UNOPTFLAT -Wno-COMBDLY -CFLAGS "-std=c++11" -LDFLAGS "-pthread"
	make -f Vmpsoc2d_riscv_testbench.mk

hardware-mpsoc3d:
	verilator -f mpsoc3d.vc --trace -Wno-fatal -Wno-lint -Wno-UNOPTFLAT -Wno-COMBDLY -CFLAGS "-std=c++11" -LDFLAGS "-pthread"
	make -f Vmpsoc3d_riscv_testbench.mk

hardware-mpsoc4d:
	verilator -f mpsoc4d.vc --trace -Wno-fatal -Wno-lint -Wno-UNOPTFLAT -Wno-COMBDLY -CFLAGS "-std=c++11" -LDFLAGS "-pthread"
	make -f Vmpsoc4d_riscv_testbench.mk

software-tile:
	./Vsoc_riscv_tile_testbench --meminit=../../../../../../software/baremetal/heat_mp_simple/c/heat_mp_simple.vmem
	./Vsoc_riscv_tile_testbench --meminit=../../../../../../software/baremetal/hello/c/hello.vmem
	./Vsoc_riscv_tile_testbench --meminit=../../../../../../software/baremetal/hello_mp/c/hello_mp.vmem
	./Vsoc_riscv_tile_testbench --meminit=../../../../../../software/baremetal/hello_mp_simple/c/hello_mp_simple.vmem

software-mpsoc2d:
	./Vmpsoc2d_riscv_testbench --meminit=../../../../../../software/baremetal/hello/c/hello.vmem
	./Vmpsoc2d_riscv_testbench --meminit=../../../../../../software/baremetal/hello_mp/c/hello_mp.vmem
	./Vmpsoc2d_riscv_testbench --meminit=../../../../../../software/baremetal/hello_mp_simple/c/hello_mp_simple.vmem

software-mpsoc3d:
	./Vmpsoc3d_riscv_testbench --meminit=../../../../../../software/baremetal/hello/c/hello.vmem
	./Vmpsoc3d_riscv_testbench --meminit=../../../../../../software/baremetal/hello_mp/c/hello_mp.vmem
	./Vmpsoc3d_riscv_testbench --meminit=../../../../../../software/baremetal/hello_mp_simple/c/hello_mp_simple.vmem

software-mpsoc4d:
	./Vmpsoc4d_riscv_testbench --meminit=../../../../../../software/baremetal/hello/c/hello.vmem
	./Vmpsoc4d_riscv_testbench --meminit=../../../../../../software/baremetal/hello_mp/c/hello_mp.vmem
	./Vmpsoc4d_riscv_testbench --meminit=../../../../../../software/baremetal/hello_mp_simple/c/hello_mp_simple.vmem

clear:
	rm -rf *.a *.cpp *.d *.dat *.h *.o *.mk

clean:
	rm -rf *.a *.cpp *.d *.dat *.h *.o *.mk Vsoc_riscv_* stdout.*
