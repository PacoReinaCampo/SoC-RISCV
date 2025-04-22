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

module soc_ahb42sram #(
  // Memory parameters
  // data width (word size)
  // Valid values: 32, 16 and 8
  parameter XLEN = 32,

  // address width
  parameter PLEN = 32,

  // byte select width
  localparam SW = (XLEN == 32) ? 4 : (XLEN == 16) ? 2 : (XLEN == 8) ? 1 : 'hx,

  // +--------------+--------------+
  // | word address | byte in word |
  // +--------------+--------------+
  //     WORD_AW         BYTE_AW
  //        +----- PLEN -----+
 
  localparam BYTE_AW = SW >> 1,
  localparam WORD_AW = PLEN - BYTE_AW
) (
  // AHB4 ports
  input            ahb4_hsel_i,
  input [PLEN-1:0] ahb4_haddr_i,
  input [XLEN-1:0] ahb4_hwdata_i,
  input [     2:0] ahb4_hburst_i,
  input [SW  -1:0] ahb4_hprot_i,
  input            ahb4_hwrite_i,
  input [     1:0] ahb4_htrans_i,
  input            ahb4_hmastlock_i,

  output [XLEN-1:0] ahb4_hrdata_o,
  output            ahb4_hready_o,
  output            ahb4_hresp_o,

  input ahb4_clk_i,
  input ahb4_rst_i,

  // generic RAM ports
  output               sram_ce,
  output               sram_we,
  output [WORD_AW-1:0] sram_waddr,
  output [XLEN   -1:0] sram_din,
  output [SW     -1:0] sram_sel,
  input  [XLEN   -1:0] sram_dout
);

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////

  wire [WORD_AW-1:0] word_addr_in;

  reg  [WORD_AW-1:0] word_addr_reg;
  reg  [WORD_AW-1:0] word_addr;

  // Register to indicate if the cycle is a Wishbone B3-registered feedback
  // type access
  reg                ahb4_b3_trans;
  wire ahb4_b3_trans_start, ahb4_b3_trans_stop;

  // Register to use for counting the addresses when doing burst accesses
  reg  [WORD_AW-1:0] burst_adr_counter;
  reg  [        2:0] ahb4_hburst_i_r;
  reg  [        1:0] ahb4_htrans_i_r;
  wire               using_burst_adr;
  wire               burst_access_wrong_ahb4_adr;

  // Ack Logic
  reg                ahb4_ack;
  reg                nxt_ahb4_ack;

  //////////////////////////////////////////////////////////////////////////////
  // Body
  //////////////////////////////////////////////////////////////////////////////

  assign word_addr_in        = ahb4_haddr_i[PLEN-1:BYTE_AW];

  // assignments from ahb4 to memory
  assign sram_ce             = 1'b1;
  assign sram_we             = ahb4_hwrite_i & ahb4_hready_o;
  assign sram_waddr          = (ahb4_hwrite_i) ? word_addr_reg : word_addr;
  assign sram_din            = ahb4_hwdata_i;
  assign sram_sel            = ahb4_hprot_i;

  assign ahb4_hrdata_o       = sram_dout;

  // Logic to detect if there's a burst access going on
  assign ahb4_b3_trans_start = ((ahb4_hburst_i == 3'b001) | (ahb4_hburst_i == 3'b010)) & ahb4_hsel_i & !ahb4_b3_trans;

  assign ahb4_b3_trans_stop  = (ahb4_hburst_i == 3'b111) & ahb4_hsel_i & ahb4_b3_trans & ahb4_hready_o;

  always @(posedge ahb4_clk_i) begin
    if (ahb4_rst_i) begin
      ahb4_b3_trans <= 0;
    end else if (ahb4_b3_trans_start) begin
      ahb4_b3_trans <= 1;
    end else if (ahb4_b3_trans_stop) begin
      ahb4_b3_trans <= 0;
    end
  end

  // Burst address generation logic
  always @(*) begin
    if (ahb4_rst_i) begin
      burst_adr_counter = 0;
    end else begin
      burst_adr_counter = word_addr_reg;
      if (ahb4_b3_trans_start) begin
        burst_adr_counter = word_addr_in;
      end else if ((ahb4_hburst_i_r == 3'b010) & ahb4_hready_o & ahb4_b3_trans) begin
        // Incrementing burst
        if (ahb4_htrans_i_r == 2'b00) begin  // Linear burst
          burst_adr_counter = word_addr_reg + 1;
        end
        if (ahb4_htrans_i_r == 2'b01) begin  // 4-beat wrap burst
          burst_adr_counter[1:0] = word_addr_reg[1:0] + 1;
        end
        if (ahb4_htrans_i_r == 2'b10) begin  // 8-beat wrap burst
          burst_adr_counter[2:0] = word_addr_reg[2:0] + 1;
        end
        if (ahb4_htrans_i_r == 2'b11) begin  // 16-beat wrap burst
          burst_adr_counter[3:0] = word_addr_reg[3:0] + 1;
        end
      end else if (!ahb4_hready_o & ahb4_b3_trans) begin
        burst_adr_counter = word_addr_reg;
      end
    end
  end

  // Register it locally
  always @(posedge ahb4_clk_i) begin
    ahb4_htrans_i_r <= ahb4_htrans_i;
  end

  always @(posedge ahb4_clk_i) begin
    ahb4_hburst_i_r <= ahb4_hburst_i;
  end

  assign using_burst_adr             = ahb4_b3_trans;

  assign burst_access_wrong_ahb4_adr = (using_burst_adr & (word_addr_reg != word_addr_in));

  // Address logic
  always @(*) begin
    if (using_burst_adr) begin
      word_addr = burst_adr_counter;
    end else if (ahb4_hmastlock_i & ahb4_hsel_i) begin
      word_addr = word_addr_in;
    end else begin
      word_addr = word_addr_reg;
    end
  end

  // Address registering logic
  always @(posedge ahb4_clk_i) begin
    if (ahb4_rst_i) begin
      word_addr_reg <= {WORD_AW{1'bx}};
    end else begin
      word_addr_reg <= word_addr;
    end
  end

  assign ahb4_hready_o = ahb4_ack & ahb4_hsel_i & ~burst_access_wrong_ahb4_adr;

  always @(*) begin
    if (ahb4_hmastlock_i) begin
      if (ahb4_hburst_i == 3'b000) begin
        // Classic cycle acks
        if (ahb4_hsel_i) begin
          if (!ahb4_ack) begin
            nxt_ahb4_ack = 1;
          end else begin
            nxt_ahb4_ack = 0;
          end
        end else begin
          nxt_ahb4_ack = 0;
        end
      end else if ((ahb4_hburst_i == 3'b001) || (ahb4_hburst_i == 3'b010)) begin
        // Increment/constant address bursts
        if (ahb4_hsel_i) begin
          nxt_ahb4_ack = 1;
        end else begin
          nxt_ahb4_ack = 0;
        end
      end else if (ahb4_hburst_i == 3'b111) begin
        // End of cycle
        if (ahb4_hsel_i) begin
          if (!ahb4_ack) begin
            nxt_ahb4_ack = 1;
          end else begin
            nxt_ahb4_ack = 0;
          end
        end else begin
          nxt_ahb4_ack = 0;
        end
      end else begin
        nxt_ahb4_ack = 0;
      end
    end else begin
      nxt_ahb4_ack = 0;
    end
  end

  always @(posedge ahb4_clk_i) begin
    if (ahb4_rst_i) begin
      ahb4_ack <= 1'b0;
    end else begin
      ahb4_ack <= nxt_ahb4_ack;
    end
  end

  assign ahb4_hresp_o = ahb4_ack & ahb4_hsel_i & (burst_access_wrong_ahb4_adr);
endmodule
