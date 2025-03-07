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

module soc_riscv_dbg_comm_vpi #(
  parameter JP_PORT     = "4567",
  parameter TIMEOUT_CNT = 6'd20
) (
  output TRSTN,
  output TCK,
  output TMS,
  output TDI,
  input  TDO
);

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////

  reg [4:0] memory;
  reg [3:0] in_word_r;
  reg [5:0] clk_count;

  reg       timeout_clk;

  //////////////////////////////////////////////////////////////////////////////
  // Body
  //////////////////////////////////////////////////////////////////////////////

  // Handle commands from the upper level
  initial begin
    in_word_r = 5'b0;
    memory    = 5'b0;
    $jp_init(JP_PORT);
    #500;  // Wait until reset is complete

    while (1) begin
      #1;
      $jp_in(memory);  // This will not change memory[][] if no command has been sent from jp
      if (memory[4]) begin
        // was memory[0][4] 
        in_word_r = memory[3:0];
        memory    = memory & 4'b1111;
        clk_count = 6'b000000;  // Reset the timeout clock in case jp wants to wait for a timeout / half TCK period
      end
    end
  end

  // Send the output bit to the upper layer
  always @(TDO) $jp_out(TDO);

  assign TCK   = in_word_r[0];
  assign TRSTN = in_word_r[1];
  assign TDI   = in_word_r[2];
  assign TMS   = in_word_r[3];

  // Send timeouts / wait periods to the upper layer
  initial timeout_clk = 0;

  always #10 timeout_clk = ~timeout_clk;

  always @(posedge timeout_clk) begin
    if (clk_count < TIMEOUT_CNT) begin
      clk_count[5:0] <= clk_count + 'h1;
    end else if (clk_count == TIMEOUT_CNT) begin
      $jp_wait_time();
      clk_count[5:0] <= clk_count + 'h1;
    end
    // else it's already timed out, don't do anything
  end

endmodule
