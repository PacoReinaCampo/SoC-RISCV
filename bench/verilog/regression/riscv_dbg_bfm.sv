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
//              Debug Controller Simulation Model                             //
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

module riscv_dbg_bfm #(
  parameter XLEN = 64,
  parameter PLEN = 64,

  parameter CORES_PER_TILE = 16
)
  (
    input                                      rstn,
    input                                      clk,

    input      [CORES_PER_TILE-1:0]            cpu_bp_i,

    output     [CORES_PER_TILE-1:0]            cpu_stall_o,
    output reg [CORES_PER_TILE-1:0]            cpu_stb_o,
    output reg [CORES_PER_TILE-1:0]            cpu_we_o,
    output reg [CORES_PER_TILE-1:0][PLEN -1:0] cpu_adr_o,
    output reg [CORES_PER_TILE-1:0][XLEN -1:0] cpu_dat_o,
    input      [CORES_PER_TILE-1:0][XLEN -1:0] cpu_dat_i,
    input      [CORES_PER_TILE-1:0]            cpu_ack_i
  );

  ////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  genvar p;

  logic [CORES_PER_TILE-1:0] stall_cpu;

  ////////////////////////////////////////////////////////////////
  //
  // Tasks
  //
  function is_stalled;
    integer p;

    for (p=0; p < CORES_PER_TILE; p++)
      is_stalled = stall_cpu[p];
  endfunction

  //Stall CPU
  task stall;
    integer p;

    for (p=0; p < CORES_PER_TILE; p++)
      @(posedge clk);
    stall_cpu[p] <= 1'b1;
  endtask

  //Unstall CPU
  task unstall;
    integer p;

    for (p=0; p < CORES_PER_TILE; p++)
      @(posedge clk)
      stall_cpu[p] <= 1'b0;
  endtask

  //Write to CPU (via DBG interface)
  task write;
    input [PLEN-1:0] addr; //address to write to
    input [XLEN-1:0] data; //data to write

    integer p;

    for (p=0; p < CORES_PER_TILE; p++)
      //setup DBG bus
      @(posedge clk);
    cpu_stb_o [p] <= 1'b1;
    cpu_we_o  [p] <= 1'b1;
    cpu_dat_o [p] <= data;
    cpu_adr_o [p] <= addr;

    //wait for ack
    while (!cpu_ack_i[p]) @(posedge clk);

    //clear DBG bus
    cpu_stb_o [p] <= 1'b0;
    cpu_we_o  [p] <= 1'b0;
  endtask;

  //Read from CPU (via DBG interface)
  task read;
    input  [PLEN-1:0] addr; //address to read from
    output [XLEN-1:0] data [CORES_PER_TILE]; //data read from CPU

    integer p;

    for (p=0; p < CORES_PER_TILE; p++)
      //setup DBG bus
      @(posedge clk);
    cpu_stb_o [p] <= 1'b1;
    cpu_we_o  [p] <= 1'b0;
    cpu_adr_o [p] <= addr;

    //wait for ack
    while (!cpu_ack_i[p]) @(posedge clk);
    data[p] = cpu_dat_i[p];

    //clear DBG bus
    cpu_stb_o [p] <= 1'b0;
    cpu_we_o  [p] <= 1'b0;
  endtask;

  ////////////////////////////////////////////////////////////////
  //
  // Module body
  //
  generate
    for (p=0; p < CORES_PER_TILE; p++) begin
      initial cpu_stb_o  [p] = 1'b0;

      assign cpu_stall_o [p] = cpu_bp_i[p] | stall_cpu[p];

      always @(posedge clk,negedge rstn) begin
        if      ( !rstn       ) stall_cpu[p] <= 1'b0;
        else if ( cpu_bp_i[p] ) stall_cpu[p] <= 1'b1; //gets cleared by task unstall_cpu
      end
    end
  endgenerate
endmodule
