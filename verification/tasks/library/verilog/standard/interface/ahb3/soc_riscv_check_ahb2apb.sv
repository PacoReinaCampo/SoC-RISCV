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

module soc_riscv_check_ahb2apb #(
  parameter HADDR_SIZE = 32,
  parameter HDATA_SIZE = 32,
  parameter PADDR_SIZE = 10,
  parameter PDATA_SIZE = 8
) (
  //AHB Interface
  input                      HRESETn,
  input                      HCLK,
  input                      HSEL,
  input [HADDR_SIZE    -1:0] HADDR,
  input [HDATA_SIZE    -1:0] HWDATA,
  input [HDATA_SIZE    -1:0] HRDATA,
  input                      HWRITE,
  input [               2:0] HSIZE,
  input [               2:0] HBURST,
  input [               3:0] HPROT,
  input [               1:0] HTRANS,
  input                      HMASTLOCK,
  input                      HREADY,
  input                      HRESP,

  //APB Interface
  input                    PRESETn,
  input                    PCLK,
  input                    PSEL,
  input                    PENABLE,
  input [             2:0] PPROT,
  input                    PWRITE,
  input [PDATA_SIZE/8-1:0] PSTRB,
  input [PADDR_SIZE  -1:0] PADDR,
  input [PDATA_SIZE  -1:0] PWDATA,
  input [PDATA_SIZE  -1:0] PRDATA,
  input                    PREADY,
  input                    PSLVERR

);

  //////////////////////////////////////////////////////////////////////////////
  // Constants
  //////////////////////////////////////////////////////////////////////////////

  typedef struct packed {
    logic [HADDR_SIZE-1:0] haddr;
    logic                  hwrite;
    logic [2:0]            hsize;
    logic [HDATA_SIZE-1:0] hwdata;
  } ahb_if_struct;

  //////////////////////////////////////////////////////////////////////////////
  // Functions
  //////////////////////////////////////////////////////////////////////////////

  function logic [6:0] address_mask;
    input integer data_size;

    //Which bits in HADDR should be taken into account?
    case (data_size)
      1024:    address_mask = 7'b111_1111;
      512:     address_mask = 7'b011_1111;
      256:     address_mask = 7'b001_1111;
      128:     address_mask = 7'b000_1111;
      64:      address_mask = 7'b000_0111;
      32:      address_mask = 7'b000_0011;
      16:      address_mask = 7'b000_0001;
      default: address_mask = 7'b000_0000;
    endcase
  endfunction  //address_mask

  function logic [9:0] data_offset(input [HADDR_SIZE-1:0] haddr);
    logic [6:0] haddr_masked;

    //Generate masked address
    haddr_masked = haddr & address_mask(HDATA_SIZE);

    //calculate bit-offset
    data_offset  = 8 * haddr_masked;
  endfunction  //data_offset

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////

  ahb_if_struct from_ahb, check;

  logic                          ahb_req;
  logic                          ahb_transfer;
  logic                          ahb_write;

  ahb_if_struct                  q_ahb2apb    [$];

  logic                          is_ahbread;
  logic         [HADDR_SIZE-1:0] ahb_haddr;
  logic         [PDATA_SIZE-1:0] q_apb2ahb    [$];
  logic         [HDATA_SIZE-1:0] check_prdata;

  //////////////////////////////////////////////////////////////////////////////
  // Body
  //////////////////////////////////////////////////////////////////////////////

  // AHB2APB Queue push
  always @(posedge HCLK) begin
    if (HREADY) begin
      from_ahb.haddr  <= HADDR;
      from_ahb.hwrite <= HWRITE;
      from_ahb.hsize  <= HSIZE;
    end
  end

  always @(posedge HCLK) begin
    ahb_req <= HREADY && HSEL && (HTRANS == HTRANS_NONSEQ || HTRANS == HTRANS_SEQ);
  end

  always @(posedge HCLK) begin
    if (ahb_req) begin
      from_ahb.hwdata = HWDATA;
      q_ahb2apb.push_front(from_ahb);
    end
  end

  // AHB2APB Queue pop
  always @(posedge PCLK) begin
    if (PSEL && PENABLE) begin
      // Is queue empty?
      if (q_ahb2apb.size() == 0) begin
        $display("ERROR  : starting APB cycle without AHB request @%t (%m)", $time);
      end else begin
        // get next item in queue
        check = q_ahb2apb.pop_back;

        // check signals
        if (PADDR !== check.haddr[PADDR_SIZE-1:0]) begin
          $display("ERROR  : got PADDR=%x, expected %x @%0t (%m)", PADDR, check.haddr[PADDR_SIZE-1:0], $time);
        end

        if (PWRITE !== check.hwrite) begin
          $display("ERROR  : got PWRITE=%x, expected %x @%0t (%m)", PWRITE, check.hwrite, $time);
        end

        if (PWRITE && PWDATA !== (check.hwdata >> data_offset(check.haddr))) begin
          $display("ERROR  : got PWDATA=%x, expected %x @%0t (%m)", PWDATA, check.hwdata, $time);
        end
      end
    end
  end

  // APB2AHB Queue push

  always @(posedge PCLK) begin
    if (PSEL && PENABLE && !PWRITE) begin
      q_apb2ahb.push_front(PRDATA);
    end
  end

  always @(posedge HCLK) begin
    if (HREADY) begin
      ahb_haddr <= HADDR;
    end
  end

  // APB2AHB Queue pop

  // cycle #1
  always @(posedge HCLK) begin
    if (HREADY) begin
      is_ahbread <= HSEL & ~HWRITE & (HTRANS == HTRANS_NONSEQ || HTRANS == HTRANS_SEQ);
    end
  end

  // cycle #2
  always @(posedge HCLK) begin
    if (HREADY) begin
      if (is_ahbread) begin
        //Is queue empty?
        if (q_apb2ahb.size() == 0) begin
          $display("ERROR  : Reading from APB, but no APB read data @%t (%m)", $time);
        end else begin
          // get next item in queue
          check_prdata = q_apb2ahb.pop_back << data_offset(ahb_haddr);

          // $display ("%x, %x, %x, %x, %x, %x", ahb_haddr, HRDATA, check_prdata, (check_prdata << data_offset(ahb_haddr)), tmp_hdata, (tmp_hdata << data_offset(ahb_haddr)) );
          // check signals
          if (HRDATA !== check_prdata) begin
            $display("ERROR  : got HRDATA=%x, expected %x @%0t (%m)", HRDATA, check_prdata, $time);
          end
        end
      end
    end
  end

endmodule
