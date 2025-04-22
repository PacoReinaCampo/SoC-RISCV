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
// Copyright (c) 2019-2020 by the author(s)
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

import soc_optimsoc_functions::*;

module soc_sram_sp_ahb4 #(
  // Memory size in bytes
  parameter MEM_SIZE_BYTE = 'hx,

  // VMEM file used to initialize the memory in simulation
  parameter MEM_FILE = "sram.vmem",

  // address width
  parameter PLEN = $clog2(MEM_SIZE_BYTE),

  // data width (must be multiple of 8 for byte selects to work)
  // Valid values: 32,16 and 8
  parameter XLEN = 32,

  // byte select width
  localparam SW = (XLEN == 32) ? 4 : (XLEN == 16) ? 2 : (XLEN == 8) ? 1 : 'hx,

  // Allowed values:
  //   * PLAIN
  parameter MEM_IMPL_TYPE = "PLAIN",

  // +--------------+--------------+
  // | word address | byte in word |
  // +--------------+--------------+
  //     WORD_AW         BYTE_AW
  //        +---- PLEN ----+
 
  localparam BYTE_AW = SW >> 1,
  localparam WORD_AW = PLEN - BYTE_AW
) (
  // AHB4 SLAVE interface
  input            ahb4_hsel_i,
  input [PLEN-1:0] ahb4_haddr_i,
  input [XLEN-1:0] ahb4_hwdata_i,
  input            ahb4_hwrite_i,
  input [     2:0] ahb4_hsize_i,
  input [     2:0] ahb4_hburst_i,
  input [SW  -1:0] ahb4_hprot_i,
  input [     1:0] ahb4_htrans_i,
  input            ahb4_hmastlock_i,

  output [XLEN-1:0] ahb4_hrdata_o,
  output            ahb4_hready_o,
  output            ahb4_hresp_o,

  input ahb4_clk_i,
  input ahb4_rst_i
);

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////

  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [WORD_AW-1:0] sram_waddr;  // From ahb4_ram of soc_ahb42sram.v
  wire               sram_ce;  // From ahb4_ram of soc_ahb42sram.v
  wire [XLEN   -1:0] sram_din;  // From ahb4_ram of soc_ahb42sram.v
  wire [XLEN   -1:0] sram_dout;  // From sp_ram of soc_sram_sp.v
  wire [SW     -1:0] sram_sel;  // From ahb4_ram of soc_ahb42sram.v
  wire               sram_we;  // From ahb4_ram of soc_ahb42sram.v
  // End of automatics

  //////////////////////////////////////////////////////////////////////////////
  // Body
  //////////////////////////////////////////////////////////////////////////////

  soc_ahb42sram #(
    .PLEN(PLEN),
    .XLEN(XLEN)
  ) ahb4_ram (
    .ahb4_clk_i(ahb4_clk_i),
    .ahb4_rst_i(ahb4_rst_i),

    .sram_ce   (sram_ce),
    .sram_we   (sram_we),
    .sram_waddr(sram_waddr),
    .sram_din  (sram_din[XLEN-1:0]),
    .sram_sel  (sram_sel[SW-1:0]),

    .ahb4_hsel_i     (ahb4_hsel_i),
    .ahb4_haddr_i    (ahb4_haddr_i[PLEN-1:0]),
    .ahb4_hwdata_i   (ahb4_hwdata_i[XLEN-1:0]),
    .ahb4_hwrite_i   (ahb4_hwrite_i),
    .ahb4_hburst_i   (ahb4_hburst_i[2:0]),
    .ahb4_hprot_i    (ahb4_hprot_i[SW-1:0]),
    .ahb4_htrans_i   (ahb4_htrans_i[1:0]),
    .ahb4_hmastlock_i(ahb4_hmastlock_i),

    .ahb4_hrdata_o(ahb4_hrdata_o[XLEN-1:0]),
    .ahb4_hready_o(ahb4_hready_o),
    .ahb4_hresp_o (ahb4_hresp_o),

    .sram_dout(sram_dout[XLEN-1:0])
  );

  soc_sram_sp #(
    .XLEN         (XLEN),
    .PLEN         (PLEN),
    .MEM_SIZE_BYTE(MEM_SIZE_BYTE),
    .WORD_AW      (WORD_AW),
    .MEM_IMPL_TYPE(MEM_IMPL_TYPE),
    .MEM_FILE     (MEM_FILE)
  ) sp_ram (
    .clk(ahb4_clk_i),
    .rst(ahb4_rst_i),

    // Outputs
    .dout(sram_dout[XLEN-1:0]),

    // Inputs
    .ce   (sram_ce),
    .we   (sram_we),
    .oe   (1'b1),
    .waddr(sram_waddr),
    .din  (sram_din),
    .sel  (sram_sel)
  );
endmodule
