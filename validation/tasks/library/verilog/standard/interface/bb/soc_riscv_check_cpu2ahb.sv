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
//              AMBA4 AHB-Lite Bus Interface                                  //
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

import peripheral_ahb4_verilog_pkg::*;

module soc_riscv_check_cpu2ahb #(
  parameter XLEN           = 32,
  parameter PHYS_ADDR_SIZE = XLEN
) (
  //CPU Interface
  input [XLEN          -1:0] mem_adr,
  input [XLEN          -1:0] mem_d,          //from CPU
  input                      mem_req,
  input                      mem_we,
  input [XLEN/8        -1:0] mem_be,
  input [XLEN          -1:0] mem_q,          //to CPU
  input                      mem_ack,
  input                      mem_misaligned,

  // AHB Interface
  input                      HRESETn,
  input                      HCLK,
  input                      HSEL,
  input [PHYS_ADDR_SIZE-1:0] HADDR,
  input [XLEN          -1:0] HWDATA,
  input [XLEN          -1:0] HRDATA,
  input                      HWRITE,
  input [               2:0] HSIZE,
  input [               2:0] HBURST,
  input [               3:0] HPROT,
  input [               1:0] HTRANS,
  input                      HMASTLOCK,
  input                      HREADY,
  input                      HRESP
);

  //////////////////////////////////////////////////////////////////////////////
  // Constants
  //////////////////////////////////////////////////////////////////////////////

  typedef struct packed {
    logic [XLEN  -1:0] adr;
    logic              we;
    logic [XLEN/8-1:0] be;
    logic [XLEN  -1:0] d;
  } mem_if_struct;

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////
  mem_if_struct from_cpu, check;

  logic dmem_req;

  logic ahb_selected, ahb_write;

  mem_if_struct q[$];

  //////////////////////////////////////////////////////////////////////////////
  // Body
  //////////////////////////////////////////////////////////////////////////////

  // Queue push
  always @(posedge HCLK)
    if (mem_req) begin
      from_cpu.adr <= mem_adr;
      from_cpu.we  <= mem_we;
      from_cpu.be  <= mem_be;
      from_cpu.d   <= mem_d;
    end

  always @(posedge HCLK) begin
    dmem_req <= mem_req;
  end

  always @(posedge HCLK) begin
    if (dmem_req && !mem_misaligned) begin
      q.push_front(from_cpu);
    end
  end

  // Queue pop
  assign ahb_selected = HREADY && HSEL && (HTRANS == HTRANS_NONSEQ || HTRANS == HTRANS_SEQ);

  always @(posedge HCLK) begin
    if (ahb_selected) begin
      //Is queue empty?

      //get next item in queue
      check = q.pop_back;

      //check signals
      if (HADDR !== check.adr[PHYS_ADDR_SIZE-1:0]) begin
        $display("ERROR  : got HADDR=%x, expected %x @%0t", HADDR, check.adr[PHYS_ADDR_SIZE-1:0], $time);
      end

      if (HWRITE !== check.we) begin
        $display("ERROR  : got HWRITE=%x, expected %x @%0t", HWRITE, check.we, $time);
      end
    end
  end

  always @(posedge HCLK) begin
    if (HREADY) begin
      ahb_write <= HSEL && HWRITE && (HTRANS == HTRANS_NONSEQ || HTRANS == HTRANS_SEQ);
    end
  end

  always @(negedge HCLK) begin
    if (HREADY && ahb_write) begin
      if (HWDATA !== check.d) begin
        $display("ERROR  : got HWDATA=%x, expected %x @%0t", HWDATA, check.d, $time);
      end
    end
  end
endmodule
