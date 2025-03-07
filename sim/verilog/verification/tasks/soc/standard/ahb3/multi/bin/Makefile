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
##              MPSoC-RV64 CPU                                                   ##
##              Regression Test Makefile                                         ##
##                                                                               ##
###################################################################################

###################################################################################
##                                                                               ##
## Copyright (c) 2017-2018 by the author(s)                                      ##
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
##   Francisco Javier Reina Campo <pacoreinacampo@queenfield.tech>               ##
##                                                                               ##
###################################################################################

all: regression

SIMULATORS = msim ncsim vcs riviera verilator
LINTERS    = $(addsuffix _lint, $(SIMULATORS))
SIMWAVES   = $(addsuffix _waves, $(SIMULATORS))
SIMGATES   = $(addsuffix _gate, $(SIMULATORS))
SIM        = msim_waves

MS     = -s

ROOT_DIR=../../../..
TST_SRC_DIR=$(ROOT_DIR)/../sw

##########################################################################
# Tests
##########################################################################
XLEN    = 32
HAS_U   = 1 
HAS_S   = 0
HAS_H   = 0
HAS_RVA =
HAS_FPU =
HAS_MMU =
HAS_RVC = 1
HAS_RVM = 1
CORES   = 1

logs = test-app.log riscv-blink-int.log riscv-blink-int-bjorn.log dhrystone.riscv32.log rv_soc.log

regression: $(logs)

##########################################################################
# Sources
##########################################################################
-include Makefile.include

##########################################################################
# libraries
##########################################################################
RTL_LIBS =

##########################################################################
# Misc Variables
##########################################################################
INCDIRS:=$(INCDIRS)
DEFINES:=$(DEFINES)

shell=/bin/sh

##########################################################################
# OVL
##########################################################################
ifeq ($(OVL_ASSERT),ON)
    INCDIRS+=$(STD_OVL_DIR) $(INCDIRS)
    DEFINES+=OVL_ASSERT_ON $(DEFINES)
    LIBDIRS+=$(STD_OVL_DIR)
    LIBEXT +=.vlib

    ifeq ($(OVL_INIT_MSG),ON)
        DEFINES:=OVL_INIT_MSG $(DEFINES)
    endif
endif

##########################################################################
# Make Targets
##########################################################################
.PHONY: $(SIMULATORS) $(LINTERS) $(SIMWAVES)

%.log:
	$(MAKE) $(SIM) LOG=$(@F) 							\
	PARAMS="XLEN=$(XLEN) 								\
		HAS_RVM=$(HAS_RVM)							\
		HAS_RVC=$(HAS_RVC)							\
		HAS_U=$(HAS_U) HAS_S=$(HAS_S) HAS_H=$(HAS_H)				\
		BOOTROM_INIT_FILE=\"$(TST_SRC_DIR)/bootrom/Debug/bootrom.hex.ver\"	\
		SDRAM_INIT_FILE=\"$(TST_SRC_DIR)/$*/Debug/$*.$(HEX_SUFFIX)\"		\
		JTAG_SERVER_TYPE=\"$(JTAG_DBG)\" "

$(SIMULATORS): % : %/Makefile $(TB_PREREQ)
	@$(MAKE) $(MS) -C $@ sim				\
	VLOG="$(abspath $(RTL_VLOG) $(TB_VLOG))"		\
	TECHLIBS="$(TECHLIBS)"					\
	LIBDIRS="$(LIBDIRS)"					\
	LIBEXT="$(LIBEXT)"					\
	PLI=$(TB_PLI)						\
	VHDL="$(abspath $(RTL_VHDL) $(TB_VHDL))"		\
	INCDIRS="$(abspath $(INCDIRS))"				\
	DEFINES="$(DEFINES)"					\
	TOP=$(TB_TOP)						\
	LOG=$(LOG) PARAMS="$(PARAMS)"				\
	JTAG_DBG=$(JTAG_DBG)

$(SIMWAVES): %_waves : %/Makefile $(TB_PREREQ)
	$(MAKE) $(MS) -C $(subst _waves,,$@) simw		\
	VLOG="$(abspath $(RTL_VLOG) $(TB_VLOG))"		\
	TECHLIBS="$(TECHLIBS)"					\
	LIBDIRS="$(LIBDIRS)"					\
	LIBEXT="$(LIBEXT)"					\
	PLI=$(TB_PLI)						\
	VHDL="$(abspath $(RTL_VHDL) $(TB_VHDL))"		\
	INCDIRS="$(abspath $(INCDIRS))"				\
	DEFINES="$(DEFINES)"					\
	TOP=$(TB_TOP)						\
	LOG=$(LOG) PARAMS="$(PARAMS)"				\
	JTAG_DBG=$(JTAG_DBG)

$(SIMGATES): %_gate : %/Makefile $(TB_PREREQ)
	$(MAKE) $(MS) -C $(subst _gate,,$@) simgate		\
	VLOG="$(abspath $(GATE_VLOG) $(TB_VLOG))"		\
	SDF="$(abspath $(GATE_SDF))"				\
	TECHLIBS="$(TECHLIBS)"					\
	LIBDIRS="$(LIBDIRS)"					\
	LIBEXT="$(LIBEXT)"					\
	PLI=$(TB_PLI)						\
	INCDIRS="$(abspath $(INCDIRS))"				\
	DEFINES="$(DEFINES)"					\
	TOP=$(TB_TOP)						\
	LOG=$(LOG) PARAMS="$(PARAMS)"				\
	JTAG_DBG=$(JTAG_DBG)

$(LINTERS): %_lint : %/Makefile $(TB_PREREQ)
	@$(MAKE) $(MS) -C $(subst _lint,,$@) lint		\
	VLOG="$(abspath $(RTL_VLOG))"				\
	VHDL="$(abspath $(RTL_VHDL))"				\
	INCDIRS="$(abspath $(INCDIRS))"				\
	DEFINES="$(DEFINES)"					\
	TOP=$(RTL_TOP)

.PHONY: clean distclean mrproper
clean:
	@for f in $(wildcard *); do				\
		if test -d $$f; then $(MAKE) -C $$f clean; fi	\
	done

distclean:
	@rm -rf $(SIMULATORS) Makefile.include $(TB_PREREQ)

mrproper:
	@rm -rf *

##########################################################################
# Make simulation structure
##########################################################################
Makefile.include:
	@cp ../bin/Makefile.include .

%/Makefile:
	@mkdir -p $*
	@cp ../bin/sims/Makefile.$* $@

$(TB_PREREQ):
	@cp ../bin/$@ $@
