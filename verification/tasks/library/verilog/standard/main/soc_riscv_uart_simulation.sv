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

module soc_riscv_uart_simulation #(
  parameter int    DATARATE  = 9600,
  parameter int    STOPBITS  = 1,      // 1, 2
  parameter int    DATABITS  = 8,      // 5,6,7,8
  parameter string PARITYBIT = "NONE"  // NONE, EVEN, ODD
) (
  input  rx_i,
  output tx_o
);

  //////////////////////////////////////////////////////////////////////////////
  // Constants
  //////////////////////////////////////////////////////////////////////////////

  localparam LOCAL_CLK = 100;  // MHz

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////

  logic clk;

  logic rx_reg, rx_reg_dly;
  logic rx_falling_edge;

  logic clk_cnt_clr, bit_cnt_clr, clk_cnt_done, bit_cnt_done;

  int clk_cnt, bit_cnt;

  logic [7:0] bit_sr, latch_rx;

  typedef enum {
    IDLE,
    START,
    DATA,
    PARITY,
    STOP
  } fsm_t;
  fsm_t fsm_state;

  int   fd;

  //////////////////////////////////////////////////////////////////////////////
  // Body
  //////////////////////////////////////////////////////////////////////////////

  // generate internal clock

  initial clk = 1'b0;

  always #(500 / LOCAL_CLK) clk = ~clk;

  // detect falling edge on incoming data

  always @(posedge clk) begin
    rx_reg     <= rx_i;
    rx_reg_dly <= rx_reg;
  end

  assign rx_falling_edge = ~rx_reg & rx_reg_dly;

  // bit count-enable
  // Start bit we only count half, such that end of START is in the middle of the Rx bit
  // Consecutive data bits are in the middle of the Rx bit then as well

  always @(posedge clk) begin
    if (clk_cnt_clr) begin
      clk_cnt <= (LOCAL_CLK * 1000_000 / (DATARATE * 2)) - 1;
    end else if (clk_cnt_done) begin
      clk_cnt <= (LOCAL_CLK * 1000_000 / DATARATE) - 1;
    end else begin
      clk_cnt <= clk_cnt - 1;
    end
  end

  assign clk_cnt_done = ~|clk_cnt;

  // Data shift register

  always @(posedge clk) begin
    if (clk_cnt_done) begin
      bit_sr <= {rx_reg, bit_sr[7:1]};
    end
  end

  // Data counter

  always @(posedge clk) begin
    if (bit_cnt_clr) begin
      bit_cnt <= DATABITS;  //the first bit we latch is the start bit. Thus count to DATABITS+1
    end else if (clk_cnt_done) begin
      bit_cnt <= bit_cnt - 1;
    end
  end

  assign bit_cnt_done = ~|bit_cnt;

  // State Machine

  initial fsm_state = IDLE;

  always @(posedge clk) begin
    clk_cnt_clr <= 1'b0;
    bit_cnt_clr <= 1'b0;

    case (fsm_state)
      //detect start bit
      IDLE: begin
        if (rx_falling_edge) begin
          fsm_state   <= START;
          clk_cnt_clr <= 1'b1;
          // bit_cnt_clr <= 1'b1;
        end
      end

      // wait for start bit to complete
      START: begin
        if (clk_cnt_done && !clk_cnt_clr) begin
          fsm_state   <= DATA;
          bit_cnt_clr <= 1'b1;
        end
      end

      // Shift in data
      DATA: begin
        if (bit_cnt_done) begin
          fsm_state <= PARITYBIT == "NONE" ? STOP : PARITY;
          latch_rx  <= bit_sr;
        end
      end

      // Parity Bit
      PARITY: begin
        if (clk_cnt_done) begin
          fsm_state <= STOP;
        end
      end

      // Stop Bit
      STOP: begin
        fsm_state <= IDLE;
        $fwrite(fd, "%0c", latch_rx);
        $fflush(fd);
      end
    endcase
  end

  // File, maybe replace with inet connection?

  initial fd = $fopen("uart_rx", "w");

endmodule
