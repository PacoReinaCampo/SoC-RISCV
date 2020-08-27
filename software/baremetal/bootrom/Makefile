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
##              Software                                                         ##
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
##   Stefan Wallentowitz <stefan.wallentowitz@tum.de>                            ##
##   Philipp Wagner <philipp.wagner@tum.de>                                      ##
##   Paco Reina Campo <pacoreinacampo@queenfield.tech>                           ##
##                                                                               ##
###################################################################################

all: bootrom_code.sv bootrom.hex

bootrom.hex: bootrom.bin
	./bin2vmem bootrom.bin > bootrom.hex

bootrom_code.sv: bootrom.bin bin2vlogarray bin2vmem
	cat bootrom_code.sv.header > bootrom_code.sv
	cat bootrom.bin | ./bin2vlogarray >> bootrom_code.sv

bootrom.bin: a.out
	or1k-elf-objcopy -O binary a.out bootrom.bin

bootrom.dis: a.out
	or1k-elf-objdump -d a.out > bootrom.dis

a.out: boot.s
	or1k-elf-as boot.s

bin2vlogarray: bin2vlogarray.c
	gcc -Wall -o bin2vlogarray bin2vlogarray.c

bin2vmem: bin2vmem.c
	gcc -Wall -o bin2vmem bin2vmem.c
	rm -f ../host/bin/bin2vmem
	cp bin2vmem ../host/bin/

install:
	rm -f ../../../rtl/verilog/bootrom/bootrom_code.sv
	cp -i bootrom_code.sv ../../../rtl/verilog/soc/bootrom/

clean:
	rm -f a.out bootrom.bin bootrom.hex bootrom_code.sv bin2vlogarray bin2vmem
