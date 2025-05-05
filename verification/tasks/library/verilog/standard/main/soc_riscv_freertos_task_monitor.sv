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

import peripheral_biu_verilog_pkg::*;

module soc_riscv_freertos_task_monitor #(
  parameter string            FILENAME      = "FREERTOS_TASK_MON",
  parameter int               XLEN          = 32,
  parameter        [XLEN-1:0] ADDRESS_BASE  = 'h0000_0000,
  parameter        [XLEN-1:0] ADDRESS_RANGE = 'h4000
) (
  input                       clk_i,
  input                       req_i,
  input            [XLEN-1:0] adr_i,
  input            [XLEN-1:0] d_i,
  input            [XLEN-1:0] q_i,
  input                       we_i,
  input            [     2:0] size_i,
  input                       ack_i,
  input            [XLEN-1:0] sp,
  ra
);

  //////////////////////////////////////////////////////////////////////////////
  // Typedef
  //////////////////////////////////////////////////////////////////////////////

  typedef struct {
    logic [XLEN-1:0] adr;
    logic [XLEN-1:0] data;
    logic            we;
    logic [     2:0] size;
    // time t; //time

    logic [XLEN-1:0] sp, ra;
  } data_t;

  //////////////////////////////////////////////////////////////////////////////
  // Functions/Tasks
  //////////////////////////////////////////////////////////////////////////////

  //Open log file
  function int fopen(input string filename);
    fopen = $fopen(filename, "w");

    if (!fopen) begin
      $fatal("Failed to open: %s", filename);
    end else begin
      $info("FreeRTOS Monitor: Opened %s (%0d)", filename, fopen);
    end
  endfunction : fopen

  //Close file
  //TODO: fd should be argument
  //      call when closing simulator (callback?)
  task fclose();
    $fclose(fd);
  endtask : fclose

  //Write datablob to file
  task fwrite(input int fd, input data_t blob);
    $fdisplay(fd, "%0h,%0h,%0b,%0h,%0h,%0h,%0t", blob.adr, blob.data, blob.we, blob.size, blob.sp, blob.ra, $time);
  endtask : fwrite

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////

  int fd;

  data_t queue[$], queue_d, queue_q;

  //////////////////////////////////////////////////////////////////////////////
  // Module body
  //////////////////////////////////////////////////////////////////////////////

  // open file
  initial fd = fopen(FILENAME);

  // store access request
  assign queue_d.adr  = adr_i;
  assign queue_d.we   = we_i;
  assign queue_d.size = size_i;
  assign queue_d.data = d_i;  // gets overwritten for a read

  assign queue_d.sp   = sp;
  assign queue_d.ra   = ra;

  //push access request into queue
  always @(posedge clk_i) begin
    if (req_i) begin
      queue.push_front(queue_d);
    end
  end

  // wait for acknowledge and write to file
  always @(posedge clk_i) begin
    if (ack_i) begin
      // pop request from queue
      queue_q = queue.pop_back();

      if (!queue_q.we) begin
        queue_q.data = q_i;
      end

      // write to file
      if (queue_q.adr >= ADDRESS_BASE && queue_q.adr < (ADDRESS_BASE + ADDRESS_RANGE)) begin
        fwrite(fd, queue_q);
      end
    end
  end

endmodule
