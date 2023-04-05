////////////////////////////////////////////////////////////////////////////////
//                                            __ _      _     _               //
//                                           / _(_)    | |   | |              //
//                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              //
//               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              //
//              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              //
//               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              //
//                  | |                                                       //
//                  |_|                                                       //
//                                                                            //
//                                                                            //
//              MPSoC-RISCV CPU                                               //
//              Multi Processor System on Chip                                //
//              AMBA3 AHB-Lite Bus Interface                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/* Copyright (c) 2019-2020 by the author(s)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * =============================================================================
 * Author(s):
 *   Paco Reina Campo <pacoreinacampo@queenfield.tech>
 */

import peripheral_dbg_soc_dii_channel::dii_flit;
import opensocdebug::peripheral_dbg_soc_mriscv_trace_exec;
import soc_optimsoc_configuration::*;
import soc_optimsoc_functions::*;

module soc_riscv_testbench;

  ////////////////////////////////////////////////////////////////
  //
  // Constans
  //

  // Simulation parameters
  parameter USE_DEBUG = 0;
  parameter integer NUM_CORES = 1;
  parameter integer LMEM_SIZE = 128 * 1024 * 1024;

  localparam base_config_t BASE_CONFIG = '{
    NUMTILES: 1,
    NUMCTS: 1,
    CTLIST: {{63{16'hx}}, 16'h0},
    CORES_PER_TILE: NUM_CORES,
    GMEM_SIZE: 0,
    GMEM_TILE: 0,
    NOC_ENABLE_VCHANNELS: 0,
    LMEM_SIZE: LMEM_SIZE,
    LMEM_STYLE: PLAIN,
    ENABLE_BOOTROM: 0,
    BOOTROM_SIZE: 0,
    ENABLE_DM: 1,
    DM_BASE: 32'h0,
    DM_SIZE: LMEM_SIZE,
    ENABLE_PGAS: 0,
    PGAS_BASE: 0,
    PGAS_SIZE: 0,
    CORE_ENABLE_FPU: 0,
    CORE_ENABLE_PERFCOUNTERS: 0,
    NA_ENABLE_MPSIMPLE: 1,
    NA_ENABLE_DMA: 1,
    NA_DMA_GENIRQ: 1,
    NA_DMA_ENTRIES: 4,
    USE_DEBUG: 1'(USE_DEBUG),
    DEBUG_STM: 1,
    DEBUG_CTM: 1,
    DEBUG_DEM_UART: 1,
    DEBUG_SUBNET_BITS: 6,
    DEBUG_LOCAL_SUBNET: 0,
    DEBUG_ROUTER_BUFFER_SIZE: 4,
    DEBUG_MAX_PKT_LEN: 12
  };

  localparam config_t CONFIG = derive_config(BASE_CONFIG);

  ////////////////////////////////////////////////////////////////
  //
  // Variables
  //

  logic rst_sys;
  logic rst_cpu;

  logic cpu_stall;

  // In Verilator, we feed clk and rst from the C++ toplevel, in ModelSim & Co.
  // these signals are generated inside this testbench.
`ifndef verilator
  reg clk;
  reg rst;
`endif

  wire                [CONFIG.NOC_CHANNELS-1:0]             [CONFIG.NOC_FLIT_WIDTH-1:0]  noc_in_flit;
  wire                [CONFIG.NOC_CHANNELS-1:0]                                          noc_in_last;
  wire                [CONFIG.NOC_CHANNELS-1:0]                                          noc_in_valid;
  wire                [CONFIG.NOC_CHANNELS-1:0]                                          noc_in_ready;
  wire                [CONFIG.NOC_CHANNELS-1:0]             [CONFIG.NOC_FLIT_WIDTH-1:0]  noc_out_flit;
  wire                [CONFIG.NOC_CHANNELS-1:0]                                          noc_out_last;
  wire                [CONFIG.NOC_CHANNELS-1:0]                                          noc_out_valid;
  wire                [CONFIG.NOC_CHANNELS-1:0]                                          noc_out_ready;

  // Monitor system behavior in simulation
  peripheral_dbg_soc_mriscv_trace_exec [                          NUM_CORES-1:0                           ] trace;

  logic               [                   31:0]                                          trace_r3             [0:NUM_CORES-1];

  wire                [          NUM_CORES-1:0]                                          termination;

  // OSD-based debug system
  dii_flit          [                          1:0                                     ] debug_ring_in;
  dii_flit          [                          1:0                                     ] debug_ring_out;

  logic               [                    1:0]                                          debug_ring_in_ready;
  logic               [                    1:0]                                          debug_ring_out_ready;

  genvar i;

  ////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  assign cpu_stall     = 0;

  assign noc_in_flit   = {CONFIG.NOC_FLIT_WIDTH * CONFIG.NOC_CHANNELS{1'bx}};
  assign noc_in_last   = {CONFIG.NOC_CHANNELS{1'bx}};
  assign noc_in_valid  = {CONFIG.NOC_CHANNELS{1'b0}};
  assign noc_out_ready = {CONFIG.NOC_CHANNELS{1'b0}};

  // Monitor system behavior in simulation
  assign trace         = u_compute_tile.trace;

  // Reset signals
  // In simulations with debug system, these signals can be triggered through
  // the host software. In simulations without debug systems, we only rely on
  // the global reset signal.
  generate
    if (USE_DEBUG == 0) begin
      assign rst_sys = rst;
      assign rst_cpu = rst;
    end
  endgenerate


  // The actual system: a single compute tile
  soc_riscv_tile #(
    .CONFIG      (CONFIG),
    .ID          (0),
    .MEM_FILE    ("ct.vmem"),
    .DEBUG_BASEID((CONFIG.DEBUG_LOCAL_SUBNET << (16 - CONFIG.DEBUG_SUBNET_BITS)) + 1)
  ) u_compute_tile (
    // Debug ring ports
    .debug_ring_in       (debug_ring_in),
    .debug_ring_in_ready (debug_ring_in_ready),
    .debug_ring_out      (debug_ring_out),
    .debug_ring_out_ready(debug_ring_out_ready),
    // Outputs
    .noc_in_ready        (noc_in_ready),
    .noc_out_flit        (noc_out_flit),
    .noc_out_last        (noc_out_last),
    .noc_out_valid       (noc_out_valid),
    // Inputs
    .clk                 (clk),
    .rst_cpu             (rst_cpu),
    .rst_sys             (rst_sys),
    .rst_dbg             (rst),
    .noc_in_flit         (noc_in_flit),
    .noc_in_last         (noc_in_last),
    .noc_in_valid        (noc_in_valid),
    .noc_out_ready       (noc_out_ready),

    // Unused
    .ahb3_ext_hsel_i     (),
    .ahb3_ext_haddr_i    (),
    .ahb3_ext_hwdata_i   (),
    .ahb3_ext_hwrite_i   (),
    .ahb3_ext_hsize_i    (),
    .ahb3_ext_hburst_i   (),
    .ahb3_ext_hprot_i    (),
    .ahb3_ext_htrans_i   (),
    .ahb3_ext_hmastlock_i(),

    .ahb3_ext_hrdata_o('0),
    .ahb3_ext_hready_o('0),
    .ahb3_ext_hresp_o ('0)
  );
endmodule
