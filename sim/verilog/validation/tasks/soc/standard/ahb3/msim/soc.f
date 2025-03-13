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

+incdir+../../../../../../../../peripheral/dbg/rtl/pu/riscv/verilog/code/pkg/core

../../../../../../../../pu/rtl/verilog/pkg/peripheral_ahb3_verilog_pkg.sv
../../../../../../../../pu/rtl/verilog/pkg/peripheral_biu_verilog_pkg.sv
../../../../../../../../pu/rtl/verilog/pkg/pu_riscv_verilog_pkg.sv

../../../../../../../../rtl/verilog/pkg/standard/peripheral_ahb3_pkg.sv
../../../../../../../../rtl/verilog/pkg/standard/peripheral_apb4_pkg.sv

../../../../../../../../pu/rtl/verilog/core/cache/pu_riscv_dcache_core.sv
../../../../../../../../pu/rtl/verilog/core/cache/pu_riscv_dext.sv
../../../../../../../../pu/rtl/verilog/core/cache/pu_riscv_icache_core.sv
../../../../../../../../pu/rtl/verilog/core/cache/pu_riscv_noicache_core.sv
../../../../../../../../pu/rtl/verilog/core/decode/pu_riscv_id.sv
../../../../../../../../pu/rtl/verilog/core/execute/pu_riscv_alu.sv
../../../../../../../../pu/rtl/verilog/core/execute/pu_riscv_bu.sv
../../../../../../../../pu/rtl/verilog/core/execute/pu_riscv_divider.sv
../../../../../../../../pu/rtl/verilog/core/execute/pu_riscv_execution.sv
../../../../../../../../pu/rtl/verilog/core/execute/pu_riscv_lsu.sv
../../../../../../../../pu/rtl/verilog/core/execute/pu_riscv_multiplier.sv
../../../../../../../../pu/rtl/verilog/core/fetch/pu_riscv_if.sv
../../../../../../../../pu/rtl/verilog/core/main/pu_riscv_bp.sv
../../../../../../../../pu/rtl/verilog/core/main/pu_riscv_core.sv
../../../../../../../../pu/rtl/verilog/core/main/pu_riscv_du.sv
../../../../../../../../pu/rtl/verilog/core/main/pu_riscv_memory.sv
../../../../../../../../pu/rtl/verilog/core/main/pu_riscv_rf.sv
../../../../../../../../pu/rtl/verilog/core/main/pu_riscv_state.sv
../../../../../../../../pu/rtl/verilog/core/main/pu_riscv_writeback.sv
../../../../../../../../pu/rtl/verilog/core/memory/pu_riscv_dmem_ctrl.sv
../../../../../../../../pu/rtl/verilog/core/memory/pu_riscv_imem_ctrl.sv
../../../../../../../../pu/rtl/verilog/core/memory/pu_riscv_membuf.sv
../../../../../../../../pu/rtl/verilog/core/memory/pu_riscv_memmisaligned.sv
../../../../../../../../pu/rtl/verilog/core/memory/pu_riscv_mmu.sv
../../../../../../../../pu/rtl/verilog/core/memory/pu_riscv_mux.sv
../../../../../../../../pu/rtl/verilog/core/memory/pu_riscv_pmachk.sv
../../../../../../../../pu/rtl/verilog/core/memory/pu_riscv_pmpchk.sv
../../../../../../../../pu/rtl/verilog/memory/pu_riscv_ram_1r1w_generic.sv
../../../../../../../../pu/rtl/verilog/memory/pu_riscv_ram_1r1w.sv
../../../../../../../../pu/rtl/verilog/memory/pu_riscv_ram_1rw_generic.sv
../../../../../../../../pu/rtl/verilog/memory/pu_riscv_ram_1rw.sv
../../../../../../../../pu/rtl/verilog/memory/pu_riscv_ram_queue.sv
../../../../../../../../pu/rtl/verilog/module/ahb3/pu_riscv_ahb3.sv
../../../../../../../../pu/rtl/verilog/module/ahb3/pu_riscv_biu2ahb3.sv
../../../../../../../../pu/rtl/verilog/module/ahb3/pu_riscv_module_ahb3.sv

../../../../../../../../peripheral/bfm/rtl/verilog/code/error/ahb3/peripheral_error_ahb3.sv
../../../../../../../../peripheral/bfm/rtl/verilog/code/error/apb4/peripheral_error_apb4.sv
../../../../../../../../peripheral/bfm/rtl/verilog/code/mux/apb4/peripheral_mux_apb4.sv
../../../../../../../../peripheral/bfm/rtl/verilog/code/plic/core/peripheral_plic_cell.sv
../../../../../../../../peripheral/bfm/rtl/verilog/code/plic/core/peripheral_plic_core.sv
../../../../../../../../peripheral/bfm/rtl/verilog/code/plic/core/peripheral_plic_dynamic_registers.sv
../../../../../../../../peripheral/bfm/rtl/verilog/code/plic/core/peripheral_plic_gateway.sv
../../../../../../../../peripheral/bfm/rtl/verilog/code/plic/core/peripheral_plic_priority_index.sv
../../../../../../../../peripheral/bfm/rtl/verilog/code/plic/core/peripheral_plic_target.sv
../../../../../../../../peripheral/bfm/rtl/verilog/code/plic/interface/ahb3/peripheral_plic_ahb3.sv
../../../../../../../../peripheral/bfm/rtl/verilog/code/plic/interface/apb4/peripheral_plic_apb4.sv
../../../../../../../../peripheral/bfm/rtl/verilog/code/timer/ahb3/peripheral_timer_ahb3.sv

