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
//              Many Processors System on Chip                                //
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

module riscv_mpsoc #(
  parameter            XLEN               = 64,
  parameter            PLEN               = 64,
  parameter [XLEN-1:0] PC_INIT            = 'h8000_0000,
  parameter            HAS_USER           = 1,
  parameter            HAS_SUPER          = 1,
  parameter            HAS_HYPER          = 1,
  parameter            HAS_BPU            = 1,
  parameter            HAS_FPU            = 1,
  parameter            HAS_MMU            = 1,
  parameter            HAS_RVM            = 1,
  parameter            HAS_RVA            = 1,
  parameter            HAS_RVC            = 1,
  parameter            IS_RV32E           = 1,

  parameter            MULT_LATENCY       = 1,

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

  parameter            HADDR_SIZE         = PLEN,
  parameter            HDATA_SIZE         = XLEN,
  parameter            PADDR_SIZE         = PLEN,
  parameter            PDATA_SIZE         = XLEN,

  parameter            SYNC_DEPTH         = 3,

  parameter            CORES_PER_SIMD     = 4,
  parameter            CORES_PER_MISD     = 4,

  parameter            X                  = 2,
  parameter            Y                  = 2,
  parameter            Z                  = 2,

  parameter            NODES              = X*Y*Z,

  parameter            CHANNELS           = 7
)
  (
    //Common signals
    input                                 HRESETn,
    input                                 HCLK,

    //PMA configuration
    input logic [PMA_CNT -1:0][     13:0] pma_cfg_i,
    input logic [PMA_CNT -1:0][XLEN -1:0] pma_adr_i,

    //AHB instruction - Single Port
    output      [X-1:0][Y-1:0][Z-1:0]                          sins_simd_HSEL,
    output      [X-1:0][Y-1:0][Z-1:0][PLEN               -1:0] sins_simd_HADDR,
    output      [X-1:0][Y-1:0][Z-1:0][XLEN               -1:0] sins_simd_HWDATA,
    input       [X-1:0][Y-1:0][Z-1:0][XLEN               -1:0] sins_simd_HRDATA,
    output      [X-1:0][Y-1:0][Z-1:0]                          sins_simd_HWRITE,
    output      [X-1:0][Y-1:0][Z-1:0][                    2:0] sins_simd_HSIZE,
    output      [X-1:0][Y-1:0][Z-1:0][                    2:0] sins_simd_HBURST,
    output      [X-1:0][Y-1:0][Z-1:0][                    3:0] sins_simd_HPROT,
    output      [X-1:0][Y-1:0][Z-1:0][                    1:0] sins_simd_HTRANS,
    output      [X-1:0][Y-1:0][Z-1:0]                          sins_simd_HMASTLOCK,
    input       [X-1:0][Y-1:0][Z-1:0]                          sins_simd_HREADY,
    input       [X-1:0][Y-1:0][Z-1:0]                          sins_simd_HRESP,

    //AHB data - Single Port
    output      [X-1:0][Y-1:0][Z-1:0]                          sdat_misd_HSEL,
    output      [X-1:0][Y-1:0][Z-1:0][PLEN               -1:0] sdat_misd_HADDR,
    output      [X-1:0][Y-1:0][Z-1:0][XLEN               -1:0] sdat_misd_HWDATA,
    input       [X-1:0][Y-1:0][Z-1:0][XLEN               -1:0] sdat_misd_HRDATA,
    output      [X-1:0][Y-1:0][Z-1:0]                          sdat_misd_HWRITE,
    output      [X-1:0][Y-1:0][Z-1:0][                    2:0] sdat_misd_HSIZE,
    output      [X-1:0][Y-1:0][Z-1:0][                    2:0] sdat_misd_HBURST,
    output      [X-1:0][Y-1:0][Z-1:0][                    3:0] sdat_misd_HPROT,
    output      [X-1:0][Y-1:0][Z-1:0][                    1:0] sdat_misd_HTRANS,
    output      [X-1:0][Y-1:0][Z-1:0]                          sdat_misd_HMASTLOCK,
    input       [X-1:0][Y-1:0][Z-1:0]                          sdat_misd_HREADY,
    input       [X-1:0][Y-1:0][Z-1:0]                          sdat_misd_HRESP,

    //AHB instruction - Multi Port
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                          mins_misd_HSEL,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][PLEN               -1:0] mins_misd_HADDR,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][XLEN               -1:0] mins_misd_HWDATA,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][XLEN               -1:0] mins_misd_HRDATA,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                          mins_misd_HWRITE,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][                    2:0] mins_misd_HSIZE,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][                    2:0] mins_misd_HBURST,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][                    3:0] mins_misd_HPROT,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][                    1:0] mins_misd_HTRANS,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                          mins_misd_HMASTLOCK,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                          mins_misd_HREADY,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                          mins_misd_HRESP,

    //AHB data - Multi Port
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                          mdat_simd_HSEL,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][PLEN               -1:0] mdat_simd_HADDR,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][XLEN               -1:0] mdat_simd_HWDATA,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][XLEN               -1:0] mdat_simd_HRDATA,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                          mdat_simd_HWRITE,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][                    2:0] mdat_simd_HSIZE,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][                    2:0] mdat_simd_HBURST,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][                    3:0] mdat_simd_HPROT,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][                    1:0] mdat_simd_HTRANS,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                          mdat_simd_HMASTLOCK,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                          mdat_simd_HREADY,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                          mdat_simd_HRESP,

    //Interrupts Interface
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                          ext_misd_nmi,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                          ext_misd_tint,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                          ext_misd_sint,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][                    3:0] ext_misd_int,

    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                          ext_simd_nmi,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                          ext_simd_tint,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                          ext_simd_sint,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][                    3:0] ext_simd_int,

    //Debug Interface
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                          dbg_misd_stall,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                          dbg_misd_strb,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                          dbg_misd_we,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][PLEN               -1:0] dbg_misd_addr,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][XLEN               -1:0] dbg_misd_dati,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][XLEN               -1:0] dbg_misd_dato,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                          dbg_misd_ack,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0]                          dbg_misd_bp,

    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                          dbg_simd_stall,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                          dbg_simd_strb,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                          dbg_simd_we,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][PLEN               -1:0] dbg_simd_addr,
    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][XLEN               -1:0] dbg_simd_dati,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][XLEN               -1:0] dbg_simd_dato,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                          dbg_simd_ack,
    output      [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0]                          dbg_simd_bp,

    //GPIO Interface

    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][PDATA_SIZE         -1:0] gpio_misd_i,
    output reg  [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][PDATA_SIZE         -1:0] gpio_misd_o,
    output reg  [X-1:0][Y-1:0][Z-1:0][CORES_PER_MISD-1:0][PDATA_SIZE         -1:0] gpio_misd_oe,

    input       [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][PDATA_SIZE         -1:0] gpio_simd_i,
    output reg  [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][PDATA_SIZE         -1:0] gpio_simd_o,
    output reg  [X-1:0][Y-1:0][Z-1:0][CORES_PER_SIMD-1:0][PDATA_SIZE         -1:0] gpio_simd_oe
  );

  ////////////////////////////////////////////////////////////////
  //
  // Constans
  //
  localparam SYSTEM_VENDOR_ID = 2;
  localparam SYSTEM_DEVICE_ID = 2;
  localparam NUM_MODULES = 0;
  localparam MAX_PKT_LEN = 2;
  localparam SUBNET_BITS = 6;
  localparam LOCAL_SUBNET = 0;
  localparam DEBUG_ROUTER_BUFFER_SIZE = 4;

  parameter FLIT_WIDTH       = 34;
  parameter OUTPUTS          = 7;
  parameter ENABLE_VCHANNELS = 1;
  parameter BUFFER_SIZE_IN   = 4;
  parameter BUFFER_SIZE_OUT  = 4;

  ////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  genvar i, j, k;

  // Flits from NoC->tiles
  wire  [NODES-1:0][CHANNELS-1:0][FLIT_WIDTH-1:0] noc_misd_in_flit;
  wire  [NODES-1:0][CHANNELS-1:0]                 noc_misd_in_last;
  wire  [NODES-1:0][CHANNELS-1:0]                 noc_misd_in_valid;
  wire  [NODES-1:0][CHANNELS-1:0]                 noc_misd_in_ready;

  wire  [NODES-1:0][CHANNELS-1:0][FLIT_WIDTH-1:0] noc_simd_out_flit;
  wire  [NODES-1:0][CHANNELS-1:0]                 noc_simd_out_last;
  wire  [NODES-1:0][CHANNELS-1:0]                 noc_simd_out_valid;
  wire  [NODES-1:0][CHANNELS-1:0]                 noc_simd_out_ready;

  // Flits from tiles->NoC
  wire  [NODES-1:0][CHANNELS-1:0][FLIT_WIDTH-1:0] noc_misd_out_flit;
  wire  [NODES-1:0][CHANNELS-1:0]                 noc_misd_out_last;
  wire  [NODES-1:0][CHANNELS-1:0]                 noc_misd_out_valid;
  wire  [NODES-1:0][CHANNELS-1:0]                 noc_misd_out_ready;

  wire  [NODES-1:0][CHANNELS-1:0][FLIT_WIDTH-1:0] noc_simd_in_flit;
  wire  [NODES-1:0][CHANNELS-1:0]                 noc_simd_in_last;
  wire  [NODES-1:0][CHANNELS-1:0]                 noc_simd_in_valid;
  wire  [NODES-1:0][CHANNELS-1:0]                 noc_simd_in_ready;

  ////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  //Instantiate RISC-V NoC MISD
  mpsoc_noc_mesh #(
    .FLIT_WIDTH       (FLIT_WIDTH),
    .CHANNELS         (CHANNELS),
    .OUTPUTS          (OUTPUTS),
    .ENABLE_VCHANNELS (ENABLE_VCHANNELS),
    .X                (X),
    .Y                (Y),
    .Z                (Z),
    .NODES            (NODES),
    .BUFFER_SIZE_IN   (BUFFER_SIZE_IN),
    .BUFFER_SIZE_OUT  (BUFFER_SIZE_OUT)
  )
  mesh_misd (
    .rst       ( rst ),
    .clk       ( clk ),

    .in_flit   ( noc_misd_out_flit  ),
    .in_last   ( noc_misd_out_last  ),
    .in_valid  ( noc_misd_out_valid ),
    .in_ready  ( noc_misd_out_ready ),

    .out_flit  ( noc_misd_in_flit  ),
    .out_last  ( noc_misd_in_last  ),
    .out_valid ( noc_misd_in_valid ),
    .out_ready ( noc_misd_in_ready )
  );

  //Instantiate RISC-V NoC SIMD
  mpsoc_noc_mesh #(
    .FLIT_WIDTH       (FLIT_WIDTH),
    .CHANNELS         (CHANNELS),
    .OUTPUTS          (OUTPUTS),
    .ENABLE_VCHANNELS (ENABLE_VCHANNELS),
    .X                (X),
    .Y                (Y),
    .Z                (Z),
    .NODES            (NODES),
    .BUFFER_SIZE_IN   (BUFFER_SIZE_IN),
    .BUFFER_SIZE_OUT  (BUFFER_SIZE_OUT)
  )
  mesh_simd (
    .rst       ( rst ),
    .clk       ( clk ),

    .in_flit   ( noc_simd_out_flit  ),
    .in_last   ( noc_simd_out_last  ),
    .in_valid  ( noc_simd_out_valid ),
    .in_ready  ( noc_simd_out_ready ),

    .out_flit  ( noc_simd_in_flit  ),
    .out_last  ( noc_simd_in_last  ),
    .out_valid ( noc_simd_in_valid ),
    .out_ready ( noc_simd_in_ready )
  );

  //Instantiate RISC-V SoC
  generate
    for (i=0; i < X; i=i+1) begin
      for (j=0; j < Y; j=j+1) begin
        for (k=0; k < Z; k=k+1) begin
          riscv_soc #(
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

            .PARCEL_SIZE           ( PARCEL_SIZE ),

            .CORES_PER_SIMD        ( CORES_PER_SIMD ),
            .CORES_PER_MISD        ( CORES_PER_MISD ),

            .CHANNELS              ( CHANNELS )
          )
          soc (
            //Common signals
            .HRESETn       ( HRESETn ),
            .HCLK          ( HCLK    ),

            //PMA configuration
            .pma_cfg_i     ( pma_cfg_i ),
            .pma_adr_i     ( pma_adr_i ),

            //AHB instruction - Single Port
            .sins_simd_HSEL      ( sins_simd_HSEL      [i][j][k] ),
            .sins_simd_HADDR     ( sins_simd_HADDR     [i][j][k] ),
            .sins_simd_HWDATA    ( sins_simd_HWDATA    [i][j][k] ),
            .sins_simd_HRDATA    ( sins_simd_HRDATA    [i][j][k] ),
            .sins_simd_HWRITE    ( sins_simd_HWRITE    [i][j][k] ),
            .sins_simd_HSIZE     ( sins_simd_HSIZE     [i][j][k] ),
            .sins_simd_HBURST    ( sins_simd_HBURST    [i][j][k] ),
            .sins_simd_HPROT     ( sins_simd_HPROT     [i][j][k] ),
            .sins_simd_HTRANS    ( sins_simd_HTRANS    [i][j][k] ),
            .sins_simd_HMASTLOCK ( sins_simd_HMASTLOCK [i][j][k] ),
            .sins_simd_HREADY    ( sins_simd_HREADY    [i][j][k] ),
            .sins_simd_HRESP     ( sins_simd_HRESP     [i][j][k] ),

            //AHB data - Single Port
            .sdat_misd_HSEL      ( sdat_misd_HSEL      [i][j][k] ),
            .sdat_misd_HADDR     ( sdat_misd_HADDR     [i][j][k] ),
            .sdat_misd_HWDATA    ( sdat_misd_HWDATA    [i][j][k] ),
            .sdat_misd_HRDATA    ( sdat_misd_HRDATA    [i][j][k] ),
            .sdat_misd_HWRITE    ( sdat_misd_HWRITE    [i][j][k] ),
            .sdat_misd_HSIZE     ( sdat_misd_HSIZE     [i][j][k] ),
            .sdat_misd_HBURST    ( sdat_misd_HBURST    [i][j][k] ),
            .sdat_misd_HPROT     ( sdat_misd_HPROT     [i][j][k] ),
            .sdat_misd_HTRANS    ( sdat_misd_HTRANS    [i][j][k] ),
            .sdat_misd_HMASTLOCK ( sdat_misd_HMASTLOCK [i][j][k] ),
            .sdat_misd_HREADY    ( sdat_misd_HREADY    [i][j][k] ),
            .sdat_misd_HRESP     ( sdat_misd_HRESP     [i][j][k] ),

            //AHB instruction - Multi Port
            .mins_misd_HSEL      ( mins_misd_HSEL      [i][j][k] ),
            .mins_misd_HADDR     ( mins_misd_HADDR     [i][j][k] ),
            .mins_misd_HWDATA    ( mins_misd_HWDATA    [i][j][k] ),
            .mins_misd_HRDATA    ( mins_misd_HRDATA    [i][j][k] ),
            .mins_misd_HWRITE    ( mins_misd_HWRITE    [i][j][k] ),
            .mins_misd_HSIZE     ( mins_misd_HSIZE     [i][j][k] ),
            .mins_misd_HBURST    ( mins_misd_HBURST    [i][j][k] ),
            .mins_misd_HPROT     ( mins_misd_HPROT     [i][j][k] ),
            .mins_misd_HTRANS    ( mins_misd_HTRANS    [i][j][k] ),
            .mins_misd_HMASTLOCK ( mins_misd_HMASTLOCK [i][j][k] ),
            .mins_misd_HREADY    ( mins_misd_HREADY    [i][j][k] ),
            .mins_misd_HRESP     ( mins_misd_HRESP     [i][j][k] ),

            //AHB data - Multi Port
            .mdat_simd_HSEL      ( mdat_simd_HSEL      [i][j][k] ),
            .mdat_simd_HADDR     ( mdat_simd_HADDR     [i][j][k] ),
            .mdat_simd_HWDATA    ( mdat_simd_HWDATA    [i][j][k] ),
            .mdat_simd_HRDATA    ( mdat_simd_HRDATA    [i][j][k] ),
            .mdat_simd_HWRITE    ( mdat_simd_HWRITE    [i][j][k] ),
            .mdat_simd_HSIZE     ( mdat_simd_HSIZE     [i][j][k] ),
            .mdat_simd_HBURST    ( mdat_simd_HBURST    [i][j][k] ),
            .mdat_simd_HPROT     ( mdat_simd_HPROT     [i][j][k] ),
            .mdat_simd_HTRANS    ( mdat_simd_HTRANS    [i][j][k] ),
            .mdat_simd_HMASTLOCK ( mdat_simd_HMASTLOCK [i][j][k] ),
            .mdat_simd_HREADY    ( mdat_simd_HREADY    [i][j][k] ),
            .mdat_simd_HRESP     ( mdat_simd_HRESP     [i][j][k] ),

            //Interrupts Interface
            .ext_misd_nmi        ( ext_misd_nmi        [i][j][k] ),
            .ext_misd_tint       ( ext_misd_tint       [i][j][k] ),
            .ext_misd_sint       ( ext_misd_sint       [i][j][k] ),
            .ext_misd_int        ( ext_misd_int        [i][j][k] ),

            .ext_simd_nmi        ( ext_simd_nmi        [i][j][k] ),
            .ext_simd_tint       ( ext_simd_tint       [i][j][k] ),
            .ext_simd_sint       ( ext_simd_sint       [i][j][k] ),
            .ext_simd_int        ( ext_simd_int        [i][j][k] ),

            //Debug Interface
            .dbg_simd_stall      ( dbg_simd_stall      [i][j][k] ),
            .dbg_simd_strb       ( dbg_simd_strb       [i][j][k] ),
            .dbg_simd_we         ( dbg_simd_we         [i][j][k] ),
            .dbg_simd_addr       ( dbg_simd_addr       [i][j][k] ),
            .dbg_simd_dati       ( dbg_simd_dati       [i][j][k] ),
            .dbg_simd_dato       ( dbg_simd_dato       [i][j][k] ),
            .dbg_simd_ack        ( dbg_simd_ack        [i][j][k] ),
            .dbg_simd_bp         ( dbg_simd_bp         [i][j][k] ),

            .dbg_misd_stall      ( dbg_misd_stall      [i][j][k] ),
            .dbg_misd_strb       ( dbg_misd_strb       [i][j][k] ),
            .dbg_misd_we         ( dbg_misd_we         [i][j][k] ),
            .dbg_misd_addr       ( dbg_misd_addr       [i][j][k] ),
            .dbg_misd_dati       ( dbg_misd_dati       [i][j][k] ),
            .dbg_misd_dato       ( dbg_misd_dato       [i][j][k] ),
            .dbg_misd_ack        ( dbg_misd_ack        [i][j][k] ),
            .dbg_misd_bp         ( dbg_misd_bp         [i][j][k] ),

            //GPIO Interface
            .gpio_simd_i         ( gpio_simd_i         [i][j][k] ),
            .gpio_simd_o         ( gpio_simd_o         [i][j][k] ),
            .gpio_simd_oe        ( gpio_simd_oe        [i][j][k] ),

            .gpio_misd_i         ( gpio_misd_i         [i][j][k] ),
            .gpio_misd_o         ( gpio_misd_o         [i][j][k] ),
            .gpio_misd_oe        ( gpio_misd_oe        [i][j][k] ),

            //NoC Interface
            .noc_misd_in_flit    ( noc_misd_in_flit    [(i+1)*(j+1)*(k+1)-1] ),
            .noc_misd_in_last    ( noc_misd_in_last    [(i+1)*(j+1)*(k+1)-1] ),
            .noc_misd_in_valid   ( noc_misd_in_valid   [(i+1)*(j+1)*(k+1)-1] ),
            .noc_misd_in_ready   ( noc_misd_in_ready   [(i+1)*(j+1)*(k+1)-1] ),
            .noc_misd_out_flit   ( noc_misd_out_flit   [(i+1)*(j+1)*(k+1)-1] ),
            .noc_misd_out_last   ( noc_misd_out_last   [(i+1)*(j+1)*(k+1)-1] ),
            .noc_misd_out_valid  ( noc_misd_out_valid  [(i+1)*(j+1)*(k+1)-1] ),
            .noc_misd_out_ready  ( noc_misd_out_ready  [(i+1)*(j+1)*(k+1)-1] ),

            .noc_simd_in_flit    ( noc_simd_in_flit    [(i+1)*(j+1)*(k+1)-1] ),
            .noc_simd_in_last    ( noc_simd_in_last    [(i+1)*(j+1)*(k+1)-1] ),
            .noc_simd_in_valid   ( noc_simd_in_valid   [(i+1)*(j+1)*(k+1)-1] ),
            .noc_simd_in_ready   ( noc_simd_in_ready   [(i+1)*(j+1)*(k+1)-1] ),
            .noc_simd_out_flit   ( noc_simd_out_flit   [(i+1)*(j+1)*(k+1)-1] ),
            .noc_simd_out_last   ( noc_simd_out_last   [(i+1)*(j+1)*(k+1)-1] ),
            .noc_simd_out_valid  ( noc_simd_out_valid  [(i+1)*(j+1)*(k+1)-1] ),
            .noc_simd_out_ready  ( noc_simd_out_ready  [(i+1)*(j+1)*(k+1)-1] )
          );
        end
      end
    end
  endgenerate
endmodule
