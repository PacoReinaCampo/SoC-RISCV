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

/* Copyright (c) 2017-2018 by the author(s)
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

module riscv_mmio_if #(
  parameter HDATA_SIZE    = 32,
  parameter HADDR_SIZE    = 32,
  parameter CATCH_TEST    = 80001000,
  parameter CATCH_UART_TX = 80001080,
  parameter X             = 8,
  parameter Y             = 8,
  parameter Z             = 8,
  parameter PORTS         = 8
)
  (
    input                                  HRESETn,
    input                                  HCLK,

    input      [PORTS-1:0][           1:0] HTRANS,
    input      [PORTS-1:0][HADDR_SIZE-1:0] HADDR,
    input      [PORTS-1:0]                 HWRITE,
    input      [PORTS-1:0][           2:0] HSIZE,
    input      [PORTS-1:0][           2:0] HBURST,
    input      [PORTS-1:0][HDATA_SIZE-1:0] HWDATA,
    output reg [PORTS-1:0][HDATA_SIZE-1:0] HRDATA,

    output reg [PORTS-1:0]                 HREADYOUT,
    output     [PORTS-1:0]                 HRESP
  );

  // Variables
  logic [PORTS-1:0][HDATA_SIZE-1:0] data_reg;
  logic [PORTS-1:0]                 catch_test,
                                    catch_uart_tx;

  logic [PORTS-1:0][           1:0] dHTRANS;
  logic [PORTS-1:0][HADDR_SIZE-1:0] dHADDR;
  logic [PORTS-1:0]                 dHWRITE;

  // Functions
  function string hostcode_to_string;
    input integer hostcode;

    case (hostcode)
      1337: hostcode_to_string = "OTHER EXCEPTION";
    endcase
  endfunction

  // Module body
  genvar p;
  //Generate watchdog counter
  integer watchdog_cnt;
  always @(posedge HCLK,negedge HRESETn) begin
    if (!HRESETn) watchdog_cnt <= 0;
    else          watchdog_cnt <= watchdog_cnt + 1;
  end

  generate
    for (p=0; p < PORTS; p++) begin
      //Catch write to host address
      assign HRESP[p] = `HRESP_OKAY;

      always @(posedge HCLK) begin
        dHTRANS <= HTRANS;
        dHADDR  <= HADDR;
        dHWRITE <= HWRITE;
      end

      always @(posedge HCLK,negedge HRESETn) begin
        if (!HRESETn) begin
          HREADYOUT[p] <= 1'b1;
        end
        else if (HTRANS[p] == `HTRANS_IDLE) begin
        end
      end

      always @(posedge HCLK,negedge HRESETn) begin
        if (!HRESETn) begin
          catch_test    [p] <= 1'b0;
          catch_uart_tx [p] <= 1'b0;
        end
        else begin
          catch_test    [p] <= dHTRANS[p] == `HTRANS_NONSEQ && dHWRITE[p] && dHADDR[p] == CATCH_TEST;
          catch_uart_tx [p] <= dHTRANS[p] == `HTRANS_NONSEQ && dHWRITE[p] && dHADDR[p] == CATCH_UART_TX;
          data_reg      [p] <= HWDATA [p];
        end
      end
      //Generate output

      //Simulated UART Tx (prints characters on screen)
      always @(posedge HCLK) begin
        if (catch_uart_tx[p]) $write ("%0c", data_reg[p]);
      end
      //Tests ...
      always @(posedge HCLK) begin
        if (watchdog_cnt > 1000_000 || catch_test[p]) begin
          $display("\n");
          $display("-------------------------------------------------------------");
          $display("* RISC-V test bench finished");
          if (data_reg[p][0] == 1'b1) begin
            if (~|data_reg[p][HDATA_SIZE-1:1])
              $display("* PASSED %0d", data_reg[p]);
            else
              $display ("* FAILED: code: 0x%h (%0d: %s)", data_reg[p] >> 1, data_reg[p] >> 1, hostcode_to_string(data_reg[p] >> 1) );
          end
          else
            $display ("* FAILED: watchdog count reached (%0d) @%0t", watchdog_cnt, $time);
          $display("-------------------------------------------------------------");
          $display("\n");

          $finish();
        end
      end
    end
  endgenerate
endmodule