../../../../../../../../peripheral/dbg/rtl/pu/riscv/verilog/code/core/peripheral_dbg_pu_riscv_biu.sv
../../../../../../../../peripheral/dbg/rtl/pu/riscv/verilog/code/core/peripheral_dbg_pu_riscv_bus_module_core.sv
../../../../../../../../peripheral/dbg/rtl/pu/riscv/verilog/code/core/peripheral_dbg_pu_riscv_bytefifo.sv
../../../../../../../../peripheral/dbg/rtl/pu/riscv/verilog/code/core/peripheral_dbg_pu_riscv_crc32.sv
../../../../../../../../peripheral/dbg/rtl/pu/riscv/verilog/code/core/peripheral_dbg_pu_riscv_jsp_module_core.sv
../../../../../../../../peripheral/dbg/rtl/pu/riscv/verilog/code/core/peripheral_dbg_pu_riscv_module.sv
../../../../../../../../peripheral/dbg/rtl/pu/riscv/verilog/code/core/peripheral_dbg_pu_riscv_status_reg.sv
../../../../../../../../peripheral/dbg/rtl/pu/riscv/verilog/code/core/peripheral_dbg_pu_riscv_syncflop.sv
../../../../../../../../peripheral/dbg/rtl/pu/riscv/verilog/code/core/peripheral_dbg_pu_riscv_syncreg.sv
../../../../../../../../peripheral/dbg/rtl/pu/riscv/verilog/code/peripheral/ahb3/peripheral_dbg_pu_riscv_ahb3_ahb3.sv
../../../../../../../../peripheral/dbg/rtl/pu/riscv/verilog/code/peripheral/ahb3/peripheral_dbg_pu_riscv_jsp_ahb3_ahb3.sv
../../../../../../../../peripheral/dbg/rtl/pu/riscv/verilog/code/peripheral/ahb3/peripheral_dbg_pu_riscv_jsp_module_ahb3.sv
../../../../../../../../peripheral/dbg/rtl/pu/riscv/verilog/code/peripheral/ahb3/peripheral_dbg_pu_riscv_module_ahb3.sv
../../../../../../../../peripheral/dbg/rtl/pu/riscv/verilog/code/peripheral/ahb3/peripheral_dbg_pu_riscv_top_ahb3.sv

../../../../../../../../peripheral/gpio/rtl/verilog/code/peripheral/ahb3/peripheral_ahb32apb4.sv
../../../../../../../../peripheral/gpio/rtl/verilog/code/peripheral/ahb3/peripheral_gpio_ahb3.sv

../../../../../../../../peripheral/uart/rtl/verilog/code/peripheral/ahb3/peripheral_apb2ahb.sv
../../../../../../../../peripheral/uart/rtl/verilog/code/peripheral/ahb3/peripheral_uart_ahb3.sv
../../../../../../../../peripheral/uart/rtl/verilog/code/peripheral/ahb3/peripheral_uart_fifo.sv
../../../../../../../../peripheral/uart/rtl/verilog/code/peripheral/ahb3/peripheral_uart_interrupt.sv
../../../../../../../../peripheral/uart/rtl/verilog/code/peripheral/ahb3/peripheral_uart_rx.sv
../../../../../../../../peripheral/uart/rtl/verilog/code/peripheral/ahb3/peripheral_uart_tx.sv

../../../../../../../../peripheral/spram/rtl/verilog/code/peripheral/ahb3/peripheral_spram_1r1w.sv
../../../../../../../../peripheral/spram/rtl/verilog/code/peripheral/ahb3/peripheral_spram_1r1w_generic.sv
../../../../../../../../peripheral/spram/rtl/verilog/code/peripheral/ahb3/peripheral_spram_ahb3.sv

../../../../../../../../peripheral/msi/rtl/verilog/code/peripheral/ahb3/peripheral_msi_interface_ahb3.sv
../../../../../../../../peripheral/msi/rtl/verilog/code/peripheral/ahb3/peripheral_msi_master_port_ahb3.sv
../../../../../../../../peripheral/msi/rtl/verilog/code/peripheral/ahb3/peripheral_msi_slave_port_ahb3.sv

../../../../../../../../rtl/verilog/soc/standard/pu/pu_riscv_system_ahb3.sv
../../../../../../../../rtl/verilog/soc/standard/pu/pu_riscv_slaves_8b_apb4.sv
../../../../../../../../rtl/verilog/soc/standard/pu/pu_riscv_slaves_32b_apb4.sv
../../../../../../../../rtl/verilog/soc/standard/top/soc_riscv_ahb3.sv

../../../../../../../../pu/verification/tasks/verilog/library/pu/interface/ahb3/pu_riscv_memory_model_ahb3.sv

../../../../../../../../verification/tasks/library/verilog/standard/interface/ahb3/soc_riscv_check_ahb2apb.sv
../../../../../../../../verification/tasks/library/verilog/standard/interface/ahb3/soc_riscv_check_cpu2ahb.sv
../../../../../../../../verification/tasks/library/verilog/standard/interface/ahb3/soc_riscv_testbench.sv
../../../../../../../../verification/tasks/library/verilog/standard/main/soc_riscv_data_validation.sv
../../../../../../../../verification/tasks/library/verilog/standard/main/soc_riscv_dbg_comm_vpi.sv
../../../../../../../../verification/tasks/library/verilog/standard/main/soc_riscv_freertos_task_monitor.sv
../../../../../../../../verification/tasks/library/verilog/standard/main/soc_riscv_jtag_vpi.sv
../../../../../../../../verification/tasks/library/verilog/standard/main/soc_riscv_sdram_model.sv
../../../../../../../../verification/tasks/library/verilog/standard/main/soc_riscv_uart_simulation.sv
