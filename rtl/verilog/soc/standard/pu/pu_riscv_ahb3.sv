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
//              WishBone Bus Interface                                        //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018-2019 by the author(s)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////
// Author(s):
//   Paco Reina Campo <pacoreinacampo@queenfield.tech>

import peripheral_ahb3_verilog_pkg::*;
import pu_riscv_verilog_pkg::*;

module pu_riscv_ahb3 #(
  parameter TECHNOLOGY = "Generic",

  // JTAG options (TAP)
  //                  [31:28] Version - to be specified by customer

  //                  Part Number:
  //                  [27:16]         - to be provided by customer 
  // 0000             [15:12] system (adv_dbg) revision

  //                  Manufacturer:
  // 1001             [11: 8] bank (bank10)
  // 1101110          [ 7: 1] manufacturer id, without parity
  // 1                [    0] required by standard

  parameter [15:0] JTAG_USERIDCODE = 16'h0,  // upper 16-bit of IDCODE
  parameter [31:0] JTAG_USERCODE   = 32'h0,

  // CPU options
  parameter            XLEN      = 32,
  parameter            PLEN      = XLEN,
  parameter [XLEN-1:0] PC_INIT   = 'h200,
  parameter            HAS_USER  = 0,
  parameter            HAS_SUPER = 0,
  parameter            HAS_HYPER = 0,
  parameter            HAS_BPU   = 0,
  parameter            HAS_FPU   = 0,
  parameter            HAS_MMU   = 0,
  parameter            HAS_RVM   = 0,
  parameter            HAS_RVA   = 0,
  parameter            HAS_RVC   = 1,

  parameter MULT_LATENCY = 0,

  parameter BREAKPOINTS = 3,  // number of hardware breakpoints

  parameter PMA_CNT = 16,
  parameter PMP_CNT = 16,

  parameter BP_GLOBAL_BITS = 2,
  parameter BP_LOCAL_BITS  = 10,

  parameter ICACHE_SIZE        = 0,   // in KBytes
  parameter ICACHE_BLOCK_SIZE  = 32,  // in Bytes
  parameter ICACHE_WAYS        = 2,   // 'n'-way set associative
  parameter ICACHE_REPLACE_ALG = 0,

  parameter DCACHE_SIZE        = 0,   // in KBytes
  parameter DCACHE_BLOCK_SIZE  = 32,  // in Bytes
  parameter DCACHE_WAYS        = 2,   // 'n'-way set associative
  parameter DCACHE_REPLACE_ALG = 0,
  parameter WRITEBUFFER_SIZE   = 8    // number of entries in the write buffer
) (
  // global power-on reset (for JTAG TAP)
  input poweron_rstn,

  // JTAG interface (TAP controller)
  input  jtag_trstn,
  input  jtag_tck,
  input  jtag_tms,
  input  jtag_tdi,
  output jtag_tdo,
  output jtag_tdo_oe,

  // Address map configuration
  input pmacfg_t                   pma_cfg_i[PMA_CNT],
  input          [XLEN       -1:0] pma_adr_i[PMA_CNT],

  // AHB interfaces
  input HRESETn,
  input HCLK,

  output                   ins_HSEL,
  output [PLEN       -1:0] ins_HADDR,
  output [XLEN       -1:0] ins_HWDATA,
  input  [XLEN       -1:0] ins_HRDATA,
  output                   ins_HWRITE,
  output [HSIZE_SIZE -1:0] ins_HSIZE,
  output [HBURST_SIZE-1:0] ins_HBURST,
  output [HPROT_SIZE -1:0] ins_HPROT,
  output [HTRANS_SIZE-1:0] ins_HTRANS,
  output                   ins_HMASTLOCK,
  input                    ins_HREADY,
  input                    ins_HRESP,

  output                   dat_HSEL,
  output [PLEN       -1:0] dat_HADDR,
  output [XLEN       -1:0] dat_HWDATA,
  input  [XLEN       -1:0] dat_HRDATA,
  output                   dat_HWRITE,
  output [HSIZE_SIZE -1:0] dat_HSIZE,
  output [HBURST_SIZE-1:0] dat_HBURST,
  output [HPROT_SIZE -1:0] dat_HPROT,
  output [HTRANS_SIZE-1:0] dat_HTRANS,
  output                   dat_HMASTLOCK,
  input                    dat_HREADY,
  input                    dat_HRESP,

  // Debug Memory Interface
  output                   dbg_HSEL,
  output [PLEN       -1:0] dbg_HADDR,
  output [XLEN       -1:0] dbg_HWDATA,
  input  [XLEN       -1:0] dbg_HRDATA,
  output                   dbg_HWRITE,
  output [HSIZE_SIZE -1:0] dbg_HSIZE,
  output [HBURST_SIZE-1:0] dbg_HBURST,
  output [HPROT_SIZE -1:0] dbg_HPROT,
  output [HTRANS_SIZE-1:0] dbg_HTRANS,
  output                   dbg_HMASTLOCK,
  input                    dbg_HREADY,
  input                    dbg_HRESP,

  output dbg_sysrst,

  // Debug JSP Interface
  input PRESETn,
  input PCLK,

  input        jsp_PSEL,
  input        jsp_PENABLE,
  input        jsp_PWRITE,
  input  [2:0] jsp_PADDR,
  input  [7:0] jsp_PWDATA,
  output [7:0] jsp_PRDATA,
  output       jsp_PREADY,
  output       jsp_PSLVERR,

  output jsp_int,

  // Interrupts
  input       ext_nmi,
  input       ext_tint,
  input       ext_sint,
  input [3:0] ext_int
);

  initial begin
    $display("ICACHE_SIZE=%0d", ICACHE_SIZE);
    $display("DCACHE_SIZE=%0d", DCACHE_SIZE);
  end

  //////////////////////////////////////////////////////////////////////////////
  // Constants
  //////////////////////////////////////////////////////////////////////////////

  localparam [3:0] JTAG_SYSREV = 0;  // System Revision
  localparam [3:0] JTAG_JEDEC_BANK = 9;  // 10th bank
  localparam [6:0] JTAG_JEDEC_ID = 7'h6E;  // bank10, ID6E = Roa Logic BV. No parity bit
  localparam [31:0] JTAG_IDCODE = {JTAG_USERIDCODE, JTAG_SYSREV, JTAG_JEDEC_BANK, JTAG_JEDEC_ID, 1'b1};

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////

  // TAP
  logic                     dbg_tck;
  logic                     dbg_tlr;
  logic                     dbg_sel;
  logic                     dbg_tdo;
  logic                     dbg_tdi;
  logic                     tap_tck;
  logic                     tap_CaptureDR;
  logic                     tap_ShiftDR;
  logic                     tap_PauseDR;
  logic                     tap_UpdateDR;

  // Debug Interface
  logic                     cpu_dbg_stall;
  logic                     cpu_dbg_strb;
  logic                     cpu_dbg_ack;
  logic                     cpu_dbg_we;
  logic                     cpu_dbg_bp;
  logic [DBG_ADDR_SIZE-1:0] cpu_dbg_addr;
  logic [         XLEN-1:0] cpu_dbg_dati;
  logic                     cpu_dbg_dato;

  // temporary dbg_HADDR in case PHYS_ADDR_SIZE is less than XLEN
  logic [         XLEN-1:0] tmp_HADDR;

  //////////////////////////////////////////////////////////////////////////////
  // Body
  //////////////////////////////////////////////////////////////////////////////

  // Instantiate RISC-V core
  riscv_top_ahb3lite #(
    .XLEN     (XLEN),
    .ALEN     (PLEN),
    .PC_INIT  (PC_INIT),
    .HAS_USER (HAS_USER),
    .HAS_SUPER(HAS_SUPER),
    .HAS_HYPER(HAS_HYPER),
    .HAS_BPU  (HAS_BPU),
    .HAS_FPU  (HAS_FPU),
    .HAS_MMU  (HAS_MMU),
    .HAS_RVM  (HAS_RVM),
    .HAS_RVA  (HAS_RVA),
    .HAS_RVC  (HAS_RVC),

    .MULT_LATENCY(MULT_LATENCY),

    .PMA_CNT(PMA_CNT),
    .PMP_CNT(PMP_CNT),

    .BP_GLOBAL_BITS(BP_GLOBAL_BITS),
    .BP_LOCAL_BITS (BP_LOCAL_BITS),

    .ICACHE_SIZE       (ICACHE_SIZE),
    .ICACHE_BLOCK_SIZE (ICACHE_BLOCK_SIZE),
    .ICACHE_WAYS       (ICACHE_WAYS),
    .ICACHE_REPLACE_ALG(ICACHE_REPLACE_ALG),

    .DCACHE_SIZE       (DCACHE_SIZE),
    .DCACHE_BLOCK_SIZE (DCACHE_BLOCK_SIZE),
    .DCACHE_WAYS       (DCACHE_WAYS),
    .DCACHE_REPLACE_ALG(DCACHE_REPLACE_ALG),

    .TECHNOLOGY(TECHNOLOGY)
  ) riscv_top (
    // AHB interfaces
    .HRESETn(HRESETn),
    .HCLK   (HCLK),

    .pma_cfg_i(pma_cfg_i),
    .pma_adr_i(pma_adr_i),

    .ins_HSEL     (ins_HSEL),
    .ins_HADDR    (ins_HADDR),
    .ins_HWDATA   (ins_HWDATA),
    .ins_HRDATA   (ins_HRDATA),
    .ins_HWRITE   (ins_HWRITE),
    .ins_HSIZE    (ins_HSIZE),
    .ins_HBURST   (ins_HBURST),
    .ins_HPROT    (ins_HPROT),
    .ins_HTRANS   (ins_HTRANS),
    .ins_HMASTLOCK(ins_HMASTLOCK),
    .ins_HREADY   (ins_HREADY),
    .ins_HRESP    (ins_HRESP),

    .dat_HSEL     (dat_HSEL),
    .dat_HADDR    (dat_HADDR),
    .dat_HWDATA   (dat_HWDATA),
    .dat_HRDATA   (dat_HRDATA),
    .dat_HWRITE   (dat_HWRITE),
    .dat_HSIZE    (dat_HSIZE),
    .dat_HBURST   (dat_HBURST),
    .dat_HPROT    (dat_HPROT),
    .dat_HTRANS   (dat_HTRANS),
    .dat_HMASTLOCK(dat_HMASTLOCK),
    .dat_HREADY   (dat_HREADY),
    .dat_HRESP    (dat_HRESP),

    // Interrupts
    .ext_nmi (ext_nmi),
    .ext_sint(ext_sint),
    .ext_tint(ext_tint),
    .ext_int (ext_int),

    // Debug Interface
    .dbg_stall(cpu_dbg_stall),
    .dbg_strb (cpu_dbg_strb),
    .dbg_we   (cpu_dbg_we),
    .dbg_addr (cpu_dbg_addr),
    .dbg_dati (cpu_dbg_dati),
    .dbg_dato (cpu_dbg_dato),
    .dbg_ack  (cpu_dbg_ack),
    .dbg_bp   (cpu_dbg_bp)
  );

  // Instantiate JTAG controller & Debug Controller
  universal_jtag_tap #(
    .TECHNOLOGY   (TECHNOLOGY),
    .JTAG_IDCODE  (JTAG_IDCODE),
    .JTAG_USERCODE(JTAG_USERCODE)
  ) tapctrl (
    .power_on_resetn(poweron_rstn),

    .jtag_trstn (jtag_trstn),
    .jtag_tck   (jtag_tck),
    .jtag_tms   (jtag_tms),
    .jtag_tdi   (jtag_tdi),
    .jtag_tdo   (jtag_tdo),
    .jtag_tdo_oe(jtag_tdo_oe),

    .tap_tck           (dbg_tck),
    .tap_TestLogicReset(dbg_tlr),
    .tap_CaptureDR     (tap_CaptureDR),
    .tap_ShiftDR       (tap_ShiftDR),
    .tap_PauseDR       (tap_PauseDR),
    .tap_UpdateDR      (tap_UpdateDR),

    .dbg_sel(dbg_sel),
    .dbg_tdo(dbg_tdo),
    .dbg_tdi(dbg_tdi)
  );

  adbg_top_ahb3 #(
    .ADDR_WIDTH (XLEN),
    .DATA_WIDTH (XLEN),
    .NB_CORES   (1),
    .DATAREG_LEN(64)     // must explain why 64
  ) adbg_ctrl (
    // JTAG signals
    .tck_i(dbg_tck),
    .tdi_i(dbg_tdi),
    .tdo_o(dbg_tdo),

    //TAP States
    .debug_select_i(dbg_sel),
    .tlr_i         (dbg_tlr),
    .shift_dr_i    (tap_ShiftDR),
    .pause_dr_i    (tap_PauseDR),
    .update_dr_i   (tap_UpdateDR),
    .capture_dr_i  (tap_CaptureDR),

    // CPU Debug Interface
    .cpu_rstn_i (HRESETn),
    .cpu_clk_i  (HCLK),
    .cpu_stb_o  ({cpu_dbg_strb}),
    .cpu_addr_o ({cpu_dbg_addr}),
    .cpu_we_o   ({cpu_dbg_we}),
    .cpu_data_i ({cpu_dbg_dato}),
    .cpu_data_o ({cpu_dbg_dati}),
    .cpu_bp_i   ({cpu_dbg_bp}),
    .cpu_stall_o({cpu_dbg_stall}),
    .cpu_rst_o  ({dbg_sysrst}),     // system reset, bring out to top-level
    .cpu_ack_i  ({cpu_dbg_ack}),

    // AHB Master Interface -- for memory access/debug
    .HCLK         (HCLK),
    .HRESETn      (HRESETn),
    .dbg_HSEL     (dbg_HSEL),
    .dbg_HADDR    (tmp_HADDR),
    .dbg_HWDATA   (dbg_HWDATA),
    .dbg_HRDATA   (dbg_HRDATA),
    .dbg_HWRITE   (dbg_HWRITE),
    .dbg_HSIZE    (dbg_HSIZE),
    .dbg_HBURST   (dbg_HBURST),
    .dbg_HPROT    (dbg_HPROT),
    .dbg_HTRANS   (dbg_HTRANS),
    .dbg_HMASTLOCK(dbg_HMASTLOCK),
    .dbg_HREADY   (dbg_HREADY),
    .dbg_HRESP    (dbg_HRESP),

    // APB Slave Interface Signals (JTAG Serial Port)
    .PRESETn    (PRESETn),
    .PCLK       (PCLK),
    .jsp_PSEL   (jsp_PSEL),
    .jsp_PENABLE(jsp_PENABLE),
    .jsp_PWRITE (jsp_PWRITE),
    .jsp_PADDR  (jsp_PADDR),
    .jsp_PWDATA (jsp_PWDATA),
    .jsp_PRDATA (jsp_PRDATA),
    .jsp_PREADY (jsp_PREADY),
    .jsp_PSLVERR(jsp_PSLVERR),
    .int_o      (jsp_int)
  );

  assign dbg_HADDR = tmp_HADDR[PLEN-1:0];
endmodule
