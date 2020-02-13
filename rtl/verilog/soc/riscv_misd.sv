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
//              Multiple Instruction Single Data                              //
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

module riscv_misd #(
  parameter            XLEN               = 64,
  parameter            PLEN               = 64,
  parameter [XLEN-1:0] PC_INIT            = 'h8000_0000,
  parameter            HAS_USER           = 0,
  parameter            HAS_SUPER          = 0,
  parameter            HAS_HYPER          = 0,
  parameter            HAS_BPU            = 1,
  parameter            HAS_FPU            = 0,
  parameter            HAS_MMU            = 0,
  parameter            HAS_RVM            = 0,
  parameter            HAS_RVA            = 0,
  parameter            HAS_RVC            = 0,
  parameter            IS_RV32E           = 0,

  parameter            MULT_LATENCY       = 0,

  parameter            BREAKPOINTS        = 8,  //Number of hardware breakpoints

  parameter            PMA_CNT            = 4,
  parameter            PMP_CNT            = 16, //Number of Physical Memory Protection entries

  parameter            BP_GLOBAL_BITS     = 2,
  parameter            BP_LOCAL_BITS      = 10,

  parameter            ICACHE_SIZE        = 0,  //in KBytes
  parameter            ICACHE_BLOCK_SIZE  = 32, //in Bytes
  parameter            ICACHE_WAYS        = 2,  //'n'-way set associative
  parameter            ICACHE_REPLACE_ALG = 0,
  parameter            ITCM_SIZE          = 0,

  parameter            DCACHE_SIZE        = 0,  //in KBytes
  parameter            DCACHE_BLOCK_SIZE  = 32, //in Bytes
  parameter            DCACHE_WAYS        = 2,  //'n'-way set associative
  parameter            DCACHE_REPLACE_ALG = 0,
  parameter            DTCM_SIZE          = 0,
  parameter            WRITEBUFFER_SIZE   = 8,

  parameter            TECHNOLOGY         = "GENERIC",

  parameter [XLEN-1:0] MNMIVEC_DEFAULT    = PC_INIT - 'h004,
  parameter [XLEN-1:0] MTVEC_DEFAULT      = PC_INIT - 'h040,
  parameter [XLEN-1:0] HTVEC_DEFAULT      = PC_INIT - 'h080,
  parameter [XLEN-1:0] STVEC_DEFAULT      = PC_INIT - 'h0C0,
  parameter [XLEN-1:0] UTVEC_DEFAULT      = PC_INIT - 'h100,

  parameter            JEDEC_BANK            = 10,
  parameter            JEDEC_MANUFACTURER_ID = 'h6e,

  parameter            HARTID             = 0,

  parameter            PARCEL_SIZE        = 32,

  parameter            HADDR_SIZE         = XLEN,
  parameter            HDATA_SIZE         = PLEN,
  parameter            PADDR_SIZE         = PLEN,
  parameter            PDATA_SIZE         = XLEN,

  parameter            FLIT_WIDTH         = 34,

  parameter            SYNC_DEPTH         = 3,

  parameter            CORES_PER_MISD     = 4,

  parameter            CHANNELS           = 2
)
  (
    //Common signals
    input                                          HRESETn,
    input                                          HCLK,

    //PMA configuration
    input logic [PMA_CNT  -1:0][             13:0] pma_cfg_i,
    input logic [PMA_CNT  -1:0][XLEN         -1:0] pma_adr_i,

    //AHB instruction
    output      [CORES_PER_MISD-1:0]               ins_HSEL,
    output      [CORES_PER_MISD-1:0][PLEN    -1:0] ins_HADDR,
    output      [CORES_PER_MISD-1:0][XLEN    -1:0] ins_HWDATA,
    input       [CORES_PER_MISD-1:0][XLEN    -1:0] ins_HRDATA,
    output      [CORES_PER_MISD-1:0]               ins_HWRITE,
    output      [CORES_PER_MISD-1:0][         2:0] ins_HSIZE,
    output      [CORES_PER_MISD-1:0][         2:0] ins_HBURST,
    output      [CORES_PER_MISD-1:0][         3:0] ins_HPROT,
    output      [CORES_PER_MISD-1:0][         1:0] ins_HTRANS,
    output      [CORES_PER_MISD-1:0]               ins_HMASTLOCK,
    input       [CORES_PER_MISD-1:0]               ins_HREADY,
    input       [CORES_PER_MISD-1:0]               ins_HRESP,

    //AHB data
    output                                         dat_HSEL,
    output                          [PLEN    -1:0] dat_HADDR,
    output                          [XLEN    -1:0] dat_HWDATA,
    input                           [XLEN    -1:0] dat_HRDATA,
    output                                         dat_HWRITE,
    output                          [         2:0] dat_HSIZE,
    output                          [         2:0] dat_HBURST,
    output                          [         3:0] dat_HPROT,
    output                          [         1:0] dat_HTRANS,
    output                                         dat_HMASTLOCK,
    input                                          dat_HREADY,
    input                                          dat_HRESP,

    //Interrupts Interface
    input       [CORES_PER_MISD-1:0]               ext_nmi,
    input       [CORES_PER_MISD-1:0]               ext_tint,
    input       [CORES_PER_MISD-1:0]               ext_sint,
    input       [CORES_PER_MISD-1:0][         3:0] ext_int,

    //Debug Interface
    input       [CORES_PER_MISD-1:0]               dbg_stall,
    input       [CORES_PER_MISD-1:0]               dbg_strb,
    input       [CORES_PER_MISD-1:0]               dbg_we,
    input       [CORES_PER_MISD-1:0][PLEN    -1:0] dbg_addr,
    input       [CORES_PER_MISD-1:0][XLEN    -1:0] dbg_dati,
    output      [CORES_PER_MISD-1:0][XLEN    -1:0] dbg_dato,
    output      [CORES_PER_MISD-1:0]               dbg_ack,
    output      [CORES_PER_MISD-1:0]               dbg_bp,

    //GPIO Interface
    input       [CORES_PER_MISD-1:0][PDATA_SIZE-1:0] gpio_i,
    output reg  [CORES_PER_MISD-1:0][PDATA_SIZE-1:0] gpio_o,
    output reg  [CORES_PER_MISD-1:0][PDATA_SIZE-1:0] gpio_oe,

    //NoC Interface
    input       [CHANNELS -1:0][FLIT_WIDTH-1:0] noc_in_flit,
    input       [CHANNELS -1:0]                 noc_in_last,
    input       [CHANNELS -1:0]                 noc_in_valid,
    output      [CHANNELS -1:0]                 noc_in_ready,

    output      [CHANNELS -1:0][FLIT_WIDTH-1:0] noc_out_flit,
    output      [CHANNELS -1:0]                 noc_out_last,
    output      [CHANNELS -1:0]                 noc_out_valid,
    input       [CHANNELS -1:0]                 noc_out_ready
  );

  //////////////////////////////////////////////////////////////////
  //
  // Constants
  //
  parameter MASTERS = 5;
  parameter SLAVES  = 5;

  parameter ADDR_WIDTH = 32;
  parameter DATA_WIDTH = 32;

  parameter APB_ADDR_WIDTH = 12;
  parameter APB_DATA_WIDTH = 32;

  parameter TABLE_ENTRIES = 4;
  parameter TABLE_ENTRIES_PTRWIDTH = $clog2(4);
  parameter TILEID = 0;
  parameter NOC_PACKET_SIZE = 16;
  parameter GENERATE_INTERRUPT = 1;

  localparam MISD_BITS = $clog2(CORES_PER_MISD);

  //////////////////////////////////////////////////////////////////
  //
  // Functions
  //
  function integer onehot2int;
    input [CORES_PER_MISD-1:0] onehot;

    for (onehot2int = - 1; |onehot; onehot2int=onehot2int+1) onehot = onehot >> 1;
  endfunction //onehot2int

  function [2:0] highest_requested_priority (
    input [CORES_PER_MISD-1:0] hsel       
  );
    logic [CORES_PER_MISD-1:0][2:0] priorities;
    integer n;
    highest_requested_priority = 0;
    for (n=0; n<CORES_PER_MISD; n++) begin
      priorities[n] = n;
      if (hsel[n] && priorities[n] > highest_requested_priority) highest_requested_priority = priorities[n];
    end
  endfunction //highest_requested_priority

  function [CORES_PER_MISD-1:0] requesters;
    input [CORES_PER_MISD-1:0] hsel;
    input [2:0] priority_select;
    logic [CORES_PER_MISD-1:0][2:0] priorities;
    integer n;

    for (n=0; n<CORES_PER_MISD; n++) begin
      priorities[n] = n;
      requesters[n] = (priorities[n] == priority_select) & hsel[n];
    end
  endfunction //requesters

  function [CORES_PER_MISD-1:0] nxt_misd_master;
    input [CORES_PER_MISD-1:0] pending_misd_masters;  //pending masters for the requesed priority level
    input [CORES_PER_MISD-1:0] last_misd_master;      //last granted master for the priority level
    input [CORES_PER_MISD-1:0] current_misd_master;   //current granted master (indpendent of priority level)

    integer n, offset;
    logic [CORES_PER_MISD*2-1:0] sr;

    //default value, don't switch if not needed
    nxt_misd_master = current_misd_master;

    //implement round-robin
    offset = onehot2int(last_misd_master) + 1;

    sr = {pending_misd_masters, pending_misd_masters};
    for (n = 0; n < CORES_PER_MISD; n++)
      if ( sr[n + offset] ) return (1 << ((n+offset) % CORES_PER_MISD));
  endfunction

  ////////////////////////////////////////////////////////////////
  //
  // Variables
  //

  genvar t;

  // DMA
  logic [CORES_PER_MISD-1:0][FLIT_WIDTH -1:0] noc_ahb3_in_req_flit;
  logic [CORES_PER_MISD-1:0]                  noc_ahb3_in_req_valid;
  logic [CORES_PER_MISD-1:0]                  noc_ahb3_in_req_ready;

  logic [CORES_PER_MISD-1:0][FLIT_WIDTH -1:0] noc_ahb3_in_res_flit;
  logic [CORES_PER_MISD-1:0]                  noc_ahb3_in_res_valid;
  logic [CORES_PER_MISD-1:0]                  noc_ahb3_in_res_ready;

  logic [CORES_PER_MISD-1:0][FLIT_WIDTH -1:0] noc_ahb3_out_req_flit;
  logic [CORES_PER_MISD-1:0]                  noc_ahb3_out_req_valid;
  logic [CORES_PER_MISD-1:0]                  noc_ahb3_out_req_ready;

  logic [CORES_PER_MISD-1:0][FLIT_WIDTH -1:0] noc_ahb3_out_res_flit;
  logic [CORES_PER_MISD-1:0]                  noc_ahb3_out_res_valid;
  logic [CORES_PER_MISD-1:0]                  noc_ahb3_out_res_ready;

  logic [CORES_PER_MISD-1:0]                  ahb3_if_hsel;
  logic [CORES_PER_MISD-1:0][ADDR_WIDTH -1:0] ahb3_if_haddr;
  logic [CORES_PER_MISD-1:0][DATA_WIDTH -1:0] ahb3_if_hrdata;
  logic [CORES_PER_MISD-1:0][DATA_WIDTH -1:0] ahb3_if_hwdata;
  logic [CORES_PER_MISD-1:0]                  ahb3_if_hwrite;
  logic [CORES_PER_MISD-1:0]                  ahb3_if_hmastlock;
  logic [CORES_PER_MISD-1:0]                  ahb3_if_hready;
  logic [CORES_PER_MISD-1:0]                  ahb3_if_hresp;

  logic [CORES_PER_MISD-1:0]                  ahb3_hsel;
  logic [CORES_PER_MISD-1:0][ADDR_WIDTH -1:0] ahb3_haddr;
  logic [CORES_PER_MISD-1:0][DATA_WIDTH -1:0] ahb3_hwdata;
  logic [CORES_PER_MISD-1:0][DATA_WIDTH -1:0] ahb3_hrdata;
  logic [CORES_PER_MISD-1:0]                  ahb3_hwrite;
  logic [CORES_PER_MISD-1:0][            2:0] ahb3_hsize;
  logic [CORES_PER_MISD-1:0][            2:0] ahb3_hburst;
  logic [CORES_PER_MISD-1:0][            3:0] ahb3_hprot;
  logic [CORES_PER_MISD-1:0][            1:0] ahb3_htrans;
  logic [CORES_PER_MISD-1:0]                  ahb3_hmastlock;
  logic [CORES_PER_MISD-1:0]                  ahb3_hready;

  logic [CORES_PER_MISD-1:0][TABLE_ENTRIES-1:0] irq_ahb3;

  logic [CORES_PER_MISD-1:0][FLIT_WIDTH -1:0] mux_flit;
  logic [CORES_PER_MISD-1:0]                  mux_last;
  logic [CORES_PER_MISD-1:0]                  mux_valid;
  logic [CORES_PER_MISD-1:0]                  mux_ready;

  logic [CORES_PER_MISD-1:0][FLIT_WIDTH -1:0] demux_flit;
  logic [CORES_PER_MISD-1:0]                  demux_last;
  logic [CORES_PER_MISD-1:0]                  demux_valid;
  logic [CORES_PER_MISD-1:0]                  demux_ready;

  // Connections DMA
  logic [CORES_PER_MISD-1:0][CHANNELS-1:0][FLIT_WIDTH -1:0] noc_ahb3_in_flit;
  logic [CORES_PER_MISD-1:0][CHANNELS-1:0]                  noc_ahb3_in_valid;
  logic [CORES_PER_MISD-1:0][CHANNELS-1:0]                  noc_ahb3_in_ready;

  logic [CORES_PER_MISD-1:0][CHANNELS-1:0][FLIT_WIDTH -1:0] noc_ahb3_out_flit;
  logic [CORES_PER_MISD-1:0][CHANNELS-1:0]                  noc_ahb3_out_valid;
  logic [CORES_PER_MISD-1:0][CHANNELS-1:0]                  noc_ahb3_out_ready;

  // Connections MISD
  logic [CORES_PER_MISD-1:0][FLIT_WIDTH -1:0] noc_input_flit;
  logic [CORES_PER_MISD-1:0]                  noc_input_last;
  logic [CORES_PER_MISD-1:0]                  noc_input_valid;
  logic [CORES_PER_MISD-1:0]                  noc_input_ready;

  logic [CORES_PER_MISD-1:0][FLIT_WIDTH -1:0] noc_output_flit;
  logic [CORES_PER_MISD-1:0]                  noc_output_last;
  logic [CORES_PER_MISD-1:0]                  noc_output_valid;
  logic [CORES_PER_MISD-1:0]                  noc_output_ready;

  // Connections LNKs
  logic [FLIT_WIDTH -1:0] linked0_flit;
  logic                   linked0_last;
  logic                   linked0_valid;
  logic                   linked0_ready;

  logic [FLIT_WIDTH -1:0] linked1_flit;
  logic                   linked1_last;
  logic                   linked1_valid;
  logic                   linked1_ready;

  // MSI
  wire  [CORES_PER_MISD-1:0][MASTERS-1:0]                      mst_HSEL;
  wire  [CORES_PER_MISD-1:0][MASTERS-1:0][PLEN           -1:0] mst_HADDR;
  wire  [CORES_PER_MISD-1:0][MASTERS-1:0][XLEN           -1:0] mst_HWDATA;
  wire  [CORES_PER_MISD-1:0][MASTERS-1:0][XLEN           -1:0] mst_HRDATA;
  wire  [CORES_PER_MISD-1:0][MASTERS-1:0]                      mst_HWRITE;
  wire  [CORES_PER_MISD-1:0][MASTERS-1:0][                2:0] mst_HSIZE;
  wire  [CORES_PER_MISD-1:0][MASTERS-1:0][                2:0] mst_HBURST;
  wire  [CORES_PER_MISD-1:0][MASTERS-1:0][                3:0] mst_HPROT;
  wire  [CORES_PER_MISD-1:0][MASTERS-1:0][                1:0] mst_HTRANS;
  wire  [CORES_PER_MISD-1:0][MASTERS-1:0]                      mst_HMASTLOCK;
  wire  [CORES_PER_MISD-1:0][MASTERS-1:0]                      mst_HREADY;
  wire  [CORES_PER_MISD-1:0][MASTERS-1:0]                      mst_HREADYOUT;
  wire  [CORES_PER_MISD-1:0][MASTERS-1:0]                      mst_HRESP;

  wire  [CORES_PER_MISD-1:0][SLAVES -1:0]                      slv_HSEL;
  wire  [CORES_PER_MISD-1:0][SLAVES -1:0][PLEN           -1:0] slv_HADDR;
  wire  [CORES_PER_MISD-1:0][SLAVES -1:0][XLEN           -1:0] slv_HWDATA;
  wire  [CORES_PER_MISD-1:0][SLAVES -1:0][XLEN           -1:0] slv_HRDATA;
  wire  [CORES_PER_MISD-1:0][SLAVES -1:0]                      slv_HWRITE;
  wire  [CORES_PER_MISD-1:0][SLAVES -1:0][                2:0] slv_HSIZE;
  wire  [CORES_PER_MISD-1:0][SLAVES -1:0][                2:0] slv_HBURST;
  wire  [CORES_PER_MISD-1:0][SLAVES -1:0][                3:0] slv_HPROT;
  wire  [CORES_PER_MISD-1:0][SLAVES -1:0][                1:0] slv_HTRANS;
  wire  [CORES_PER_MISD-1:0][SLAVES -1:0]                      slv_HMASTLOCK;
  wire  [CORES_PER_MISD-1:0][SLAVES -1:0]                      slv_HREADY;
  wire  [CORES_PER_MISD-1:0][SLAVES -1:0]                      slv_HRESP;

  // GPIO
  wire  [CORES_PER_MISD-1:0]                      mst_gpio_HSEL;
  wire  [CORES_PER_MISD-1:0][PLEN           -1:0] mst_gpio_HADDR;
  wire  [CORES_PER_MISD-1:0][XLEN           -1:0] mst_gpio_HWDATA;
  wire  [CORES_PER_MISD-1:0][XLEN           -1:0] mst_gpio_HRDATA;
  wire  [CORES_PER_MISD-1:0]                      mst_gpio_HWRITE;
  wire  [CORES_PER_MISD-1:0][                2:0] mst_gpio_HSIZE;
  wire  [CORES_PER_MISD-1:0][                2:0] mst_gpio_HBURST;
  wire  [CORES_PER_MISD-1:0][                3:0] mst_gpio_HPROT;
  wire  [CORES_PER_MISD-1:0][                1:0] mst_gpio_HTRANS;
  wire  [CORES_PER_MISD-1:0]                      mst_gpio_HMASTLOCK;
  wire  [CORES_PER_MISD-1:0]                      mst_gpio_HREADY;
  wire  [CORES_PER_MISD-1:0]                      mst_gpio_HREADYOUT;
  wire  [CORES_PER_MISD-1:0]                      mst_gpio_HRESP;

  wire  [CORES_PER_MISD-1:0]                      gpio_PSEL;
  wire  [CORES_PER_MISD-1:0]                      gpio_PENABLE;
  wire  [CORES_PER_MISD-1:0]                      gpio_PWRITE;
  wire  [CORES_PER_MISD-1:0]                      gpio_PSTRB;
  wire  [CORES_PER_MISD-1:0][PADDR_SIZE     -1:0] gpio_PADDR;
  wire  [CORES_PER_MISD-1:0][PDATA_SIZE     -1:0] gpio_PWDATA;
  wire  [CORES_PER_MISD-1:0][PDATA_SIZE     -1:0] gpio_PRDATA;
  wire  [CORES_PER_MISD-1:0]                      gpio_PREADY;
  wire  [CORES_PER_MISD-1:0]                      gpio_PSLVERR;

  logic [CORES_PER_MISD-1:0]                      uart_PSEL;
  logic [CORES_PER_MISD-1:0]                      uart_PENABLE;
  logic [CORES_PER_MISD-1:0]                      uart_PWRITE;
  logic [CORES_PER_MISD-1:0][APB_ADDR_WIDTH -1:0] uart_PADDR;
  logic [CORES_PER_MISD-1:0][APB_DATA_WIDTH -1:0] uart_PWDATA;
  logic [CORES_PER_MISD-1:0][APB_DATA_WIDTH -1:0] uart_PRDATA;
  logic [CORES_PER_MISD-1:0]                      uart_PREADY;
  logic [CORES_PER_MISD-1:0]                      uart_PSLVERR;

  logic [CORES_PER_MISD-1:0]                      uart_rx_i;  // Receiver input
  logic [CORES_PER_MISD-1:0]                      uart_tx_o;  // Transmitter output

  logic [CORES_PER_MISD-1:0]                      uart_event_o;

  // RAM
  wire  [CORES_PER_MISD-1:0]                      mst_sram_HSEL;
  wire  [CORES_PER_MISD-1:0][PLEN           -1:0] mst_sram_HADDR;
  wire  [CORES_PER_MISD-1:0][XLEN           -1:0] mst_sram_HWDATA;
  wire  [CORES_PER_MISD-1:0][XLEN           -1:0] mst_sram_HRDATA;
  wire  [CORES_PER_MISD-1:0]                      mst_sram_HWRITE;
  wire  [CORES_PER_MISD-1:0][                2:0] mst_sram_HSIZE;
  wire  [CORES_PER_MISD-1:0][                2:0] mst_sram_HBURST;
  wire  [CORES_PER_MISD-1:0][                3:0] mst_sram_HPROT;
  wire  [CORES_PER_MISD-1:0][                1:0] mst_sram_HTRANS;
  wire  [CORES_PER_MISD-1:0]                      mst_sram_HMASTLOCK;
  wire  [CORES_PER_MISD-1:0]                      mst_sram_HREADY;
  wire  [CORES_PER_MISD-1:0]                      mst_sram_HREADYOUT;
  wire  [CORES_PER_MISD-1:0]                      mst_sram_HRESP;

  wire  [CORES_PER_MISD-1:0]                      mst_mram_HSEL;
  wire  [CORES_PER_MISD-1:0][PLEN           -1:0] mst_mram_HADDR;
  wire  [CORES_PER_MISD-1:0][XLEN           -1:0] mst_mram_HWDATA;
  wire  [CORES_PER_MISD-1:0][XLEN           -1:0] mst_mram_HRDATA;
  wire  [CORES_PER_MISD-1:0]                      mst_mram_HWRITE;
  wire  [CORES_PER_MISD-1:0][                2:0] mst_mram_HSIZE;
  wire  [CORES_PER_MISD-1:0][                2:0] mst_mram_HBURST;
  wire  [CORES_PER_MISD-1:0][                3:0] mst_mram_HPROT;
  wire  [CORES_PER_MISD-1:0][                1:0] mst_mram_HTRANS;
  wire  [CORES_PER_MISD-1:0]                      mst_mram_HMASTLOCK;
  wire  [CORES_PER_MISD-1:0]                      mst_mram_HREADY;
  wire  [CORES_PER_MISD-1:0]                      mst_mram_HREADYOUT;
  wire  [CORES_PER_MISD-1:0]                      mst_mram_HRESP;

  // PU
  wire  [CORES_PER_MISD-1:0]                      bus_dat_HSEL;
  wire  [CORES_PER_MISD-1:0][PLEN           -1:0] bus_dat_HADDR;
  wire  [CORES_PER_MISD-1:0][XLEN           -1:0] bus_dat_HWDATA;
  wire  [CORES_PER_MISD-1:0][XLEN           -1:0] bus_dat_HRDATA;
  wire  [CORES_PER_MISD-1:0]                      bus_dat_HWRITE;
  wire  [CORES_PER_MISD-1:0][                2:0] bus_dat_HSIZE;
  wire  [CORES_PER_MISD-1:0][                2:0] bus_dat_HBURST;
  wire  [CORES_PER_MISD-1:0][                3:0] bus_dat_HPROT;
  wire  [CORES_PER_MISD-1:0][                1:0] bus_dat_HTRANS;
  wire  [CORES_PER_MISD-1:0]                      bus_dat_HMASTLOCK;
  wire  [CORES_PER_MISD-1:0]                      bus_dat_HREADY;
  wire  [CORES_PER_MISD-1:0]                      bus_dat_HRESP;

  logic [                2:0] requested_priority_lvl;        //requested priority level
  logic [CORES_PER_MISD -1:0] priority_misd_masters;         //all masters at this priority level

  logic [CORES_PER_MISD -1:0] pending_misd_master,           //next master waiting to be served
                              last_granted_misd_master;      //for requested priority level
  logic [CORES_PER_MISD -1:0] last_granted_misd_masters [3]; //per priority level, for round-robin


  logic [MISD_BITS      -1:0] granted_misd_master_idx,       //granted master as index
                              granted_misd_master_idx_dly;   //deleayed granted master index (for HWDATA)

  logic [CORES_PER_MISD -1:0] granted_misd_master;

  ////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  //Instantiate RISC-V PU
  generate
    for (t=0; t < CORES_PER_MISD; t=t+1) begin
      //Instantiate RISC-V PU
      riscv_pu #(
        .XLEN                  ( XLEN ),
        .PLEN                  ( PLEN ),
        .PC_INIT               ( PC_INIT ),
        .HAS_USER              ( HAS_USER ),
        .HAS_SUPER             ( HAS_SUPER ),
        .HAS_HYPER             ( HAS_HYPER ),
        .HAS_BPU               ( HAS_BPU ),
        .HAS_FPU               ( HAS_FPU ),
        .HAS_MMU               ( HAS_MMU ),
        .HAS_RVM               ( HAS_RVM ),
        .HAS_RVA               ( HAS_RVA ),
        .HAS_RVC               ( HAS_RVC ),
        .IS_RV32E              ( IS_RV32E ),

        .MULT_LATENCY          ( MULT_LATENCY ),

        .BREAKPOINTS           ( BREAKPOINTS ),

        .PMA_CNT               ( PMA_CNT ),
        .PMP_CNT               ( PMP_CNT ),

        .BP_GLOBAL_BITS        ( BP_GLOBAL_BITS ),
        .BP_LOCAL_BITS         ( BP_LOCAL_BITS ),

        .ICACHE_SIZE           ( ICACHE_SIZE ),
        .ICACHE_BLOCK_SIZE     ( ICACHE_BLOCK_SIZE ),
        .ICACHE_WAYS           ( ICACHE_WAYS ),
        .ICACHE_REPLACE_ALG    ( ICACHE_REPLACE_ALG ),
        .ITCM_SIZE             ( ITCM_SIZE ),

        .DCACHE_SIZE           ( DCACHE_SIZE ),
        .DCACHE_BLOCK_SIZE     ( DCACHE_BLOCK_SIZE ),
        .DCACHE_WAYS           ( DCACHE_WAYS ),
        .DCACHE_REPLACE_ALG    ( DCACHE_REPLACE_ALG ),
        .DTCM_SIZE             ( DTCM_SIZE ),
        .WRITEBUFFER_SIZE      ( WRITEBUFFER_SIZE ),

        .TECHNOLOGY            ( TECHNOLOGY ),

        .MNMIVEC_DEFAULT       ( MNMIVEC_DEFAULT ),
        .MTVEC_DEFAULT         ( MTVEC_DEFAULT ),
        .HTVEC_DEFAULT         ( HTVEC_DEFAULT ),
        .STVEC_DEFAULT         ( STVEC_DEFAULT ),
        .UTVEC_DEFAULT         ( UTVEC_DEFAULT ),

        .JEDEC_BANK            ( JEDEC_BANK ),
        .JEDEC_MANUFACTURER_ID ( JEDEC_MANUFACTURER_ID ),

        .HARTID                ( HARTID ),

        .PARCEL_SIZE           ( PARCEL_SIZE )
      )
      pu (
        //Common signals
        .HRESETn       ( HRESETn ),
        .HCLK          ( HCLK    ),

        //PMA configuration
        .pma_cfg_i     ( pma_cfg_i ),
        .pma_adr_i     ( pma_adr_i ),

        //AHB instruction
        .ins_HSEL      ( ins_HSEL          [t] ),
        .ins_HADDR     ( ins_HADDR         [t] ),
        .ins_HWDATA    ( ins_HWDATA        [t] ),
        .ins_HRDATA    ( ins_HRDATA        [t] ),
        .ins_HWRITE    ( ins_HWRITE        [t] ),
        .ins_HSIZE     ( ins_HSIZE         [t] ),
        .ins_HBURST    ( ins_HBURST        [t] ),
        .ins_HPROT     ( ins_HPROT         [t] ),
        .ins_HTRANS    ( ins_HTRANS        [t] ),
        .ins_HMASTLOCK ( ins_HMASTLOCK     [t] ),
        .ins_HREADY    ( ins_HREADY        [t] ),
        .ins_HRESP     ( ins_HRESP         [t] ),

        //AHB data
        .dat_HSEL      ( bus_dat_HSEL      [t] ),
        .dat_HADDR     ( bus_dat_HADDR     [t] ),
        .dat_HWDATA    ( bus_dat_HWDATA    [t] ),
        .dat_HRDATA    ( bus_dat_HRDATA    [t] ),
        .dat_HWRITE    ( bus_dat_HWRITE    [t] ),
        .dat_HSIZE     ( bus_dat_HSIZE     [t] ),
        .dat_HBURST    ( bus_dat_HBURST    [t] ),
        .dat_HPROT     ( bus_dat_HPROT     [t] ),
        .dat_HTRANS    ( bus_dat_HTRANS    [t] ),
        .dat_HMASTLOCK ( bus_dat_HMASTLOCK [t] ),
        .dat_HREADY    ( bus_dat_HREADY    [t] ),
        .dat_HRESP     ( bus_dat_HRESP     [t] ),

        //Interrupts Interface
        .ext_nmi       ( ext_nmi           [t] ),
        .ext_tint      ( ext_tint          [t] ),
        .ext_sint      ( ext_sint          [t] ),
        .ext_int       ( ext_int           [t] ),

        //Debug Interface
        .dbg_stall     ( dbg_stall         [t] ),
        .dbg_strb      ( dbg_strb          [t] ),
        .dbg_we        ( dbg_we            [t] ),
        .dbg_addr      ( dbg_addr          [t] ),
        .dbg_dati      ( dbg_dati          [t] ),
        .dbg_dato      ( dbg_dato          [t] ),
        .dbg_ack       ( dbg_ack           [t] ),
        .dbg_bp        ( dbg_bp            [t] )
      );

      mpsoc_msi_interface #(
        .PLEN    ( PLEN    ),
        .XLEN    ( XLEN    ),
        .MASTERS ( MASTERS ),
        .SLAVES  ( SLAVES  )
      )
      peripheral_interface (
        //Common signals
        .HRESETn       ( HRESETn ),
        .HCLK          ( HCLK    ),

        //Master Ports; AHB masters connect to these
        //thus these are actually AHB Slave Interfaces
        .mst_priority  (                   ),

        .mst_HSEL      ( mst_HSEL      [t] ),
        .mst_HADDR     ( mst_HADDR     [t] ),
        .mst_HWDATA    ( mst_HWDATA    [t] ),
        .mst_HRDATA    ( mst_HRDATA    [t] ),
        .mst_HWRITE    ( mst_HWRITE    [t] ),
        .mst_HSIZE     ( mst_HSIZE     [t] ),
        .mst_HBURST    ( mst_HBURST    [t] ),
        .mst_HPROT     ( mst_HPROT     [t] ),
        .mst_HTRANS    ( mst_HTRANS    [t] ),
        .mst_HMASTLOCK ( mst_HMASTLOCK [t] ),
        .mst_HREADYOUT ( mst_HREADYOUT [t] ),
        .mst_HREADY    ( mst_HREADY    [t] ),
        .mst_HRESP     ( mst_HRESP     [t] ),

        //Slave Ports; AHB Slaves connect to these
        //thus these are actually AHB Master Interfaces
        .slv_addr_mask (                   ),
        .slv_addr_base (                   ),

        .slv_HSEL      ( slv_HSEL      [t] ),
        .slv_HADDR     ( slv_HADDR     [t] ),
        .slv_HWDATA    ( slv_HWDATA    [t] ),
        .slv_HRDATA    ( slv_HRDATA    [t] ),
        .slv_HWRITE    ( slv_HWRITE    [t] ),
        .slv_HSIZE     ( slv_HSIZE     [t] ),
        .slv_HBURST    ( slv_HBURST    [t] ),
        .slv_HPROT     ( slv_HPROT     [t] ),
        .slv_HTRANS    ( slv_HTRANS    [t] ),
        .slv_HMASTLOCK ( slv_HMASTLOCK [t] ),
        .slv_HREADYOUT (                   ),
        .slv_HREADY    ( slv_HREADY    [t] ),
        .slv_HRESP     ( slv_HRESP     [t] )
      );

      //Instantiate RISC-V DMA
      mpsoc_dma_ahb3_top #(
        .ADDR_WIDTH ( ADDR_WIDTH ),
        .DATA_WIDTH ( DATA_WIDTH ),

        .TABLE_ENTRIES          ( TABLE_ENTRIES          ),
        .TABLE_ENTRIES_PTRWIDTH ( TABLE_ENTRIES_PTRWIDTH ),
        .TILEID                 ( TILEID                 ),
        .NOC_PACKET_SIZE        ( NOC_PACKET_SIZE        ),
        .GENERATE_INTERRUPT     ( GENERATE_INTERRUPT     )
      )
      ahb3_top (
        .clk ( HCLK    ),
        .rst ( HRESETn ),

        .noc_in_req_flit  ( noc_ahb3_in_req_flit  [t] ),
        .noc_in_req_valid ( noc_ahb3_in_req_valid [t] ),
        .noc_in_req_ready ( noc_ahb3_in_req_ready [t] ),

        .noc_in_res_flit  ( noc_ahb3_in_res_flit  [t] ),
        .noc_in_res_valid ( noc_ahb3_in_res_valid [t] ),
        .noc_in_res_ready ( noc_ahb3_in_res_ready [t] ),

        .noc_out_req_flit  ( noc_ahb3_out_req_flit  [t] ),
        .noc_out_req_valid ( noc_ahb3_out_req_valid [t] ),
        .noc_out_req_ready ( noc_ahb3_out_req_ready [t] ),

        .noc_out_res_flit  ( noc_ahb3_out_res_flit  [t] ),
        .noc_out_res_valid ( noc_ahb3_out_res_valid [t] ),
        .noc_out_res_ready ( noc_ahb3_out_res_ready [t] ),

        .ahb3_if_haddr     ( ahb3_if_haddr     [t] ),
        .ahb3_if_hrdata    ( ahb3_if_hrdata    [t] ),
        .ahb3_if_hmastlock ( ahb3_if_hmastlock [t] ),
        .ahb3_if_hsel      ( ahb3_if_hsel      [t] ),
        .ahb3_if_hwrite    ( ahb3_if_hwrite    [t] ),
        .ahb3_if_hwdata    ( ahb3_if_hwdata    [t] ),
        .ahb3_if_hready    ( ahb3_if_hready    [t] ),
        .ahb3_if_hresp     ( ahb3_if_hresp     [t] ),

        .ahb3_haddr     ( ahb3_haddr     [t] ),
        .ahb3_hwdata    ( ahb3_hwdata    [t] ),
        .ahb3_hmastlock ( ahb3_hmastlock [t] ),
        .ahb3_hsel      ( ahb3_hsel      [t] ),
        .ahb3_hprot     ( ahb3_hprot     [t] ),
        .ahb3_hwrite    ( ahb3_hwrite    [t] ),
        .ahb3_hsize     ( ahb3_hsize     [t] ),
        .ahb3_hburst    ( ahb3_hburst    [t] ),
        .ahb3_htrans    ( ahb3_htrans    [t] ),
        .ahb3_hrdata    ( ahb3_hrdata    [t] ),
        .ahb3_hready    ( ahb3_hready    [t] ),

        .irq ( irq_ahb3 [t] )
      );

      mpsoc_noc_buffer #(
        .FLIT_WIDTH ( FLIT_WIDTH ),
        .DEPTH      ()
      )
      mux_noc_buffer (
       .clk          ( HRESETn ),
       .rst          ( HCLK    ),

        .in_flit     ( mux_flit  [t] ),
        .in_last     ( mux_last  [t] ),
        .in_valid    ( mux_valid [t] ),
        .in_ready    ( mux_ready [t] ),

        .out_flit    ( noc_output_flit  [t] ),
        .out_last    ( noc_output_last  [t] ),
        .out_valid   ( noc_output_valid [t] ),
        .out_ready   ( noc_output_ready [t] ),

        .packet_size ()
      );

      mpsoc_noc_buffer #(
        .FLIT_WIDTH ( FLIT_WIDTH ),
        .DEPTH      ()
      )
      demux_noc_buffer (
       .clk          ( HRESETn ),
       .rst          ( HCLK    ),

        .in_flit     ( noc_input_flit  [t] ),
        .in_last     ( noc_input_last  [t] ),
        .in_valid    ( noc_input_valid [t] ),
        .in_ready    ( noc_input_ready [t] ),

        .out_flit    ( demux_flit  [t] ),
        .out_last    ( demux_last  [t] ),
        .out_valid   ( demux_valid [t] ),
        .out_ready   ( demux_ready [t] ),

        .packet_size ()
      );

      mpsoc_noc_mux #(
        .FLIT_WIDTH ( FLIT_WIDTH ),
        .CHANNELS   ( CHANNELS   )
      )
      noc_mux (
        .clk ( HRESETn ),
        .rst ( HCLK    ),

        .in_flit   ( noc_ahb3_out_flit  [t] ),
        .in_last   (                        ),
        .in_valid  ( noc_ahb3_out_valid [t] ),
        .in_ready  ( noc_ahb3_out_ready [t] ),

        .out_flit  ( mux_flit  [t] ),
        .out_last  ( mux_last  [t] ),
        .out_valid ( mux_valid [t] ),
        .out_ready ( mux_ready [t] )
      );

      mpsoc_noc_demux #(
        .FLIT_WIDTH ( FLIT_WIDTH ),
        .CHANNELS   ( CHANNELS   ),
        .MAPPING    ()
      )
      noc_demux (
        .clk ( HRESETn ),
        .rst ( HCLK    ),

        .in_flit   ( demux_flit  [t] ),
        .in_last   ( demux_last  [t] ),
        .in_valid  ( demux_valid [t] ),
        .in_ready  ( demux_ready [t] ),

        .out_flit  ( noc_ahb3_in_flit  [t] ),
        .out_last  (                       ),
        .out_valid ( noc_ahb3_in_valid [t] ),
        .out_ready ( noc_ahb3_in_ready [t] )
      );

      assign noc_ahb3_in_req_flit  [t] = noc_ahb3_in_flit  [t][0];
      assign noc_ahb3_in_req_valid [t] = noc_ahb3_in_valid [t][0];

      assign noc_ahb3_in_ready [t][0] = noc_ahb3_in_req_ready [t];


      assign noc_ahb3_in_res_flit  [t] = noc_ahb3_in_flit  [t][1];
      assign noc_ahb3_in_res_valid [t] = noc_ahb3_in_valid [t][1];

      assign noc_ahb3_in_ready [t][1] = noc_ahb3_in_res_ready [t];


      assign noc_ahb3_out_flit  [t][0] = noc_ahb3_out_req_flit  [t];
      assign noc_ahb3_out_valid [t][0] = noc_ahb3_out_req_valid [t];

      assign noc_ahb3_out_req_ready [t] = noc_ahb3_out_ready [t][0];


      assign noc_ahb3_out_flit  [t][1] = noc_ahb3_out_res_flit  [t];
      assign noc_ahb3_out_valid [t][1] = noc_ahb3_out_res_valid [t];

      assign noc_ahb3_out_res_ready [t] = noc_ahb3_out_ready [t][1];

      //Instantiate RISC-V GPIO
      mpsoc_peripheral_bridge #(
        .HADDR_SIZE ( PLEN ),
        .HDATA_SIZE ( XLEN ),
        .PADDR_SIZE ( PLEN ),
        .PDATA_SIZE ( XLEN ),

        .SYNC_DEPTH ( SYNC_DEPTH )
      )
      gpio_bridge (
        //AHB Slave Interface
        .HRESETn   ( HRESETn ),
        .HCLK      ( HCLK    ),

        .HSEL      ( mst_gpio_HSEL      [t] ),
        .HADDR     ( mst_gpio_HADDR     [t] ),
        .HWDATA    ( mst_gpio_HWDATA    [t] ),
        .HRDATA    ( mst_gpio_HRDATA    [t] ),
        .HWRITE    ( mst_gpio_HWRITE    [t] ),
        .HSIZE     ( mst_gpio_HSIZE     [t] ),
        .HBURST    ( mst_gpio_HBURST    [t] ),
        .HPROT     ( mst_gpio_HPROT     [t] ),
        .HTRANS    ( mst_gpio_HTRANS    [t] ),
        .HMASTLOCK ( mst_gpio_HMASTLOCK [t] ),
        .HREADYOUT ( mst_gpio_HREADYOUT [t] ),
        .HREADY    ( mst_gpio_HREADY    [t] ),
        .HRESP     ( mst_gpio_HRESP     [t] ),

        //APB Master Interface
        .PRESETn ( HRESETn ),
        .PCLK    ( HCLK    ),

        .PSEL    ( gpio_PSEL    [t] ),
        .PENABLE ( gpio_PENABLE [t] ),
        .PPROT   (                  ),
        .PWRITE  ( gpio_PWRITE  [t] ),
        .PSTRB   ( gpio_PSTRB   [t] ),
        .PADDR   ( gpio_PADDR   [t] ),
        .PWDATA  ( gpio_PWDATA  [t] ),
        .PRDATA  ( gpio_PRDATA  [t] ),
        .PREADY  ( gpio_PREADY  [t] ),
        .PSLVERR ( gpio_PSLVERR [t] )
      );

      mpsoc_gpio #(
        .PADDR_SIZE ( PLEN ),
        .PDATA_SIZE ( XLEN )
      )
      gpio (
        .PRESETn ( HRESETn ),
        .PCLK    ( HCLK    ),

        .PSEL    ( gpio_PSEL    [t] ),
        .PENABLE ( gpio_PENABLE [t] ),
        .PWRITE  ( gpio_PWRITE  [t] ),
        .PSTRB   ( gpio_PSTRB   [t] ),
        .PADDR   ( gpio_PADDR   [t] ),
        .PWDATA  ( gpio_PWDATA  [t] ),
        .PRDATA  ( gpio_PRDATA  [t] ),
        .PREADY  ( gpio_PREADY  [t] ),
        .PSLVERR ( gpio_PSLVERR [t] ),

        .gpio_i  ( gpio_i       [t] ),
        .gpio_o  ( gpio_o       [t] ),
        .gpio_oe ( gpio_oe      [t] )
      );

      mpsoc_spram #(
        .MEM_SIZE          ( 0 ),
        .MEM_DEPTH         ( 256 ),
        .HADDR_SIZE        ( PLEN ),
        .HDATA_SIZE        ( XLEN ),
        .TECHNOLOGY        ( TECHNOLOGY ),
        .REGISTERED_OUTPUT ( "NO" )
      )
      spram (
        //AHB Slave Interface
        .HRESETn   ( HRESETn ),
        .HCLK      ( HCLK    ),

        .HSEL      ( mst_sram_HSEL      [t] ),
        .HADDR     ( mst_sram_HADDR     [t] ),
        .HWDATA    ( mst_sram_HWDATA    [t] ),
        .HRDATA    ( mst_sram_HRDATA    [t] ),
        .HWRITE    ( mst_sram_HWRITE    [t] ),
        .HSIZE     ( mst_sram_HSIZE     [t] ),
        .HBURST    ( mst_sram_HBURST    [t] ),
        .HPROT     ( mst_sram_HPROT     [t] ),
        .HTRANS    ( mst_sram_HTRANS    [t] ),
        .HMASTLOCK ( mst_sram_HMASTLOCK [t] ),
        .HREADYOUT ( mst_sram_HREADYOUT [t] ),
        .HREADY    ( mst_sram_HREADY    [t] ),
        .HRESP     ( mst_sram_HRESP     [t] )
      );

      //Instantiate RISC-V UART
      mpsoc_uart #(
        .APB_ADDR_WIDTH ( APB_ADDR_WIDTH ),
        .APB_DATA_WIDTH ( APB_DATA_WIDTH )
      )
      uart (
        .RSTN ( HRESETn ),
        .CLK  ( HCLK    ),

        .PADDR   ( uart_PADDR    [t] ),
        .PWDATA  ( uart_PWDATA   [t] ),
        .PWRITE  ( uart_PWRITE   [t] ),
        .PSEL    ( uart_PSEL     [t] ),
        .PENABLE ( uart_PENABLE  [t] ),
        .PRDATA  ( uart_PRDATA   [t] ),
        .PREADY  ( uart_PREADY   [t] ),
        .PSLVERR ( uart_PSLVERR  [t] ),

        .rx_i ( uart_rx_i  [t] ),
        .tx_o ( uart_tx_o  [t] ),

        .event_o ( uart_event_o  [t] )
      );

      // MST Connections
      assign mst_HSEL      [t][0] = bus_dat_HSEL      [t];
      assign mst_HADDR     [t][0] = bus_dat_HADDR     [t];
      assign mst_HWDATA    [t][0] = bus_dat_HWDATA    [t];
      assign mst_HWRITE    [t][0] = bus_dat_HWRITE    [t];
      assign mst_HSIZE     [t][0] = bus_dat_HSIZE     [t];
      assign mst_HBURST    [t][0] = bus_dat_HBURST    [t];
      assign mst_HPROT     [t][0] = bus_dat_HPROT     [t];
      assign mst_HTRANS    [t][0] = bus_dat_HTRANS    [t];
      assign mst_HMASTLOCK [t][0] = bus_dat_HMASTLOCK [t];
      assign mst_HREADY    [t][0] = bus_dat_HREADY    [t];

      assign mst_HREADYOUT [t][0] = 1'b0;

      assign bus_dat_HRDATA [t] = mst_HRDATA [t][0];
      assign bus_dat_HRESP  [t] = mst_HRESP  [t][0];

      assign mst_HSEL      [t][1] = ahb3_if_hsel      [t];
      assign mst_HADDR     [t][1] = ahb3_if_haddr     [t];
      assign mst_HWDATA    [t][1] = ahb3_if_hwdata    [t];
      assign mst_HWRITE    [t][1] = ahb3_if_hwrite    [t];
      assign mst_HSIZE     [t][1] = 3'b0;
      assign mst_HBURST    [t][1] = 3'b0;
      assign mst_HPROT     [t][1] = 4'b0;
      assign mst_HTRANS    [t][1] = 2'b0;
      assign mst_HMASTLOCK [t][1] = ahb3_if_hmastlock [t];
      assign mst_HREADY    [t][1] = ahb3_if_hready    [t];

      assign mst_HREADYOUT [t][1] = 1'b0;

      assign ahb3_if_hrdata [t] = mst_HRDATA [t][1];
      //assign ahb3_if_hresp  [t] = mst_HRESP  [t][1];

      assign mst_HSEL      [t][2] = mst_gpio_HSEL      [t];
      assign mst_HADDR     [t][2] = mst_gpio_HADDR     [t];
      assign mst_HWDATA    [t][2] = mst_gpio_HWDATA    [t];
      assign mst_HWRITE    [t][2] = mst_gpio_HWRITE    [t];
      assign mst_HSIZE     [t][2] = mst_gpio_HSIZE     [t];
      assign mst_HBURST    [t][2] = mst_gpio_HBURST    [t];
      assign mst_HPROT     [t][2] = mst_gpio_HPROT     [t];
      assign mst_HTRANS    [t][2] = mst_gpio_HTRANS    [t];
      assign mst_HMASTLOCK [t][2] = mst_gpio_HMASTLOCK [t];
      assign mst_HREADY    [t][2] = mst_gpio_HREADY    [t];

      assign mst_gpio_HRDATA    [t] = mst_HRDATA    [t][2];
      assign mst_gpio_HREADYOUT [t] = mst_HREADYOUT [t][2];
      assign mst_gpio_HRESP     [t] = mst_HRESP     [t][2];

      assign mst_HSEL      [t][3] = mst_sram_HSEL      [t];
      assign mst_HADDR     [t][3] = mst_sram_HADDR     [t];
      assign mst_HWDATA    [t][3] = mst_sram_HWDATA    [t];
      assign mst_HWRITE    [t][3] = mst_sram_HWRITE    [t];
      assign mst_HSIZE     [t][3] = mst_sram_HSIZE     [t];
      assign mst_HBURST    [t][3] = mst_sram_HBURST    [t];
      assign mst_HPROT     [t][3] = mst_sram_HPROT     [t];
      assign mst_HTRANS    [t][3] = mst_sram_HTRANS    [t];
      assign mst_HMASTLOCK [t][3] = mst_sram_HMASTLOCK [t];
      assign mst_HREADY    [t][3] = mst_sram_HREADY    [t];

      assign mst_sram_HRDATA    [t] = mst_HRDATA    [t][3];
      assign mst_sram_HREADYOUT [t] = mst_HREADYOUT [t][3];
      assign mst_sram_HRESP     [t] = mst_HRESP     [t][3];

      assign mst_HSEL      [t][4] = mst_mram_HSEL      [t];
      assign mst_HADDR     [t][4] = mst_mram_HADDR     [t];
      assign mst_HWDATA    [t][4] = mst_mram_HWDATA    [t];
      assign mst_HWRITE    [t][4] = mst_mram_HWRITE    [t];
      assign mst_HSIZE     [t][4] = mst_mram_HSIZE     [t];
      assign mst_HBURST    [t][4] = mst_mram_HBURST    [t];
      assign mst_HPROT     [t][4] = mst_mram_HPROT     [t];
      assign mst_HTRANS    [t][4] = mst_mram_HTRANS    [t];
      assign mst_HMASTLOCK [t][4] = mst_mram_HMASTLOCK [t];
      assign mst_HREADY    [t][4] = mst_mram_HREADY    [t];

      assign mst_mram_HRDATA    [t] = mst_HRDATA    [t][4];
      assign mst_mram_HREADYOUT [t] = mst_HREADYOUT [t][4];
      assign mst_mram_HRESP     [t] = mst_HRESP     [t][4];

      // SLV Connections
      assign slv_HSEL      [t][0] = ahb3_hsel      [t];
      assign slv_HADDR     [t][0] = ahb3_haddr     [t];
      assign slv_HWDATA    [t][0] = ahb3_hwdata    [t];
      assign slv_HWRITE    [t][0] = ahb3_hwrite    [t];
      assign slv_HSIZE     [t][0] = ahb3_hsize     [t];
      assign slv_HBURST    [t][0] = ahb3_hburst    [t];
      assign slv_HPROT     [t][0] = ahb3_hprot     [t];
      assign slv_HTRANS    [t][0] = ahb3_htrans    [t];
      assign slv_HMASTLOCK [t][0] = ahb3_hmastlock [t];
      assign slv_HREADY    [t][0] = ahb3_hready    [t];

      assign slv_HRDATA    [t][0] = ahb3_hrdata    [t];
      assign slv_HRESP     [t][0] = 1'b0;
    end
  endgenerate

  //get highest priority from selected masters
  assign requested_priority_lvl = highest_requested_priority(bus_dat_HSEL);

  //get pending masters for the highest priority requested
  assign priority_misd_masters = requesters(bus_dat_HSEL, requested_priority_lvl);

  //get last granted master for the priority requested
  assign last_granted_misd_master = last_granted_misd_masters[requested_priority_lvl];

  //get next master to serve
  assign pending_misd_master = nxt_misd_master(priority_misd_masters, last_granted_misd_master, granted_misd_master);

  //select new master
  always @(posedge HCLK, negedge HRESETn) begin
    if      ( !HRESETn  ) granted_misd_master <= 'h1;
    else if ( !dat_HSEL ) granted_misd_master <= pending_misd_master;
  end

  //store current master (for this priority level)
  always @(posedge HCLK, negedge HRESETn) begin
    if      ( !HRESETn  ) last_granted_misd_masters[requested_priority_lvl] <= 'h1;
    else if ( !dat_HSEL ) last_granted_misd_masters[requested_priority_lvl] <= pending_misd_master;
  end

  //get signals from current requester
  always @(posedge HCLK, negedge HRESETn) begin
    if      ( !HRESETn  ) granted_misd_master_idx <= 'h0;
    else if ( !dat_HSEL ) granted_misd_master_idx <= onehot2int(pending_misd_master);
  end

  always @(posedge HCLK) begin
    if (dat_HSEL) granted_misd_master_idx_dly <= granted_misd_master_idx;
  end

  assign dat_HSEL      = bus_dat_HSEL      [granted_misd_master_idx];
  assign dat_HADDR     = bus_dat_HADDR     [granted_misd_master_idx];
  assign dat_HWDATA    = bus_dat_HWDATA    [granted_misd_master_idx_dly];
  assign dat_HWRITE    = bus_dat_HWRITE    [granted_misd_master_idx];
  assign dat_HSIZE     = bus_dat_HSIZE     [granted_misd_master_idx];
  assign dat_HBURST    = bus_dat_HBURST    [granted_misd_master_idx];
  assign dat_HPROT     = bus_dat_HPROT     [granted_misd_master_idx];
  assign dat_HTRANS    = bus_dat_HTRANS    [granted_misd_master_idx];
  assign dat_HMASTLOCK = bus_dat_HMASTLOCK [granted_misd_master_idx];

  generate
    for(t=0; t < CORES_PER_MISD; t=t+1) begin
      assign bus_dat_HRDATA [t] = dat_HRDATA;
      assign bus_dat_HREADY [t] = dat_HREADY;
      assign bus_dat_HRESP  [t] = dat_HRESP;
    end
  endgenerate

  //Instantiate RISC-V RAM
  mpsoc_mpram #(
    .MEM_SIZE          ( 0 ),
    .MEM_DEPTH         ( 256 ),
    .HADDR_SIZE        ( PLEN ),
    .HDATA_SIZE        ( XLEN ),
    .CORES_PER_TILE    ( CORES_PER_MISD ),
    .TECHNOLOGY        ( TECHNOLOGY ),
    .REGISTERED_OUTPUT ( "NO" )
  )
  mpram (
    //AHB Slave Interface
    .HRESETn   ( HRESETn ),
    .HCLK      ( HCLK    ),

    .HSEL      ( mst_mram_HSEL      ),
    .HADDR     ( mst_mram_HADDR     ),
    .HWDATA    ( mst_mram_HWDATA    ),
    .HRDATA    ( mst_mram_HRDATA    ),
    .HWRITE    ( mst_mram_HWRITE    ),
    .HSIZE     ( mst_mram_HSIZE     ),
    .HBURST    ( mst_mram_HBURST    ),
    .HPROT     ( mst_mram_HPROT     ),
    .HTRANS    ( mst_mram_HTRANS    ),
    .HMASTLOCK ( mst_mram_HMASTLOCK ),
    .HREADYOUT ( mst_mram_HREADYOUT ),
    .HREADY    ( mst_mram_HREADY    ),
    .HRESP     ( mst_mram_HRESP     )
  );

  //Instantiate LNKs
  mpsoc_noc_mux #(
    .FLIT_WIDTH ( FLIT_WIDTH     ),
    .CHANNELS   ( CORES_PER_MISD )
  )
  noc_mux_lnk1 (
    .clk ( HRESETn ),
    .rst ( HCLK    ),

    .in_flit   ( noc_output_flit  ),
    .in_last   ( noc_output_last  ),
    .in_valid  ( noc_output_valid ),
    .in_ready  ( noc_output_ready ),

    .out_flit  ( linked1_flit  ),
    .out_last  ( linked1_last  ),
    .out_valid ( linked1_valid ),
    .out_ready ( linked1_ready )
  );

  mpsoc_noc_demux #(
    .FLIT_WIDTH ( FLIT_WIDTH     ),
    .CHANNELS   ( CORES_PER_MISD ),
    .MAPPING    ()
  )
  noc_demux_lnk0 (
    .clk ( HRESETn ),
    .rst ( HCLK    ),

    .in_flit   ( linked0_flit  ),
    .in_last   ( linked0_last  ),
    .in_valid  ( linked0_valid ),
    .in_ready  ( linked0_ready ),

    .out_flit  ( noc_input_flit  ),
    .out_last  ( noc_input_last  ),
    .out_valid ( noc_input_valid ),
    .out_ready ( noc_input_ready )
  );

  mpsoc_noc_mux #(
    .FLIT_WIDTH ( FLIT_WIDTH ),
    .CHANNELS   ( CHANNELS   )
  )
  noc_mux_lnk0 (
    .clk ( HRESETn ),
    .rst ( HCLK    ),

    .in_flit   ( noc_in_flit  ),
    .in_last   ( noc_in_last  ),
    .in_valid  ( noc_in_valid ),
    .in_ready  ( noc_in_ready ),

    .out_flit  ( linked0_flit  ),
    .out_last  ( linked0_last  ),
    .out_valid ( linked0_valid ),
    .out_ready ( linked0_ready )
  );

  mpsoc_noc_demux #(
    .FLIT_WIDTH ( FLIT_WIDTH ),
    .CHANNELS   ( CHANNELS   ),
    .MAPPING    ()
  )
  noc_demux_lnk1 (
    .clk ( HRESETn ),
    .rst ( HCLK    ),

    .in_flit   ( linked1_flit  ),
    .in_last   ( linked1_last  ),
    .in_valid  ( linked1_valid ),
    .in_ready  ( linked1_ready ),

    .out_flit  ( noc_out_flit  ),
    .out_last  ( noc_out_last  ),
    .out_valid ( noc_out_valid ),
    .out_ready ( noc_out_ready )
  );
endmodule
