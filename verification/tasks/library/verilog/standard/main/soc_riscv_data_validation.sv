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

// Data Validation

import peripheral_biu_verilog_pkg::*;

// Data Memory Access Validation
module soc_riscv_data_validation #(
  parameter XLEN               = 32,
  parameter INIT_FILE          = "inifile",
  parameter CHECK_CREATE       = 1,
  parameter ADDRESS_LOWERBOUND = 'h0000_0000,
  parameter ADDRESS_UPPERBOUND = 'hffff_ffff
) (
  input                       clk_i,
  input                       req_i,
  input            [XLEN-1:0] adr_i,
  input            [XLEN-1:0] d_i,
  input            [XLEN-1:0] q_i,
  input                       we_i,
  input biu_size_t            size_i,
  input                       lock_i,
  input                       ack_i,
  input                       err_i,
  input                       misaligned_i,
  input                       page_fault_i
);

  //////////////////////////////////////////////////////////////////////////////
  // Typedef
  //////////////////////////////////////////////////////////////////////////////

  typedef struct {
    logic [XLEN-1:0] adr;
    logic [XLEN-1:0] data;
    logic            we;
    biu_size_t       size;
    logic            lock;
    logic            ack;
    logic            err;
    logic            misaligned;
    logic            page_fault;
    string           comment;
  } data_t;

  //////////////////////////////////////////////////////////////////////////////
  // Functions/Tasks
  //////////////////////////////////////////////////////////////////////////////

  // Open golden file, either for reading or writing
  function int golden_open(input string filename, input bit rw);
    golden_open = $fopen(filename, rw ? "r" : "w");

    if (!golden_open) begin
      $fatal("Failed to open: %s", filename);
    end else begin
      $info("Opened %s (%0d)", filename, golden_open);
    end
  endfunction : golden_open

  //Close golden file
  //TODO: fd should be argument
  //      call when closing simulator (callback?)
  task golden_close();
    $fclose(fd);
  endtask : golden_close

  // Write datablob to golden file
  //TODO: why doesn't $fwrite work?
  //      why can't a typedef be written at once with %z?
  task golden_write(input int fd, input data_t blob);
    //    $display ("fwrite %0t %z", $realtime, blob);
    //    $fdisplay (fd, "%z", blob);
    $fdisplay(fd, "%h %h %b %h %b %h %s", blob.adr, blob.data, blob.we, blob.size, blob.lock, {blob.ack, blob.err, blob.misaligned, blob.page_fault}, "-");
  endtask : golden_write

  // Read golden file
  //TODO: ideally would want to read a type_def with %z
  function data_t golden_read(input int fd);
    int    err;
    data_t tmp;

    err = $fscanf(fd, "%h %h %b %h %b %h %s", tmp.adr, tmp.data, tmp.we, tmp.size, tmp.lock, {tmp.ack, tmp.err, tmp.misaligned, tmp.page_fault}, tmp.comment);

    if (err != 7) begin
      $error("golden_read");
      return data_t'(-1);
    end else begin
      return tmp;
    end
  endfunction : golden_read

  // Compare results
  // g=golden
  // r=reference
  function int golden_compare(input data_t g, r);
    r.comment = "-";
    if (r !== g && g.comment[0] !== "+") begin
      $display("ERROR  : golden_compare error @%0t %s", $realtime, g.comment);
      $display("        | golden %s| reference", {XLEN / 4 - 6{" "}});
      $display("adr     | %h | %h", g.adr, r.adr);
      $display("data    | %h | %h", g.data, r.data);
      $display("size    | %h  %s| %h", g.size, {XLEN / 4 - 2{" "}}, r.size);
      $display("we/lock | %b%b %s| %b%b", g.we, g.lock, {XLEN / 4 - 2{" "}}, r.we, r.lock);
      $display("aemp    | %b%b%b%b %s| %b%b%b%b", g.ack, g.err, g.misaligned, g.page_fault, {XLEN / 4 - 4{" "}}, r.ack, r.err, r.misaligned, r.page_fault);
      return -1;
    end else begin
      return 0;
    end
  endfunction : golden_compare

  task golden_finish();
    // close file
    golden_close();

    // display notice
    $info("soc_riscv_data_validation errors: %0d", golden_errors);
  endtask : golden_finish

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////

  int fd;

  data_t queue[$], queue_d, queue_q;

  int golden_errors = 0;

  //////////////////////////////////////////////////////////////////////////////
  // Body
  //////////////////////////////////////////////////////////////////////////////

  // open file
  initial begin
    fd = golden_open({INIT_FILE, ".golden"}, CHECK_CREATE);
  end

  // store access request
  assign queue_d.adr  = adr_i;
  assign queue_d.we   = we_i;
  assign queue_d.size = size_i;
  assign queue_d.lock = lock_i;
  assign queue_d.data = d_i;  //gets overwritten for a read

  //push access request into queue
  always @(posedge clk_i) begin
    if (req_i) begin
      queue.push_front(queue_d);
    end
  end

  //wait for acknowledge and write to file
  always @(posedge clk_i) begin
    if (ack_i || err_i || page_fault_i) begin
      //pop request from queue
      queue_q            = queue.pop_back();

      //store response
      queue_q.ack        = ack_i;
      queue_q.err        = err_i;
      queue_q.misaligned = misaligned_i;
      queue_q.page_fault = page_fault_i;

      if (!queue_q.we) begin
        queue_q.data = q_i;
      end

      if (CHECK_CREATE) begin
        // read from file and compare
        if (queue_q.adr > ADDRESS_LOWERBOUND && queue_q.adr < ADDRESS_UPPERBOUND) begin
          if (golden_compare(golden_read(fd), queue_q)) begin
            golden_errors++;
          end
        end
      end else begin
        // write to file
        if (queue_q.adr > ADDRESS_LOWERBOUND && queue_q.adr < ADDRESS_UPPERBOUND) begin
          golden_write(fd, queue_q);
        end
      end
    end
  end

endmodule
