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
//              System on Chip                                                //
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

module riscv_soc #(
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

  parameter            HADDR_SIZE         = PLEN,
  parameter            HDATA_SIZE         = XLEN,
  parameter            PADDR_SIZE         = PLEN,
  parameter            PDATA_SIZE         = XLEN,

  parameter            FLIT_WIDTH         = 34,

  parameter            SYNC_DEPTH         = 3,

  parameter            CORES_PER_SIMD     = 8,
  parameter            CORES_PER_MISD     = 8,

  parameter            CORES_PER_TILE     = CORES_PER_SIMD + CORES_PER_MISD,

  parameter            CHANNELS           = 2
)
  (
    //Common signals
    input                                          HRESETn,
    input                                          HCLK,

    //PMA configuration
    input logic [PMA_CNT  -1:0][             13:0] pma_cfg_i,
    input logic [PMA_CNT  -1:0][XLEN         -1:0] pma_adr_i,

    //AHB instruction - Single Port
    output                                         sins_simd_HSEL,
    output      [PLEN                        -1:0] sins_simd_HADDR,
    output      [XLEN                        -1:0] sins_simd_HWDATA,
    input       [XLEN                        -1:0] sins_simd_HRDATA,
    output                                         sins_simd_HWRITE,
    output      [                             2:0] sins_simd_HSIZE,
    output      [                             2:0] sins_simd_HBURST,
    output      [                             3:0] sins_simd_HPROT,
    output      [                             1:0] sins_simd_HTRANS,
    output                                         sins_simd_HMASTLOCK,
    input                                          sins_simd_HREADY,
    input                                          sins_simd_HRESP,

    //AHB data - Single Port
    output                                         sdat_misd_HSEL,
    output      [PLEN                        -1:0] sdat_misd_HADDR,
    output      [XLEN                        -1:0] sdat_misd_HWDATA,
    input       [XLEN                        -1:0] sdat_misd_HRDATA,
    output                                         sdat_misd_HWRITE,
    output      [                             2:0] sdat_misd_HSIZE,
    output      [                             2:0] sdat_misd_HBURST,
    output      [                             3:0] sdat_misd_HPROT,
    output      [                             1:0] sdat_misd_HTRANS,
    output                                         sdat_misd_HMASTLOCK,
    input                                          sdat_misd_HREADY,
    input                                          sdat_misd_HRESP,

    //AHB instruction - Multi Port
    output      [CORES_PER_MISD-1:0]                                   mins_misd_HSEL,
    output      [CORES_PER_MISD-1:0][PLEN                        -1:0] mins_misd_HADDR,
    output      [CORES_PER_MISD-1:0][XLEN                        -1:0] mins_misd_HWDATA,
    input       [CORES_PER_MISD-1:0][XLEN                        -1:0] mins_misd_HRDATA,
    output      [CORES_PER_MISD-1:0]                                   mins_misd_HWRITE,
    output      [CORES_PER_MISD-1:0][                             2:0] mins_misd_HSIZE,
    output      [CORES_PER_MISD-1:0][                             2:0] mins_misd_HBURST,
    output      [CORES_PER_MISD-1:0][                             3:0] mins_misd_HPROT,
    output      [CORES_PER_MISD-1:0][                             1:0] mins_misd_HTRANS,
    output      [CORES_PER_MISD-1:0]                                   mins_misd_HMASTLOCK,
    input       [CORES_PER_MISD-1:0]                                   mins_misd_HREADY,
    input       [CORES_PER_MISD-1:0]                                   mins_misd_HRESP,

    //AHB data - Multi Port
    output      [CORES_PER_SIMD-1:0]                                   mdat_simd_HSEL,
    output      [CORES_PER_SIMD-1:0][PLEN                        -1:0] mdat_simd_HADDR,
    output      [CORES_PER_SIMD-1:0][XLEN                        -1:0] mdat_simd_HWDATA,
    input       [CORES_PER_SIMD-1:0][XLEN                        -1:0] mdat_simd_HRDATA,
    output      [CORES_PER_SIMD-1:0]                                   mdat_simd_HWRITE,
    output      [CORES_PER_SIMD-1:0][                             2:0] mdat_simd_HSIZE,
    output      [CORES_PER_SIMD-1:0][                             2:0] mdat_simd_HBURST,
    output      [CORES_PER_SIMD-1:0][                             3:0] mdat_simd_HPROT,
    output      [CORES_PER_SIMD-1:0][                             1:0] mdat_simd_HTRANS,
    output      [CORES_PER_SIMD-1:0]                                   mdat_simd_HMASTLOCK,
    input       [CORES_PER_SIMD-1:0]                                   mdat_simd_HREADY,
    input       [CORES_PER_SIMD-1:0]                                   mdat_simd_HRESP,

    //Interrupts Interface
    input       [CORES_PER_MISD-1:0]                                   ext_misd_nmi,
    input       [CORES_PER_MISD-1:0]                                   ext_misd_tint,
    input       [CORES_PER_MISD-1:0]                                   ext_misd_sint,
    input       [CORES_PER_MISD-1:0][                             3:0] ext_misd_int,

    input       [CORES_PER_SIMD-1:0]                                   ext_simd_nmi,
    input       [CORES_PER_SIMD-1:0]                                   ext_simd_tint,
    input       [CORES_PER_SIMD-1:0]                                   ext_simd_sint,
    input       [CORES_PER_SIMD-1:0][                             3:0] ext_simd_int,

    //Debug Interface
    input       [CORES_PER_MISD-1:0]                                   dbg_misd_stall,
    input       [CORES_PER_MISD-1:0]                                   dbg_misd_strb,
    input       [CORES_PER_MISD-1:0]                                   dbg_misd_we,
    input       [CORES_PER_MISD-1:0][PLEN                        -1:0] dbg_misd_addr,
    input       [CORES_PER_MISD-1:0][XLEN                        -1:0] dbg_misd_dati,
    output      [CORES_PER_MISD-1:0][XLEN                        -1:0] dbg_misd_dato,
    output      [CORES_PER_MISD-1:0]                                   dbg_misd_ack,
    output      [CORES_PER_MISD-1:0]                                   dbg_misd_bp,

    input       [CORES_PER_SIMD-1:0]                                   dbg_simd_stall,
    input       [CORES_PER_SIMD-1:0]                                   dbg_simd_strb,
    input       [CORES_PER_SIMD-1:0]                                   dbg_simd_we,
    input       [CORES_PER_SIMD-1:0][PLEN                        -1:0] dbg_simd_addr,
    input       [CORES_PER_SIMD-1:0][XLEN                        -1:0] dbg_simd_dati,
    output      [CORES_PER_SIMD-1:0][XLEN                        -1:0] dbg_simd_dato,
    output      [CORES_PER_SIMD-1:0]                                   dbg_simd_ack,
    output      [CORES_PER_SIMD-1:0]                                   dbg_simd_bp,

    //GPIO Interface
    input       [CORES_PER_MISD-1:0][PDATA_SIZE-1:0] gpio_misd_i,
    output reg  [CORES_PER_MISD-1:0][PDATA_SIZE-1:0] gpio_misd_o,
    output reg  [CORES_PER_MISD-1:0][PDATA_SIZE-1:0] gpio_misd_oe,

    input       [CORES_PER_SIMD-1:0][PDATA_SIZE-1:0] gpio_simd_i,
    output reg  [CORES_PER_SIMD-1:0][PDATA_SIZE-1:0] gpio_simd_o,
    output reg  [CORES_PER_SIMD-1:0][PDATA_SIZE-1:0] gpio_simd_oe,

    //NoC Interface
    input       [CHANNELS -1:0][FLIT_WIDTH-1:0] noc_misd_in_flit,
    input       [CHANNELS -1:0]                 noc_misd_in_last,
    input       [CHANNELS -1:0]                 noc_misd_in_valid,
    output      [CHANNELS -1:0]                 noc_misd_in_ready,
    output      [CHANNELS -1:0][FLIT_WIDTH-1:0] noc_misd_out_flit,
    output      [CHANNELS -1:0]                 noc_misd_out_last,
    output      [CHANNELS -1:0]                 noc_misd_out_valid,
    input       [CHANNELS -1:0]                 noc_misd_out_ready,

    input       [CHANNELS -1:0][FLIT_WIDTH-1:0] noc_simd_in_flit,
    input       [CHANNELS -1:0]                 noc_simd_in_last,
    input       [CHANNELS -1:0]                 noc_simd_in_valid,
    output      [CHANNELS -1:0]                 noc_simd_in_ready,
    output      [CHANNELS -1:0][FLIT_WIDTH-1:0] noc_simd_out_flit,
    output      [CHANNELS -1:0]                 noc_simd_out_last,
    output      [CHANNELS -1:0]                 noc_simd_out_valid,
    input       [CHANNELS -1:0]                 noc_simd_out_ready
  );

  ////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  //Instantiate RISC-V MISD
  if (CORES_PER_MISD > 0)
    riscv_misd #(
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

      .HADDR_SIZE            ( HADDR_SIZE ),
      .HDATA_SIZE            ( HDATA_SIZE ),
      .PADDR_SIZE            ( PADDR_SIZE ),
      .PDATA_SIZE            ( PDATA_SIZE ),

      .SYNC_DEPTH            ( SYNC_DEPTH ),

      .CORES_PER_MISD        ( CORES_PER_MISD ),

      .CHANNELS              ( CHANNELS )
    )
    misd_soc (
      //Common signals
      .HRESETn ( HRESETn ),
      .HCLK    ( HCLK    ),

      //PMA configuration
      .pma_cfg_i     ( pma_cfg_i ),
      .pma_adr_i     ( pma_adr_i ),

      //AHB Instruction
      .ins_HSEL      ( mins_misd_HSEL      ),
      .ins_HADDR     ( mins_misd_HADDR     ),
      .ins_HWDATA    ( mins_misd_HWDATA    ),
      .ins_HRDATA    ( mins_misd_HRDATA    ),
      .ins_HWRITE    ( mins_misd_HWRITE    ),
      .ins_HSIZE     ( mins_misd_HSIZE     ),
      .ins_HBURST    ( mins_misd_HBURST    ),
      .ins_HPROT     ( mins_misd_HPROT     ),
      .ins_HTRANS    ( mins_misd_HTRANS    ),
      .ins_HMASTLOCK ( mins_misd_HMASTLOCK ),
      .ins_HREADY    ( mins_misd_HREADY    ),
      .ins_HRESP     ( mins_misd_HRESP     ),

      //AHB Data
      .dat_HSEL      ( sdat_misd_HSEL      ),
      .dat_HADDR     ( sdat_misd_HADDR     ),
      .dat_HWDATA    ( sdat_misd_HWDATA    ),
      .dat_HRDATA    ( sdat_misd_HRDATA    ),
      .dat_HWRITE    ( sdat_misd_HWRITE    ),
      .dat_HSIZE     ( sdat_misd_HSIZE     ),
      .dat_HBURST    ( sdat_misd_HBURST    ),
      .dat_HPROT     ( sdat_misd_HPROT     ),
      .dat_HTRANS    ( sdat_misd_HTRANS    ),
      .dat_HMASTLOCK ( sdat_misd_HMASTLOCK ),
      .dat_HREADY    ( sdat_misd_HREADY    ),
      .dat_HRESP     ( sdat_misd_HRESP     ),

      //Interrupts Interface
      .ext_nmi       ( ext_misd_nmi        ),
      .ext_tint      ( ext_misd_tint       ),
      .ext_sint      ( ext_misd_sint       ),
      .ext_int       ( ext_misd_int        ),

      //Debug Interface
      .dbg_stall     ( dbg_misd_stall      ),
      .dbg_strb      ( dbg_misd_strb       ),
      .dbg_we        ( dbg_misd_we         ),
      .dbg_addr      ( dbg_misd_addr       ),
      .dbg_dati      ( dbg_misd_dati       ),
      .dbg_dato      ( dbg_misd_dato       ),
      .dbg_ack       ( dbg_misd_ack        ),
      .dbg_bp        ( dbg_misd_bp         ),

      //GPIO Interface
      .gpio_i        ( gpio_misd_i         ),
      .gpio_o        ( gpio_misd_o         ),
      .gpio_oe       ( gpio_misd_oe        ),

      //NoC Interface
      .noc_in_flit   ( noc_misd_in_flit    ),
      .noc_in_last   ( noc_misd_in_last    ),
      .noc_in_valid  ( noc_misd_in_valid   ),
      .noc_in_ready  ( noc_misd_in_ready   ),
      .noc_out_flit  ( noc_misd_out_flit   ),
      .noc_out_last  ( noc_misd_out_last   ),
      .noc_out_valid ( noc_misd_out_valid  ),
      .noc_out_ready ( noc_misd_out_ready  )
    );

  //Instantiate RISC-V SIMD
  if (CORES_PER_SIMD > 0)
    riscv_simd #(
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

      .HADDR_SIZE            ( HADDR_SIZE ),
      .HDATA_SIZE            ( HDATA_SIZE ),
      .PADDR_SIZE            ( PADDR_SIZE ),
      .PDATA_SIZE            ( PDATA_SIZE ),

      .SYNC_DEPTH            ( SYNC_DEPTH ),

      .CORES_PER_SIMD        ( CORES_PER_SIMD ),

      .CHANNELS              ( CHANNELS )
    )
    simd_soc (
      //Common signals
      .HRESETn ( HRESETn ),
      .HCLK    ( HCLK    ),

      //PMA configuration
      .pma_cfg_i     ( pma_cfg_i ),
      .pma_adr_i     ( pma_adr_i ),

      //AHB Instruction
      .ins_HSEL      ( sins_simd_HSEL      ),
      .ins_HADDR     ( sins_simd_HADDR     ),
      .ins_HWDATA    ( sins_simd_HWDATA    ),
      .ins_HRDATA    ( sins_simd_HRDATA    ),
      .ins_HWRITE    ( sins_simd_HWRITE    ),
      .ins_HSIZE     ( sins_simd_HSIZE     ),
      .ins_HBURST    ( sins_simd_HBURST    ),
      .ins_HPROT     ( sins_simd_HPROT     ),
      .ins_HTRANS    ( sins_simd_HTRANS    ),
      .ins_HMASTLOCK ( sins_simd_HMASTLOCK ),
      .ins_HREADY    ( sins_simd_HREADY    ),
      .ins_HRESP     ( sins_simd_HRESP     ),

      //AHB Data
      .dat_HSEL      ( mdat_simd_HSEL      ),
      .dat_HADDR     ( mdat_simd_HADDR     ),
      .dat_HWDATA    ( mdat_simd_HWDATA    ),
      .dat_HRDATA    ( mdat_simd_HRDATA    ),
      .dat_HWRITE    ( mdat_simd_HWRITE    ),
      .dat_HSIZE     ( mdat_simd_HSIZE     ),
      .dat_HBURST    ( mdat_simd_HBURST    ),
      .dat_HPROT     ( mdat_simd_HPROT     ),
      .dat_HTRANS    ( mdat_simd_HTRANS    ),
      .dat_HMASTLOCK ( mdat_simd_HMASTLOCK ),
      .dat_HREADY    ( mdat_simd_HREADY    ),
      .dat_HRESP     ( mdat_simd_HRESP     ),

      //Interrupts Interface
      .ext_nmi       ( ext_simd_nmi        ),
      .ext_tint      ( ext_simd_tint       ),
      .ext_sint      ( ext_simd_sint       ),
      .ext_int       ( ext_simd_int        ),

      //Debug Interface
      .dbg_stall     ( dbg_simd_stall      ),
      .dbg_strb      ( dbg_simd_strb       ),
      .dbg_we        ( dbg_simd_we         ),
      .dbg_addr      ( dbg_simd_addr       ),
      .dbg_dati      ( dbg_simd_dati       ),
      .dbg_dato      ( dbg_simd_dato       ),
      .dbg_ack       ( dbg_simd_ack        ),
      .dbg_bp        ( dbg_simd_bp         ),

      //GPIO Interface
      .gpio_i        ( gpio_simd_i         ),
      .gpio_o        ( gpio_simd_o         ),
      .gpio_oe       ( gpio_simd_oe        ),

      //NoC Interface
      .noc_in_flit   ( noc_simd_in_flit    ),
      .noc_in_last   ( noc_simd_in_last    ),
      .noc_in_valid  ( noc_simd_in_valid   ),
      .noc_in_ready  ( noc_simd_in_ready   ),
      .noc_out_flit  ( noc_simd_out_flit   ),
      .noc_out_last  ( noc_simd_out_last   ),
      .noc_out_valid ( noc_simd_out_valid  ),
      .noc_out_ready ( noc_simd_out_ready  )
    );
endmodule
