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
//              TestBench                                                     //
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
 *   Francisco Javier Reina Campo <frareicam@gmail.com>
 */

`include "riscv_mpsoc_pkg.sv"

module riscv_testbench;

  //core parameters
  parameter XLEN               = 64;
  parameter PLEN               = 64;          //64bit address bus
  parameter PC_INIT            = 'h8000_0000; //Start here after reset
  parameter BASE               = PC_INIT;     //offset where to load program in memory
  parameter INIT_FILE          = "test.hex";
  parameter MEM_LATENCY        = 1;
  parameter WRITEBUFFER_SIZE   = 4;
  parameter HAS_U              = 1;
  parameter HAS_S              = 1;
  parameter HAS_H              = 1;
  parameter HAS_MMU            = 1;
  parameter HAS_FPU            = 1;
  parameter HAS_RVA            = 1;
  parameter HAS_RVM            = 1;
  parameter MULT_LATENCY       = 1;

  parameter HTIF               = 0; //Host-interface
  parameter TOHOST             = 32'h80001000;
  parameter UART_TX            = 32'h80001080;

  //caches
  parameter ICACHE_SIZE        = 0;
  parameter DCACHE_SIZE        = 0;

  parameter PMA_CNT            = 4;

  parameter CORES_PER_SIMD     = 4;
  parameter CORES_PER_MISD     = 4;

  //noc parameters
  parameter CHANNELS           = 7;
  parameter PCHANNELS          = 1;
  parameter VCHANNELS          = 7;

  parameter X                  = 2;
  parameter Y                  = 2;
  parameter Z                  = 2;

  parameter CORES_PER_TILE     = CORES_PER_SIMD + CORES_PER_MISD;
  parameter NODES              = X*Y*Z;
  parameter CORES              = NODES*CORES_PER_TILE;

  parameter HADDR_SIZE         = PLEN;
  parameter HDATA_SIZE         = XLEN;
  parameter PADDR_SIZE         = PLEN;
  parameter PDATA_SIZE         = XLEN;

  parameter FLIT_WIDTH         = 34;

  parameter ADDR_WIDTH     = 32;
  parameter DATA_WIDTH     = 32;
  parameter CPU_ADDR_WIDTH = 32;
  parameter CPU_DATA_WIDTH = 32;
  parameter DATAREG_LEN    = 64;

  //////////////////////////////////////////////////////////////////
  //
  // Constants
  //

  localparam MULLAT = MULT_LATENCY > 4 ? 4 : MULT_LATENCY;

  localparam MISD_BITS = $clog2(CORES_PER_MISD);
  localparam SIMD_BITS = $clog2(CORES_PER_SIMD);

  //////////////////////////////////////////////////////////////////
  //
  // Functions
  //

  function integer onehot2int_simd;
    input [CORES_PER_SIMD-1:0] onehot;

    for (onehot2int_simd = - 1; |onehot; onehot2int_simd++) onehot = onehot >> 1;
  endfunction //onehot2int_simd

  function [2:0] highest_simd_requested_priority (
    input [CORES_PER_SIMD-1:0] hsel
  );
    logic [CORES_PER_SIMD-1:0][2:0] priorities;
    integer t;
    highest_simd_requested_priority = 0;
    for (t=0; t<CORES_PER_SIMD; t++) begin
      priorities[t] = t;
      if (hsel[t] && priorities[t] > highest_simd_requested_priority) highest_simd_requested_priority = priorities[t];
    end
  endfunction //highest_simd_requested_priority

  function [CORES_PER_SIMD-1:0] requesters_simd;
    input [CORES_PER_SIMD-1:0] hsel;
    input [2:0] priority_select;
    logic [CORES_PER_SIMD-1:0][2:0] priorities;
    integer t;

    for (t=0; t<CORES_PER_SIMD; t++) begin
      priorities      [t] = t;
      requesters_simd [t] = (priorities[t] == priority_select) & hsel[t];
    end
  endfunction //requesters_simd


  function [CORES_PER_SIMD-1:0] nxt_simd_master;
    input [CORES_PER_SIMD-1:0] pending_masters;  //pending masters for the requesed priority level
    input [CORES_PER_SIMD-1:0] last_master;      //last granted master for the priority level
    input [CORES_PER_SIMD-1:0] current_master;   //current granted master (indpendent of priority level)

    integer t, offset;
    logic [CORES_PER_SIMD*2-1:0] sr;

    //default value, don't switch if not needed
    nxt_simd_master = current_master;

    //implement round-robin
    offset = onehot2int_simd(last_master) + 1;

    sr = {pending_masters, pending_masters};
    for (t = 0; t < CORES_PER_SIMD; t++)
      if ( sr[t + offset] ) return (1 << ((t+offset) % CORES_PER_SIMD));
  endfunction

  function integer onehot2int_misd;
    input [CORES_PER_MISD-1:0] onehot;

    for (onehot2int_misd = - 1; |onehot; onehot2int_misd++) onehot = onehot >> 1;
  endfunction //onehot2int_misd


  function [2:0] highest_misd_requested_priority (
    input [CORES_PER_MISD-1:0] hsel
  );
    logic [CORES_PER_MISD-1:0][2:0] priorities;
    integer t;
    highest_misd_requested_priority = 0;
    for (t=0; t<CORES_PER_MISD; t++) begin
      priorities[t] = t;
      if (hsel[t] && priorities[t] > highest_misd_requested_priority) highest_misd_requested_priority = priorities[t];
    end
  endfunction //highest_misd_requested_priority

  function [CORES_PER_MISD-1:0] requesters_misd;
    input [CORES_PER_MISD-1:0] hsel;
    input [2:0] priority_select;
    logic [CORES_PER_MISD-1:0][2:0] priorities;
    integer t;

    for (t=0; t<CORES_PER_MISD; t++) begin
      priorities      [t] = t;
      requesters_misd [t] = (priorities[t] == priority_select) & hsel[t];
    end
  endfunction //requesters_misd

  function [CORES_PER_MISD-1:0] nxt_misd_master;
    input [CORES_PER_MISD-1:0] pending_masters;  //pending masters for the requesed priority level
    input [CORES_PER_MISD-1:0] last_master;      //last granted master for the priority level
    input [CORES_PER_MISD-1:0] current_master;   //current granted master (indpendent of priority level)

    integer t, offset;
    logic [CORES_PER_MISD*2-1:0] sr;

    //default value, don't switch if not needed
    nxt_misd_master = current_master;

    //implement round-robin
    offset = onehot2int_misd(last_master) + 1;

    sr = {pending_masters, pending_masters};
    for (t = 0; t < CORES_PER_MISD; t++)
      if ( sr[t + offset] ) return (1 << ((t+offset) % CORES_PER_MISD));
  endfunction

  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  genvar                      t;

  logic                       HCLK,
                              HRESETn;

  //PMA configuration
  logic [PMA_CNT-1:0][    13:0] pma_cfg;
  logic [PMA_CNT-1:0][PLEN-1:0] pma_adr;

  //AHB instruction - Single Port
  logic                       sins_simd_HSEL;
  logic [PLEN           -1:0] sins_simd_HADDR;
  logic [XLEN           -1:0] sins_simd_HWDATA;
  logic [XLEN           -1:0] sins_simd_HRDATA;
  logic                       sins_simd_HWRITE;
  logic [                2:0] sins_simd_HSIZE;
  logic [                2:0] sins_simd_HBURST;
  logic [                3:0] sins_simd_HPROT;
  logic [                1:0] sins_simd_HTRANS;
  logic                       sins_simd_HMASTLOCK;
  logic                       sins_simd_HREADY;
  logic                       sins_simd_HRESP;

  //AHB data - Single Port
  logic                       sdat_misd_HSEL;
  logic [PLEN           -1:0] sdat_misd_HADDR;
  logic [XLEN           -1:0] sdat_misd_HWDATA;
  logic [XLEN           -1:0] sdat_misd_HRDATA;
  logic                       sdat_misd_HWRITE;
  logic [                2:0] sdat_misd_HSIZE;
  logic [                2:0] sdat_misd_HBURST;
  logic [                3:0] sdat_misd_HPROT;
  logic [                1:0] sdat_misd_HTRANS;
  logic                       sdat_misd_HMASTLOCK;
  logic                       sdat_misd_HREADY;
  logic                       sdat_misd_HRESP;

  //AHB instruction - Multi Port
  logic [CORES_PER_MISD-1:0]                      mins_misd_HSEL;
  logic [CORES_PER_MISD-1:0][PLEN           -1:0] mins_misd_HADDR;
  logic [CORES_PER_MISD-1:0][XLEN           -1:0] mins_misd_HWDATA;
  logic [CORES_PER_MISD-1:0][XLEN           -1:0] mins_misd_HRDATA;
  logic [CORES_PER_MISD-1:0]                      mins_misd_HWRITE;
  logic [CORES_PER_MISD-1:0][                2:0] mins_misd_HSIZE;
  logic [CORES_PER_MISD-1:0][                2:0] mins_misd_HBURST;
  logic [CORES_PER_MISD-1:0][                3:0] mins_misd_HPROT;
  logic [CORES_PER_MISD-1:0][                1:0] mins_misd_HTRANS;
  logic [CORES_PER_MISD-1:0]                      mins_misd_HMASTLOCK;
  logic [CORES_PER_MISD-1:0]                      mins_misd_HREADY;
  logic [CORES_PER_MISD-1:0]                      mins_misd_HRESP;

  logic [CORES_PER_SIMD-1:0]                      mins_simd_HSEL;
  logic [CORES_PER_SIMD-1:0][PLEN           -1:0] mins_simd_HADDR;
  logic [CORES_PER_SIMD-1:0][XLEN           -1:0] mins_simd_HWDATA;
  logic [CORES_PER_SIMD-1:0][XLEN           -1:0] mins_simd_HRDATA;
  logic [CORES_PER_SIMD-1:0]                      mins_simd_HWRITE;
  logic [CORES_PER_SIMD-1:0][                2:0] mins_simd_HSIZE;
  logic [CORES_PER_SIMD-1:0][                2:0] mins_simd_HBURST;
  logic [CORES_PER_SIMD-1:0][                3:0] mins_simd_HPROT;
  logic [CORES_PER_SIMD-1:0][                1:0] mins_simd_HTRANS;
  logic [CORES_PER_SIMD-1:0]                      mins_simd_HMASTLOCK;
  logic [CORES_PER_SIMD-1:0]                      mins_simd_HREADY;
  logic [CORES_PER_SIMD-1:0]                      mins_simd_HRESP;

  //AHB data - Multi Port
  logic [CORES_PER_MISD-1:0]                      mdat_misd_HSEL;
  logic [CORES_PER_MISD-1:0][PLEN           -1:0] mdat_misd_HADDR;
  logic [CORES_PER_MISD-1:0][XLEN           -1:0] mdat_misd_HWDATA;
  logic [CORES_PER_MISD-1:0][XLEN           -1:0] mdat_misd_HRDATA;
  logic [CORES_PER_MISD-1:0]                      mdat_misd_HWRITE;
  logic [CORES_PER_MISD-1:0][                2:0] mdat_misd_HSIZE;
  logic [CORES_PER_MISD-1:0][                2:0] mdat_misd_HBURST;
  logic [CORES_PER_MISD-1:0][                3:0] mdat_misd_HPROT;
  logic [CORES_PER_MISD-1:0][                1:0] mdat_misd_HTRANS;
  logic [CORES_PER_MISD-1:0]                      mdat_misd_HMASTLOCK;
  logic [CORES_PER_MISD-1:0]                      mdat_misd_HREADY;
  logic [CORES_PER_MISD-1:0]                      mdat_misd_HRESP;

  logic [CORES_PER_SIMD-1:0]                      mdat_simd_HSEL;
  logic [CORES_PER_SIMD-1:0][PLEN           -1:0] mdat_simd_HADDR;
  logic [CORES_PER_SIMD-1:0][XLEN           -1:0] mdat_simd_HWDATA;
  logic [CORES_PER_SIMD-1:0][XLEN           -1:0] mdat_simd_HRDATA;
  logic [CORES_PER_SIMD-1:0]                      mdat_simd_HWRITE;
  logic [CORES_PER_SIMD-1:0][                2:0] mdat_simd_HSIZE;
  logic [CORES_PER_SIMD-1:0][                2:0] mdat_simd_HBURST;
  logic [CORES_PER_SIMD-1:0][                3:0] mdat_simd_HPROT;
  logic [CORES_PER_SIMD-1:0][                1:0] mdat_simd_HTRANS;
  logic [CORES_PER_SIMD-1:0]                      mdat_simd_HMASTLOCK;
  logic [CORES_PER_SIMD-1:0]                      mdat_simd_HREADY;
  logic [CORES_PER_SIMD-1:0]                      mdat_simd_HRESP;

  //Data Model Memory
  logic [CORES_PER_TILE-1:0]                      dat_HSEL;
  logic [CORES_PER_TILE-1:0][PLEN           -1:0] dat_HADDR;
  logic [CORES_PER_TILE-1:0][XLEN           -1:0] dat_HWDATA;
  logic [CORES_PER_TILE-1:0][XLEN           -1:0] dat_HRDATA;
  logic [CORES_PER_TILE-1:0]                      dat_HWRITE;
  logic [CORES_PER_TILE-1:0][                2:0] dat_HSIZE;
  logic [CORES_PER_TILE-1:0][                2:0] dat_HBURST;
  logic [CORES_PER_TILE-1:0][                3:0] dat_HPROT;
  logic [CORES_PER_TILE-1:0][                1:0] dat_HTRANS;
  logic [CORES_PER_TILE-1:0]                      dat_HMASTLOCK;
  logic [CORES_PER_TILE-1:0]                      dat_HREADY;
  logic [CORES_PER_TILE-1:0]                      dat_HRESP;

  //Debug Interface
  logic [CORES_PER_TILE-1:0]                      dbg_bp,
                                                  dbg_stall,
                                                  dbg_strb,
                                                  dbg_ack,
                                                  dbg_we;
  logic [CORES_PER_TILE-1:0][PLEN           -1:0] dbg_addr;
  logic [CORES_PER_TILE-1:0][XLEN           -1:0] dbg_dati,
                                                  dbg_dato;

  logic [CORES_PER_MISD-1:0]                      dbg_misd_bp,
                                                  dbg_misd_stall,
                                                  dbg_misd_strb,
                                                  dbg_misd_ack,
                                                  dbg_misd_we;
  logic [CORES_PER_MISD-1:0][PLEN           -1:0] dbg_misd_addr;
  logic [CORES_PER_MISD-1:0][XLEN           -1:0] dbg_misd_dati,
                                                  dbg_misd_dato;

  logic [CORES_PER_SIMD-1:0]                      dbg_simd_bp,
                                                  dbg_simd_stall,
                                                  dbg_simd_strb,
                                                  dbg_simd_ack,
                                                  dbg_simd_we;
  logic [CORES_PER_SIMD-1:0][PLEN           -1:0] dbg_simd_addr;
  logic [CORES_PER_SIMD-1:0][XLEN           -1:0] dbg_simd_dati,
                                                  dbg_simd_dato;

  //Interrupts
  logic [CORES_PER_MISD-1:0]                      ext_misd_nmi;
  logic [CORES_PER_MISD-1:0]                      ext_misd_tint;
  logic [CORES_PER_MISD-1:0]                      ext_misd_sint;
  logic [CORES_PER_MISD-1:0][                3:0] ext_misd_int;

  logic [CORES_PER_SIMD-1:0]                      ext_simd_nmi;
  logic [CORES_PER_SIMD-1:0]                      ext_simd_tint;
  logic [CORES_PER_SIMD-1:0]                      ext_simd_sint;
  logic [CORES_PER_SIMD-1:0][                3:0] ext_simd_int;

  //GPIO
  logic [CORES_PER_MISD-1:0][PDATA_SIZE     -1:0] gpio_misd_i;
  logic [CORES_PER_MISD-1:0][PDATA_SIZE     -1:0] gpio_misd_o;
  logic [CORES_PER_MISD-1:0][PDATA_SIZE     -1:0] gpio_misd_oe;

  logic [CORES_PER_SIMD-1:0][PDATA_SIZE     -1:0] gpio_simd_i;
  logic [CORES_PER_MISD-1:0][PDATA_SIZE     -1:0] gpio_simd_o;
  logic [CORES_PER_MISD-1:0][PDATA_SIZE     -1:0] gpio_simd_oe;

  //Host Interface
  logic                       host_csr_req,
                              host_csr_ack,
                              host_csr_we;
  logic [XLEN           -1:0] host_csr_tohost,
                              host_csr_fromhost;

  // JTAG signals
  logic                    ahb3_misd_tck_i;
  logic                    ahb3_misd_tdi_i;
  logic                    ahb3_misd_tdo_o;

  logic                    ahb3_simd_tck_i;
  logic                    ahb3_simd_tdi_i;
  logic                    ahb3_simd_tdo_o;

  // TAP states
  logic                    ahb3_misd_tlr_i;
  logic                    ahb3_misd_shift_dr_i;
  logic                    ahb3_misd_pause_dr_i;
  logic                    ahb3_misd_update_dr_i;
  logic                    ahb3_misd_capture_dr_i;

  logic                    ahb3_simd_tlr_i;
  logic                    ahb3_simd_shift_dr_i;
  logic                    ahb3_simd_pause_dr_i;
  logic                    ahb3_simd_update_dr_i;
  logic                    ahb3_simd_capture_dr_i;

  // Instructions
  logic                    ahb3_misd_debug_select_i;

  logic                    ahb3_simd_debug_select_i;

  // AHB Master Interface Signals

  logic                    dbg_misd_HSEL;
  logic [ADDR_WIDTH  -1:0] dbg_misd_HADDR;
  logic [DATA_WIDTH  -1:0] dbg_misd_HWDATA;
  logic [DATA_WIDTH  -1:0] dbg_misd_HRDATA;
  logic                    dbg_misd_HWRITE;
  logic [             2:0] dbg_misd_HSIZE;
  logic [             2:0] dbg_misd_HBURST;
  logic [             3:0] dbg_misd_HPROT;
  logic [             1:0] dbg_misd_HTRANS;
  logic                    dbg_misd_HMASTLOCK;
  logic                    dbg_misd_HREADY;
  logic                    dbg_misd_HRESP;

  logic                    dbg_simd_HSEL;
  logic [ADDR_WIDTH  -1:0] dbg_simd_HADDR;
  logic [DATA_WIDTH  -1:0] dbg_simd_HWDATA;
  logic [DATA_WIDTH  -1:0] dbg_simd_HRDATA;
  logic                    dbg_simd_HWRITE;
  logic [             2:0] dbg_simd_HSIZE;
  logic [             2:0] dbg_simd_HBURST;
  logic [             3:0] dbg_simd_HPROT;
  logic [             1:0] dbg_simd_HTRANS;
  logic                    dbg_simd_HMASTLOCK;
  logic                    dbg_simd_HREADY;
  logic                    dbg_simd_HRESP;

  // APB Slave Interface Signals (JTAG Serial Port)
  logic                    PRESETn;
  logic                    PCLK;

  logic                    jsp_misd_PSEL;
  logic                    jsp_misd_PENABLE;
  logic                    jsp_misd_PWRITE;
  logic [             2:0] jsp_misd_PADDR;
  logic [             7:0] jsp_misd_PWDATA;
  logic [             7:0] jsp_misd_PRDATA;
  logic                    jsp_misd_PREADY;
  logic                    jsp_misd_PSLVERR;

  logic                    jsp_simd_PSEL;
  logic                    jsp_simd_PENABLE;
  logic                    jsp_simd_PWRITE;
  logic [             2:0] jsp_simd_PADDR;
  logic [             7:0] jsp_simd_PWDATA;
  logic [             7:0] jsp_simd_PRDATA;
  logic                    jsp_simd_PREADY;
  logic                    jsp_simd_PSLVERR;

  logic                    int_misd_o;

  logic                    int_simd_o;

  // CPU/Thread debug ports
  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][CPU_ADDR_WIDTH-1:0] ahb3_misd_cpu_addr_o;
  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][CPU_DATA_WIDTH-1:0] ahb3_misd_cpu_data_i;
  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][CPU_DATA_WIDTH-1:0] ahb3_misd_cpu_data_o;
  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                     ahb3_misd_cpu_bp_i;
  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                     ahb3_misd_cpu_stall_o;
  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                     ahb3_misd_cpu_stb_o;
  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                     ahb3_misd_cpu_we_o;
  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                     ahb3_misd_cpu_ack_i;

  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][CPU_ADDR_WIDTH-1:0] ahb3_simd_cpu_addr_o;
  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][CPU_DATA_WIDTH-1:0] ahb3_simd_cpu_data_i;
  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][CPU_DATA_WIDTH-1:0] ahb3_simd_cpu_data_o;
  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                     ahb3_simd_cpu_bp_i;
  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                     ahb3_simd_cpu_stall_o;
  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                     ahb3_simd_cpu_stb_o;
  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                     ahb3_simd_cpu_we_o;
  logic [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                     ahb3_simd_cpu_ack_i;

  //Unified memory interface
  logic [1:0][CORES_PER_TILE-1:0][                1:0] mem_htrans;
  logic [1:0][CORES_PER_TILE-1:0][                2:0] mem_hburst;
  logic [1:0][CORES_PER_TILE-1:0]                      mem_hready,
                                                       mem_hresp;
  logic [1:0][CORES_PER_TILE-1:0][PLEN           -1:0] mem_haddr;
  logic [1:0][CORES_PER_TILE-1:0][XLEN           -1:0] mem_hwdata,
                                                       mem_hrdata;
  logic [1:0][CORES_PER_TILE-1:0][                2:0] mem_hsize;
  logic [1:0][CORES_PER_TILE-1:0]                      mem_hwrite;

  //MISD mux
  logic [                2:0] requested_misd_priority_lvl;  //requested priority level
  logic [CORES_PER_MISD -1:0] priority_misd_masters;        //all masters at this priority level

  logic [CORES_PER_MISD -1:0] pending_misd_master,            //next master waiting to be served
                              last_granted_misd_master;       //for requested priority level
  logic [CORES_PER_MISD -1:0] last_granted_misd_masters [3];  //per priority level, for round-robin


  logic [MISD_BITS      -1:0] granted_misd_master_idx     ,    //granted master as index
                              granted_misd_master_idx_dly ;    //deleayed granted master index (for HWDATA)

  logic [CORES_PER_MISD -1:0] granted_misd_master         ;

  //SIMD mux
  logic [                2:0] requested_simd_priority_lvl ;    //requested priority level
  logic [CORES_PER_SIMD -1:0] priority_simd_masters       ;    //all masters at this priority level

  logic [CORES_PER_SIMD -1:0] pending_simd_master         ,    //next master waiting to be served
                              last_granted_simd_master    ;    //for requested priority level
  logic [CORES_PER_SIMD -1:0] last_granted_simd_masters   [3]; //per priority level, for round-robin


  logic [SIMD_BITS      -1:0] granted_simd_master_idx     ,    //granted master as index
                              granted_simd_master_idx_dly ;    //deleayed granted master index (for HWDATA)

  logic [CORES_PER_SIMD -1:0] granted_simd_master         ;

  //NoC Interface
  logic [CHANNELS -1:0][FLIT_WIDTH-1:0] noc_misd_in_flit;
  logic [CHANNELS -1:0]                 noc_misd_in_last;
  logic [CHANNELS -1:0]                 noc_misd_in_valid;
  logic [CHANNELS -1:0]                 noc_misd_in_ready;
  logic [CHANNELS -1:0][FLIT_WIDTH-1:0] noc_misd_out_flit;
  logic [CHANNELS -1:0]                 noc_misd_out_last;
  logic [CHANNELS -1:0]                 noc_misd_out_valid;
  logic [CHANNELS -1:0]                 noc_misd_out_ready;

  logic [CHANNELS -1:0][FLIT_WIDTH-1:0] noc_simd_in_flit;
  logic [CHANNELS -1:0]                 noc_simd_in_last;
  logic [CHANNELS -1:0]                 noc_simd_in_valid;
  logic [CHANNELS -1:0]                 noc_simd_in_ready;
  logic [CHANNELS -1:0][FLIT_WIDTH-1:0] noc_simd_out_flit;
  logic [CHANNELS -1:0]                 noc_simd_out_last;
  logic [CHANNELS -1:0]                 noc_simd_out_valid;
  logic [CHANNELS -1:0]                 noc_simd_out_ready;

  ////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  //Define PMA regions

  //crt.0 (ROM) region
  assign pma_adr[0] = TOHOST >> 2;
  assign pma_cfg[0] = {`MEM_TYPE_MAIN, 8'b1111_1000, `AMO_TYPE_NONE, `TOR};

  //TOHOST region
  assign pma_adr[1] = ((TOHOST >> 2) & ~'hf) | 'h7;
  assign pma_cfg[1] = {`MEM_TYPE_IO,   8'b0100_0000, `AMO_TYPE_NONE, `NAPOT};

  //UART-Tx region
  assign pma_adr[2] = UART_TX >> 2;
  assign pma_cfg[2] = {`MEM_TYPE_IO,   8'b0100_0000, `AMO_TYPE_NONE, `NA4};

  //RAM region
  assign pma_adr[3] = 1 << 31;
  assign pma_cfg[3] = {`MEM_TYPE_MAIN, 8'b1111_0000, `AMO_TYPE_NONE, `TOR};

  //Interrupts
  assign gpio_misd_i  = 'b0;
  assign gpio_simd_i  = 'b0;

  //GPIO inputs
  generate
    for (t=0; t < CORES_PER_MISD; t++) begin
      assign ext_misd_nmi  [t] = 1'b0;
      assign ext_misd_tint [t] = 1'b0;
      assign ext_misd_sint [t] = 1'b0;
      assign ext_misd_int  [t] = 1'b0;
    end

    for (t=0; t < CORES_PER_SIMD; t++) begin
      assign ext_simd_nmi  [t] = 1'b0;
      assign ext_simd_tint [t] = 1'b0;
      assign ext_simd_sint [t] = 1'b0;
      assign ext_simd_int  [t] = 1'b0;
    end
  endgenerate

  //Hookup Device Under Test
  riscv_soc #(
    .XLEN             ( XLEN             ),
    .PLEN             ( PLEN             ), //31bit address bus
    .PC_INIT          ( PC_INIT          ),
    .HAS_USER         ( HAS_U            ),
    .HAS_SUPER        ( HAS_S            ),
    .HAS_HYPER        ( HAS_H            ),
    .HAS_RVA          ( HAS_RVA          ),
    .HAS_RVM          ( HAS_RVM          ),
    .MULT_LATENCY     ( MULLAT           ),

    .PMA_CNT          ( PMA_CNT          ),
    .ICACHE_SIZE      ( ICACHE_SIZE      ),
    .ICACHE_WAYS      ( 1                ),
    .DCACHE_SIZE      ( DCACHE_SIZE      ),
    .DTCM_SIZE        ( 0                ),
    .WRITEBUFFER_SIZE ( WRITEBUFFER_SIZE ),

    .MTVEC_DEFAULT    ( 32'h80000004     ),

    .CORES_PER_SIMD   ( CORES_PER_SIMD   ),
    .CORES_PER_MISD   ( CORES_PER_MISD   ),

    .CHANNELS         ( CHANNELS         )
  )
  dut (
    .HRESETn   ( HRESETn ),
    .HCLK      ( HCLK    ),

    .pma_cfg_i ( pma_cfg ),
    .pma_adr_i ( pma_adr ),

    .*
  );

  //Hookup Debug Unit
  riscv_dbg_bfm #(
    .XLEN ( XLEN ),
    .PLEN ( PLEN ),

    .CORES_PER_TILE ( CORES_PER_TILE )
  )
  dbg_ctrl (
    .rstn ( HRESETn ),
    .clk  ( HCLK    ),

    .cpu_bp_i    ( dbg_bp    ),
    .cpu_stall_o ( dbg_stall ),
    .cpu_stb_o   ( dbg_strb  ),
    .cpu_we_o    ( dbg_we    ),
    .cpu_adr_o   ( dbg_addr  ),
    .cpu_dat_o   ( dbg_dati  ),
    .cpu_dat_i   ( dbg_dato  ),
    .cpu_ack_i   ( dbg_ack   )
  );

  //DBG MISD AHB3
  mpsoc_dbg_top_ahb3 #(
    .X              ( X              ),
    .Y              ( Y              ),
    .Z              ( Z              ),
    .CORES_PER_TILE ( CORES_PER_MISD ),
    .ADDR_WIDTH     ( 32             ),
    .DATA_WIDTH     ( 32             ),
    .CPU_ADDR_WIDTH ( 32             ),
    .CPU_DATA_WIDTH ( 32             ),
    .DATAREG_LEN    ( DATAREG_LEN    )
  )
  top_misd_ahb3 (
    // JTAG signals
    .tck_i ( ahb3_misd_tck_i ),
    .tdi_i ( ahb3_misd_tdi_i ),
    .tdo_o ( ahb3_misd_tdo_i ),

    // TAP states
    .tlr_i        ( ahb3_misd_tlr_i        ),
    .shift_dr_i   ( ahb3_misd_shift_dr_i   ),
    .pause_dr_i   ( ahb3_misd_pause_dr_i   ),
    .update_dr_i  ( ahb3_misd_update_dr_i  ),
    .capture_dr_i ( ahb3_misd_capture_dr_i ),

    // Instructions
    .debug_select_i ( ahb3_misd_debug_select_i ),

    // AHB Master Interface Signals
    .HCLK          ( HCLK               ),
    .HRESETn       ( HRESETn            ),
    .dbg_HSEL      ( dbg_misd_HSEL      ),
    .dbg_HADDR     ( dbg_misd_HADDR     ),
    .dbg_HWDATA    ( dbg_misd_HWDATA    ),
    .dbg_HRDATA    ( dbg_misd_HRDATA    ),
    .dbg_HWRITE    ( dbg_misd_HWRITE    ),
    .dbg_HSIZE     ( dbg_misd_HSIZE     ),
    .dbg_HBURST    ( dbg_misd_HBURST    ),
    .dbg_HPROT     ( dbg_misd_HPROT     ),
    .dbg_HTRANS    ( dbg_misd_HTRANS    ),
    .dbg_HMASTLOCK ( dbg_misd_HMASTLOCK ),
    .dbg_HREADY    ( dbg_misd_HREADY    ),
    .dbg_HRESP     ( dbg_misd_HRESP     ),

    // APB Slave Interface Signals (JTAG Serial Port)
    .PRESETn     ( PRESETn          ),
    .PCLK        ( PCLK             ),
    .jsp_PSEL    ( jsp_misd_PSEL    ),
    .jsp_PENABLE ( jsp_misd_PENABLE ),
    .jsp_PWRITE  ( jsp_misd_PWRITE  ),
    .jsp_PADDR   ( jsp_misd_PADDR   ),
    .jsp_PWDATA  ( jsp_misd_PWDATA  ),
    .jsp_PRDATA  ( jsp_misd_PRDATA  ),
    .jsp_PREADY  ( jsp_misd_PREADY  ),
    .jsp_PSLVERR ( jsp_misd_PSLVERR ),

    .int_o ( int_misd_o ),

    //CPU/Thread debug ports
    .cpu_clk_i   ( ahb3_misd_cpu_clk_i   ),
    .cpu_rstn_i  ( ahb3_misd_cpu_rstn_i  ),
    .cpu_addr_o  ( ahb3_misd_cpu_addr_o  ),
    .cpu_data_i  ( ahb3_misd_cpu_data_i  ),
    .cpu_data_o  ( ahb3_misd_cpu_data_o  ),
    .cpu_bp_i    ( ahb3_misd_cpu_bp_i    ),
    .cpu_stall_o ( ahb3_misd_cpu_stall_o ),
    .cpu_stb_o   ( ahb3_misd_cpu_stb_o   ),
    .cpu_we_o    ( ahb3_misd_cpu_we_o    ),
    .cpu_ack_i   ( ahb3_misd_cpu_ack_i   )
  );

  //DBG SIMD AHB3
  mpsoc_dbg_top_ahb3 #(
    .X              ( X              ),
    .Y              ( Y              ),
    .Z              ( Z              ),
    .CORES_PER_TILE ( CORES_PER_SIMD ),
    .ADDR_WIDTH     ( 32             ),
    .DATA_WIDTH     ( 32             ),
    .CPU_ADDR_WIDTH ( 32             ),
    .CPU_DATA_WIDTH ( 32             ),
    .DATAREG_LEN    ( DATAREG_LEN    )
  )
  top_simd_ahb3 (
    // JTAG signals
    .tck_i ( ahb3_simd_tck_i ),
    .tdi_i ( ahb3_simd_tdi_i ),
    .tdo_o ( ahb3_simd_tdo_i ),

    // TAP states
    .tlr_i        ( ahb3_simd_tlr_i        ),
    .shift_dr_i   ( ahb3_simd_shift_dr_i   ),
    .pause_dr_i   ( ahb3_simd_pause_dr_i   ),
    .update_dr_i  ( ahb3_simd_update_dr_i  ),
    .capture_dr_i ( ahb3_simd_capture_dr_i ),

    // Instructions
    .debug_select_i ( ahb3_simd_debug_select_i ),

    // AHB Master Interface Signals
    .HCLK          ( HCLK               ),
    .HRESETn       ( HRESETn            ),
    .dbg_HSEL      ( dbg_simd_HSEL      ),
    .dbg_HADDR     ( dbg_simd_HADDR     ),
    .dbg_HWDATA    ( dbg_simd_HWDATA    ),
    .dbg_HRDATA    ( dbg_simd_HRDATA    ),
    .dbg_HWRITE    ( dbg_simd_HWRITE    ),
    .dbg_HSIZE     ( dbg_simd_HSIZE     ),
    .dbg_HBURST    ( dbg_simd_HBURST    ),
    .dbg_HPROT     ( dbg_simd_HPROT     ),
    .dbg_HTRANS    ( dbg_simd_HTRANS    ),
    .dbg_HMASTLOCK ( dbg_simd_HMASTLOCK ),
    .dbg_HREADY    ( dbg_simd_HREADY    ),
    .dbg_HRESP     ( dbg_simd_HRESP     ),

    // APB Slave Interface Signals (JTAG Serial Port)
    .PRESETn     ( PRESETn          ),
    .PCLK        ( PCLK             ),
    .jsp_PSEL    ( jsp_simd_PSEL    ),
    .jsp_PENABLE ( jsp_simd_PENABLE ),
    .jsp_PWRITE  ( jsp_simd_PWRITE  ),
    .jsp_PADDR   ( jsp_simd_PADDR   ),
    .jsp_PWDATA  ( jsp_simd_PWDATA  ),
    .jsp_PRDATA  ( jsp_simd_PRDATA  ),
    .jsp_PREADY  ( jsp_simd_PREADY  ),
    .jsp_PSLVERR ( jsp_simd_PSLVERR ),

    .int_o ( int_simd_o ),

    //CPU/Thread debug ports
    .cpu_clk_i   ( ahb3_simd_cpu_clk_i   ),
    .cpu_rstn_i  ( ahb3_simd_cpu_rstn_i  ),
    .cpu_addr_o  ( ahb3_simd_cpu_addr_o  ),
    .cpu_data_i  ( ahb3_simd_cpu_data_i  ),
    .cpu_data_o  ( ahb3_simd_cpu_data_o  ),
    .cpu_bp_i    ( ahb3_simd_cpu_bp_i    ),
    .cpu_stall_o ( ahb3_simd_cpu_stall_o ),
    .cpu_stb_o   ( ahb3_simd_cpu_stb_o   ),
    .cpu_we_o    ( ahb3_simd_cpu_we_o    ),
    .cpu_ack_i   ( ahb3_simd_cpu_ack_i   )
  );

  generate
    for (t=0; t < CORES_PER_MISD; t++) begin
      assign dbg_bp    [t] = dbg_misd_bp    [t];
      assign dbg_dato  [t] = dbg_misd_dato  [t];
      assign dbg_ack   [t] = dbg_misd_ack   [t];

      assign dbg_misd_stall [t] = dbg_stall [t];
      assign dbg_misd_strb  [t] = dbg_strb  [t];
      assign dbg_misd_we    [t] = dbg_we    [t];
      assign dbg_misd_addr  [t] = dbg_addr  [t];
      assign dbg_misd_dati  [t] = dbg_dati  [t];
    end

    for (t=0; t < CORES_PER_SIMD; t++) begin
      assign dbg_bp    [t+CORES_PER_MISD] = dbg_simd_bp    [t];
      assign dbg_dato  [t+CORES_PER_MISD] = dbg_simd_dato  [t];
      assign dbg_ack   [t+CORES_PER_MISD] = dbg_simd_ack   [t];

      assign dbg_simd_stall [t+CORES_PER_MISD] = dbg_stall [t];
      assign dbg_simd_strb  [t+CORES_PER_MISD] = dbg_strb  [t];
      assign dbg_simd_we    [t+CORES_PER_MISD] = dbg_we    [t];
      assign dbg_simd_addr  [t+CORES_PER_MISD] = dbg_addr  [t];
      assign dbg_simd_dati  [t+CORES_PER_MISD] = dbg_dati  [t];
    end
  endgenerate

  //bus MISD <-> memory model connections
  generate
    for (t=0; t < CORES_PER_MISD; t++) begin
      assign mem_htrans [0][t] = mins_misd_HTRANS [t];
      assign mem_hburst [0][t] = mins_misd_HBURST [t];
      assign mem_haddr  [0][t] = mins_misd_HADDR  [t];
      assign mem_hwrite [0][t] = mins_misd_HWRITE [t];
      assign mem_hsize  [0][t] = 'b0;
      assign mem_hwdata [0][t] = 'b0;

      assign mem_htrans [1][t] = mdat_misd_HTRANS [t];
      assign mem_hburst [1][t] = mdat_misd_HBURST [t];
      assign mem_haddr  [1][t] = mdat_misd_HADDR  [t];
      assign mem_hwrite [1][t] = mdat_misd_HWRITE [t];
      assign mem_hsize  [1][t] = mdat_misd_HSIZE  [t];
      assign mem_hwdata [1][t] = mdat_misd_HWDATA [t];
    end
  endgenerate

  generate
    for (t=0; t < CORES_PER_MISD; t++) begin
      assign mins_misd_HRDATA [t] = mem_hrdata [0][t];
      assign mins_misd_HREADY [t] = mem_hready [0][t];
      assign mins_misd_HRESP  [t] = mem_hresp  [0][t];

      assign mdat_misd_HRDATA [t] = mem_hrdata [1][t];
      assign mdat_misd_HREADY [t] = mem_hready [1][t];
      assign mdat_misd_HRESP  [t] = mem_hresp  [1][t];
    end
  endgenerate

  //bus SIMD <-> memory model connections
  generate
    for (t=0; t < CORES_PER_SIMD; t++) begin
      assign mem_htrans [0][t+CORES_PER_MISD] = mins_simd_HTRANS [t];
      assign mem_hburst [0][t+CORES_PER_MISD] = mins_simd_HBURST [t];
      assign mem_haddr  [0][t+CORES_PER_MISD] = mins_simd_HADDR  [t];
      assign mem_hwrite [0][t+CORES_PER_MISD] = mins_simd_HWRITE [t];
      assign mem_hsize  [0][t+CORES_PER_MISD] = 'b0;
      assign mem_hwdata [0][t+CORES_PER_MISD] = 'b0;

      assign mem_htrans [1][t+CORES_PER_MISD] = mdat_simd_HTRANS [t];
      assign mem_hburst [1][t+CORES_PER_MISD] = mdat_simd_HBURST [t];
      assign mem_haddr  [1][t+CORES_PER_MISD] = mdat_simd_HADDR  [t];
      assign mem_hwrite [1][t+CORES_PER_MISD] = mdat_simd_HWRITE [t];
      assign mem_hsize  [1][t+CORES_PER_MISD] = mdat_simd_HSIZE  [t];
      assign mem_hwdata [1][t+CORES_PER_MISD] = mdat_simd_HWDATA [t];
    end
  endgenerate

  generate
    for (t=0; t < CORES_PER_SIMD; t++) begin
      assign mins_simd_HRDATA [t] = mem_hrdata [0][t+CORES_PER_MISD];
      assign mins_simd_HREADY [t] = mem_hready [0][t+CORES_PER_MISD];
      assign mins_simd_HRESP  [t] = mem_hresp  [0][t+CORES_PER_MISD];

      assign mdat_simd_HRDATA [t] = mem_hrdata [1][t+CORES_PER_MISD];
      assign mdat_simd_HREADY [t] = mem_hready [1][t+CORES_PER_MISD];
      assign mdat_simd_HRESP  [t] = mem_hresp  [1][t+CORES_PER_MISD];
    end
  endgenerate

  //Data Model Memory
  generate
    for (t=0; t < CORES_PER_MISD; t++) begin
      assign dat_HSEL      [t] = mdat_misd_HSEL      [t];
      assign dat_HADDR     [t] = mdat_misd_HADDR     [t];
      assign dat_HWDATA    [t] = mdat_misd_HWDATA    [t];
      assign dat_HRDATA    [t] = mdat_misd_HRDATA    [t];
      assign dat_HWRITE    [t] = mdat_misd_HWRITE    [t];
      assign dat_HSIZE     [t] = mdat_misd_HSIZE     [t];
      assign dat_HBURST    [t] = mdat_misd_HBURST    [t];
      assign dat_HPROT     [t] = mdat_misd_HPROT     [t];
      assign dat_HTRANS    [t] = mdat_misd_HTRANS    [t];
      assign dat_HMASTLOCK [t] = mdat_misd_HMASTLOCK [t];
      assign dat_HREADY    [t] = mdat_misd_HREADY    [t];
      assign dat_HRESP     [t] = mdat_misd_HRESP     [t];
    end

    for (t=0; t < CORES_PER_SIMD; t++) begin
      assign dat_HSEL      [t+CORES_PER_MISD] = mdat_simd_HSEL      [t];
      assign dat_HADDR     [t+CORES_PER_MISD] = mdat_simd_HADDR     [t];
      assign dat_HWDATA    [t+CORES_PER_MISD] = mdat_simd_HWDATA    [t];
      assign dat_HRDATA    [t+CORES_PER_MISD] = mdat_simd_HRDATA    [t];
      assign dat_HWRITE    [t+CORES_PER_MISD] = mdat_simd_HWRITE    [t];
      assign dat_HSIZE     [t+CORES_PER_MISD] = mdat_simd_HSIZE     [t];
      assign dat_HBURST    [t+CORES_PER_MISD] = mdat_simd_HBURST    [t];
      assign dat_HPROT     [t+CORES_PER_MISD] = mdat_simd_HPROT     [t];
      assign dat_HTRANS    [t+CORES_PER_MISD] = mdat_simd_HTRANS    [t];
      assign dat_HMASTLOCK [t+CORES_PER_MISD] = mdat_simd_HMASTLOCK [t];
      assign dat_HREADY    [t+CORES_PER_MISD] = mdat_simd_HREADY    [t];
      assign dat_HRESP     [t+CORES_PER_MISD] = mdat_simd_HRESP     [t];
    end
  endgenerate

  //bus MISD <-> mux
  generate
    for (t=0; t < CORES_PER_MISD; t++) begin
      assign mdat_misd_HSEL      [t] = sdat_misd_HSEL      ;
      assign mdat_misd_HADDR     [t] = sdat_misd_HADDR     ;
      assign mdat_misd_HWDATA    [t] = sdat_misd_HWDATA    ;
      assign mdat_misd_HWRITE    [t] = sdat_misd_HWRITE    ;
      assign mdat_misd_HSIZE     [t] = sdat_misd_HSIZE     ;
      assign mdat_misd_HBURST    [t] = sdat_misd_HBURST    ;
      assign mdat_misd_HPROT     [t] = sdat_misd_HPROT     ;
      assign mdat_misd_HTRANS    [t] = sdat_misd_HTRANS    ;
      assign mdat_misd_HMASTLOCK [t] = sdat_misd_HMASTLOCK ;
    end
  endgenerate

  assign sdat_misd_HRDATA  = mdat_misd_HRDATA [granted_simd_master_idx];
  assign sdat_misd_HREADY  = mdat_misd_HREADY [granted_simd_master_idx];
  assign sdat_misd_HRESP   = mdat_misd_HRESP  [granted_simd_master_idx];

  //get highest priority from selected masters
  assign requested_misd_priority_lvl = highest_misd_requested_priority(mdat_misd_HSEL);

  //get pending masters for the highest priority requested
  assign priority_misd_masters = requesters_misd(mdat_misd_HSEL, requested_misd_priority_lvl);

  //get last granted master for the priority requested
  assign last_granted_misd_master = last_granted_misd_masters[requested_misd_priority_lvl];

  //get next master to serve
  assign pending_misd_master = nxt_misd_master(priority_misd_masters, last_granted_misd_master, granted_misd_master);

  //select new master
  always @(posedge HCLK, negedge HRESETn) begin
    if      ( !HRESETn                 ) granted_misd_master <= 'h1;
    else if ( !sdat_misd_HSEL ) granted_misd_master <= pending_misd_master;
  end

  //store current master (for this priority level)
  always @(posedge HCLK, negedge HRESETn) begin
    if      ( !HRESETn                 ) last_granted_misd_masters[requested_misd_priority_lvl] <= 'h1;
    else if ( !sdat_misd_HSEL ) last_granted_misd_masters[requested_misd_priority_lvl] <= pending_misd_master;
  end

  //get signals from current requester
  always @(posedge HCLK, negedge HRESETn) begin
    if      ( !HRESETn                 ) granted_misd_master_idx <= 'h0;
    else if ( !sdat_misd_HSEL ) granted_misd_master_idx <= onehot2int_misd(pending_misd_master);
  end

  //bus SIMD <-> mux
  generate
    for (t=0; t < CORES_PER_SIMD; t++) begin
      assign mins_simd_HSEL      [t] = sins_simd_HSEL      ;
      assign mins_simd_HADDR     [t] = sins_simd_HADDR     ;
      assign mins_simd_HWDATA    [t] = sins_simd_HWDATA    ;
      assign mins_simd_HWRITE    [t] = sins_simd_HWRITE    ;
      assign mins_simd_HSIZE     [t] = sins_simd_HSIZE     ;
      assign mins_simd_HBURST    [t] = sins_simd_HBURST    ;
      assign mins_simd_HPROT     [t] = sins_simd_HPROT     ;
      assign mins_simd_HTRANS    [t] = sins_simd_HTRANS    ;
      assign mins_simd_HMASTLOCK [t] = sins_simd_HMASTLOCK ;
    end
  endgenerate

  assign sins_simd_HRDATA  = mins_simd_HRDATA [granted_simd_master_idx];
  assign sins_simd_HREADY  = mins_simd_HREADY [granted_simd_master_idx];
  assign sins_simd_HRESP   = mins_simd_HRESP  [granted_simd_master_idx];

  //get highest priority from selected masters
  assign requested_simd_priority_lvl = highest_simd_requested_priority(mins_simd_HSEL);

  //get pending masters for the highest priority requested
  assign priority_simd_masters = requesters_simd(mins_simd_HSEL, requested_simd_priority_lvl);

  //get last granted master for the priority requested
  assign last_granted_simd_master = last_granted_simd_masters[requested_simd_priority_lvl];

  //get next master to serve
  assign pending_simd_master = nxt_simd_master(priority_simd_masters, last_granted_simd_master, granted_simd_master);

  //select new master
  always @(posedge HCLK, negedge HRESETn) begin
    if      ( !HRESETn                 ) granted_simd_master <= 'h1;
    else if ( !sins_simd_HSEL ) granted_simd_master <= pending_simd_master;
  end

  //store current master (for this priority level)
  always @(posedge HCLK, negedge HRESETn) begin
    if      ( !HRESETn                 ) last_granted_simd_masters[requested_simd_priority_lvl] <= 'h1;
    else if ( !sins_simd_HSEL ) last_granted_simd_masters[requested_simd_priority_lvl] <= pending_simd_master;
  end

  //get signals from current requester
  always @(posedge HCLK, negedge HRESETn) begin
    if      ( !HRESETn                 ) granted_simd_master_idx <= 'h0;
    else if ( !sins_simd_HSEL ) granted_simd_master_idx <= onehot2int_simd(pending_simd_master);
  end

  //hookup memory model
  riscv_memory_model #(
    .XLEN ( XLEN ),
    .PLEN ( PLEN ),

    .BASE ( BASE ),

    .MEM_LATENCY ( MEM_LATENCY ),

    .LATENCY ( 1 ),
    .BURST   ( 8 ),

    .INIT_FILE ( INIT_FILE ),

    .CORES_PER_TILE ( CORES_PER_TILE )
  )
  unified_memory (
    .HRESETn ( HRESETn   ),
    .HCLK   ( HCLK       ),
    .HTRANS ( mem_htrans ),
    .HREADY ( mem_hready ),
    .HRESP  ( mem_hresp  ),
    .HADDR  ( mem_haddr  ),
    .HWRITE ( mem_hwrite ),
    .HSIZE  ( mem_hsize  ),
    .HBURST ( mem_hburst ),
    .HWDATA ( mem_hwdata ),
    .HRDATA ( mem_hrdata )
  );

  //Front-End Server
  generate
    if (HTIF) begin
      //Old HTIF interface
      riscv_htif #(XLEN)
      htif_frontend (
        .rstn              ( HRESETn           ),
        .clk               ( HCLK              ),
        .host_csr_req      ( host_csr_req      ),
        .host_csr_ack      ( host_csr_ack      ),
        .host_csr_we       ( host_csr_we       ),
        .host_csr_tohost   ( host_csr_tohost   ),
        .host_csr_fromhost ( host_csr_fromhost )
      );
    end
    else begin
      //New MMIO interface
      riscv_mmio_if #(
        XLEN, PLEN, TOHOST, UART_TX, CORES_PER_TILE
      )
      mmio_if (
        .HRESETn   ( HRESETn    ),
        .HCLK      ( HCLK       ),
        .HTRANS    ( dat_HTRANS ),
        .HWRITE    ( dat_HWRITE ),
        .HSIZE     ( dat_HSIZE  ),
        .HBURST    ( dat_HBURST ),
        .HADDR     ( dat_HADDR  ),
        .HWDATA    ( dat_HWDATA ),
        .HRDATA    (            ),
        .HREADYOUT (            ),
        .HRESP     (            )
      );
    end
  endgenerate

  //Generate clock
  always #1 HCLK = ~HCLK;

  initial begin
    $display("\n");
    $display ("                                                                                                         ");
    $display ("                                                                                                         ");
    $display ("                                                              ***                     ***          **    ");
    $display ("                                                            ** ***    *                ***          **   ");
    $display ("                                                           **   ***  ***                **          **   ");
    $display ("                                                           **         *                 **          **   ");
    $display ("    ****    **   ****                                      **                           **          **   ");
    $display ("   * ***  *  **    ***  *    ***       ***    ***  ****    ******   ***        ***      **      *** **   ");
    $display ("  *   ****   **     ****    * ***     * ***    **** **** * *****     ***      * ***     **     ********* ");
    $display (" **    **    **      **    *   ***   *   ***    **   ****  **         **     *   ***    **    **   ****  ");
    $display (" **    **    **      **   **    *** **    ***   **    **   **         **    **    ***   **    **    **   ");
    $display (" **    **    **      **   ********  ********    **    **   **         **    ********    **    **    **   ");
    $display (" **    **    **      **   *******   *******     **    **   **         **    *******     **    **    **   ");
    $display (" **    **    **      **   **        **          **    **   **         **    **          **    **    **   ");
    $display ("  *******     ******* **  ****    * ****    *   **    **   **         **    ****    *   **    **    **   ");
    $display ("   ******      *****   **  *******   *******    ***   ***  **         *** *  *******    *** *  *****     ");
    $display ("       **                   *****     *****      ***   ***  **         ***    *****      ***    ***      ");
    $display ("       **                                                                                                ");
    $display ("       **                                                                                                ");
    $display ("        **                                                                                               ");
    $display ("- RISC-V Regression TestBench ---------------------------------------------------------------------------");
    $display ("  XLEN | PRIV | MMU | FPU | RVA | RVM | MULLAT");
    $display ("  %4d | M%C%C%C | %3d | %3d | %3d | %3d | %6d", 
              XLEN, HAS_H > 0 ? "H" : " ", HAS_S > 0 ? "S" : " ", HAS_U > 0 ? "U" : " ",
              HAS_MMU, HAS_FPU, HAS_RVA, HAS_RVM, MULLAT);
    $display ("------------------------------------------------------------------------------");
    $display ("  CORES | NODES | X | Y | Z | CORES_PER_TILE | CORES_PER_MISD | CORES_PER_SIMD");
    $display ("  %5d | %5d | %1d | %1d | %1d | %14d | %14d | %14d   ", 
              CORES, NODES, X, Y, Z, CORES_PER_TILE, CORES_PER_MISD, CORES_PER_SIMD);
    $display ("------------------------------------------------------------------------------");
    $display ("  Test   = %s", INIT_FILE);
    $display ("  ICache = %0dkB", ICACHE_SIZE);
    $display ("  DCache = %0dkB", DCACHE_SIZE);
    $display ("------------------------------------------------------------------------------");
  end

  generate
    for (t=0; t < CORES_PER_TILE; t++) begin
      initial begin

        `ifdef WAVES
        $shm_open("waves");
        $shm_probe("AS",riscv_testbench,"AS");
        $display("INFO: Signal dump enabled ...\n");
        `endif

        //unified_memory.read_elf2hex(INIT_FILE);
        unified_memory.read_ihex(INIT_FILE);
        //unified_memory.dump;

        HCLK  = 'b0;

        HRESETn = 'b1;
        repeat (5) @(negedge HCLK);
        HRESETn = 'b0;
        repeat (5) @(negedge HCLK);
        HRESETn = 'b1;

        #112;
        //stall CPU
        dbg_ctrl.stall;

        //Enable BREAKPOINT to call external debugger
        //dbg_ctrl.write('h0004,'h0008);

        //Enable Single Stepping
        dbg_ctrl.write('h0000,'h0001);

        //single step through 10 instructions
        repeat (100) begin
          while (!dbg_ctrl.stall_cpu[t]) @(posedge HCLK);
          repeat(15) @(posedge HCLK);
          dbg_ctrl.write('h0001,'h0000); //clear single-step-hit
          dbg_ctrl.unstall;
        end

        //last time ...
        @(posedge HCLK);
        while (!dbg_ctrl.stall_cpu[t]) @(posedge HCLK);
        //disable Single Stepping
        dbg_ctrl.write('h0000,'h0000);
        dbg_ctrl.write('h0001,'h0000);
        dbg_ctrl.unstall;
      end
    end
  endgenerate
endmodule

//MMIO Interface
module riscv_mmio_if #(
  parameter HDATA_SIZE    = 32,
  parameter HADDR_SIZE    = 32,
  parameter CATCH_TEST    = 80001000,
  parameter CATCH_UART_TX = 80001080,
  parameter X             = 8,
  parameter Y             = 8,
  parameter Z             = 8,
  parameter PORTS         = 8
)
  (
    input                                  HRESETn,
    input                                  HCLK,

    input      [PORTS-1:0][           1:0] HTRANS,
    input      [PORTS-1:0][HADDR_SIZE-1:0] HADDR,
    input      [PORTS-1:0]                 HWRITE,
    input      [PORTS-1:0][           2:0] HSIZE,
    input      [PORTS-1:0][           2:0] HBURST,
    input      [PORTS-1:0][HDATA_SIZE-1:0] HWDATA,
    output reg [PORTS-1:0][HDATA_SIZE-1:0] HRDATA,

    output reg [PORTS-1:0]                 HREADYOUT,
    output     [PORTS-1:0]                 HRESP
  );

  // Variables
  logic [PORTS-1:0][HDATA_SIZE-1:0] data_reg;
  logic [PORTS-1:0]                 catch_test,
                                    catch_uart_tx;

  logic [PORTS-1:0][           1:0] dHTRANS;
  logic [PORTS-1:0][HADDR_SIZE-1:0] dHADDR;
  logic [PORTS-1:0]                 dHWRITE;

  // Functions
  function string hostcode_to_string;
    input integer hostcode;

    case (hostcode)
      1337: hostcode_to_string = "OTHER EXCEPTION";
    endcase
  endfunction

  // Module body
  genvar p;
  //Generate watchdog counter
  integer watchdog_cnt;
  always @(posedge HCLK,negedge HRESETn) begin
    if (!HRESETn) watchdog_cnt <= 0;
    else          watchdog_cnt <= watchdog_cnt + 1;
  end

  generate
    for (p=0; p < PORTS; p++) begin
      //Catch write to host address
      assign HRESP[p] = `HRESP_OKAY;

      always @(posedge HCLK) begin
        dHTRANS <= HTRANS;
        dHADDR  <= HADDR;
        dHWRITE <= HWRITE;
      end

      always @(posedge HCLK,negedge HRESETn) begin
        if (!HRESETn) begin
          HREADYOUT[p] <= 1'b1;
        end
        else if (HTRANS[p] == `HTRANS_IDLE) begin
        end
      end

      always @(posedge HCLK,negedge HRESETn) begin
        if (!HRESETn) begin
          catch_test    [p] <= 1'b0;
          catch_uart_tx [p] <= 1'b0;
        end
        else begin
          catch_test    [p] <= dHTRANS[p] == `HTRANS_NONSEQ && dHWRITE[p] && dHADDR[p] == CATCH_TEST;
          catch_uart_tx [p] <= dHTRANS[p] == `HTRANS_NONSEQ && dHWRITE[p] && dHADDR[p] == CATCH_UART_TX;
          data_reg      [p] <= HWDATA [p];
        end
      end
      //Generate output

      //Simulated UART Tx (prints characters on screen)
      always @(posedge HCLK) begin
        if (catch_uart_tx[p]) $write ("%0c", data_reg[p]);
      end
      //Tests ...
      always @(posedge HCLK) begin
        if (watchdog_cnt > 1000_000 || catch_test[p]) begin
          $display("\n");
          $display("-------------------------------------------------------------");
          $display("* RISC-V test bench finished");
          if (data_reg[p][0] == 1'b1) begin
            if (~|data_reg[p][HDATA_SIZE-1:1])
              $display("* PASSED %0d", data_reg[p]);
            else
              $display ("* FAILED: code: 0x%h (%0d: %s)", data_reg[p] >> 1, data_reg[p] >> 1, hostcode_to_string(data_reg[p] >> 1) );
          end
          else
            $display ("* FAILED: watchdog count reached (%0d) @%0t", watchdog_cnt, $time);
          $display("-------------------------------------------------------------");
          $display("\n");

          $finish();
        end
      end
    end
  endgenerate
endmodule

//HTIF Interface
module riscv_htif #(
  parameter XLEN=32
)
  (
    input             rstn,
    input             clk,

    output            host_csr_req,
    input             host_csr_ack,
    output            host_csr_we,
    input  [XLEN-1:0] host_csr_tohost,
    output [XLEN-1:0] host_csr_fromhost
  );
  function string hostcode_to_string;
    input integer hostcode;

    case (hostcode)
      1337: hostcode_to_string = "OTHER EXCEPTION";
    endcase
  endfunction

  //Generate watchdog counter
  integer watchdog_cnt;
  always @(posedge clk,negedge rstn) begin
    if (!rstn) watchdog_cnt <= 0;
    else       watchdog_cnt <= watchdog_cnt + 1;
  end

  always @(posedge clk) begin
    if (watchdog_cnt > 200_000 || host_csr_tohost[0] == 1'b1) begin
      $display("\n");
      $display("*****************************************************");
      $display("* RISC-V test bench finished");
      if (host_csr_tohost[0] == 1'b1) begin
        if (~|host_csr_tohost[XLEN-1:1])
          $display("* PASSED %0d", host_csr_tohost);
        else
          $display ("* FAILED: code: 0x%h (%0d: %s)", host_csr_tohost >> 1, host_csr_tohost >> 1, hostcode_to_string(host_csr_tohost >> 1) );
      end
      else
        $display ("* FAILED: watchdog count reached (%0d) @%0t", watchdog_cnt, $time);
      $display("*****************************************************");
      $display("\n");

      $finish();
    end
  end
endmodule
