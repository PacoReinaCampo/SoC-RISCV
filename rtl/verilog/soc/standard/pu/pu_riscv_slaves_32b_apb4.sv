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

// 32-bit APB Slaves reside here;
// PLIC
// User 32-bit APB buses

module pu_riscv_slaves_32b_apb4 #(
  parameter PADDR_SIZE = 8,
  parameter PDATA_SIZE = 32,

  parameter USR_CNT = 1,  // Number of USER APB32 buses

  // Interrupts
  parameter GPIO_CNT    = 1,
  parameter UART_CNT    = 1,
  parameter I2C_CNT     = 1,
  parameter SPI_CNT     = 1,
  parameter USR_INT_CNT = 1,

  // PLIC Parameter
  localparam PLIC_SOURCES       = 1 + GPIO_CNT + UART_CNT + I2C_CNT + SPI_CNT + USR_INT_CNT,  // JSP interrupt
  parameter  PLIC_TARGETS       = 1,
  parameter  PLIC_PRIORITIES    = 3,
  parameter  PLIC_PENDING_CNT   = 3,
  parameter  PLIC_HAS_THRESHOLD = 1,

  localparam USR_CHK = USR_CNT < 1 ? 1 : USR_CNT,

  localparam GPIO_CHK    = GPIO_CNT < 1 ? 1 : GPIO_CNT,
  localparam UART_CHK    = UART_CNT < 1 ? 1 : UART_CNT,
  localparam I2C_CHK     = I2C_CNT < 1 ? 1 : I2C_CNT,
  localparam SPI_CHK     = SPI_CNT < 1 ? 1 : SPI_CNT,
  localparam USR_INT_CHK = USR_INT_CNT < 1 ? 1 : USR_INT_CNT,

  localparam MAX_USR        = 1 << $clog2(USR_CHK),
  localparam USR_PADDR_SIZE = PADDR_SIZE - $clog2(MAX_USR) - 1

) (
  // System APB Bus
  input                         PRESETn,
  input                         PCLK,
  input                         PSEL,
  input                         PENABLE,
  input  [                 2:0] PPROT,
  input                         PWRITE,
  input  [PDATA_SIZE/8    -1:0] PSTRB,
  input  [PADDR_SIZE      -1:0] PADDR,
  input  [PDATA_SIZE      -1:0] PWDATA,
  output [PDATA_SIZE      -1:0] PRDATA,
  output                        PREADY,
  output                        PSLVERR,

  // USR APB
  output                        usr_PSEL   [USR_CHK],
  output                        usr_PENABLE[USR_CHK],
  output [                 2:0] usr_PPROT  [USR_CHK],
  output                        usr_PWRITE [USR_CHK],
  output [PDATA_SIZE/8    -1:0] usr_PSTRB  [USR_CHK],
  output [USR_PADDR_SIZE  -1:0] usr_PADDR  [USR_CHK],
  output [PDATA_SIZE      -1:0] usr_PWDATA [USR_CHK],
  input  [PDATA_SIZE      -1:0] usr_PRDATA [USR_CHK],
  input                         usr_PREADY [USR_CHK],
  input                         usr_PSLVERR[USR_CHK],

  // Interrupts
  input                        int_jsp_i,
  input [UART_CHK        -1:0] int_uart_i,
  input [GPIO_CHK        -1:0] int_gpio_i,
  input [I2C_CHK         -1:0] int_i2c_i,
  input [SPI_CHK         -1:0] int_spi_i,
  input [USR_INT_CHK     -1:0] int_usr_i,

  output plic_int_o
);

  //////////////////////////////////////////////////////////////////////////////
  // Constants
  //////////////////////////////////////////////////////////////////////////////

  localparam APB_SLAVES = 1 + MAX_USR;

  localparam PLIC_SLV_OFFS = 0;
  localparam USR_SLV_OFFS = 1;

  localparam PLIC_BASE = 0;
  localparam PLIC_BYTES = 1024;  // 1k bytes

  localparam USR_BASE = 1 << (PADDR_SIZE - 1);
  localparam USR_BYTES = USR_BASE / MAX_USR;

  // Interrupt sources
  localparam PLIC_SRC_JSP = 0;
  localparam PLIC_SRC_UART = PLIC_SRC_JSP + 1;
  localparam PLIC_SRC_GPIO = PLIC_SRC_UART + UART_CNT;
  localparam PLIC_SRC_I2C = PLIC_SRC_GPIO + GPIO_CNT;
  localparam PLIC_SRC_SPI = PLIC_SRC_I2C + I2C_CNT;
  localparam PLIC_SRC_USR = PLIC_SRC_SPI + SPI_CNT;

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////

  logic [  PADDR_SIZE-1:0] slv_addr   [APB_SLAVES];
  logic [  PADDR_SIZE-1:0] slv_mask   [APB_SLAVES];

  logic                    SLV_PSEL   [APB_SLAVES];
  logic [  PDATA_SIZE-1:0] SLV_PRDATA [APB_SLAVES];
  logic                    SLV_PREADY [APB_SLAVES];
  logic                    SLV_PSLVERR[APB_SLAVES];

  logic [PLIC_SOURCES-1:0] plic_src;

  //////////////////////////////////////////////////////////////////////////////
  // Body
  //////////////////////////////////////////////////////////////////////////////

  // Hookup ABP Decoder
  always_comb begin
    // PLIC
    slv_addr[PLIC_SLV_OFFS] = PLIC_BASE;
    slv_mask[PLIC_SLV_OFFS] = ~{$clog2(PLIC_BYTES) {1'b1}};

    // USR APB
    for (int n = 0; n < MAX_USR; n++) begin
      slv_addr[USR_SLV_OFFS + n] = USR_BASE + n * USR_BYTES;
      slv_mask[USR_SLV_OFFS + n] = ~{$clog2(USR_BYTES) {1'b1}};
    end
  end

  // Actual bus mux/decoder
  apb_mux #(
    .PADDR_SIZE(PADDR_SIZE),  // number of (MSB) bits to compare
    .PDATA_SIZE(PDATA_SIZE),
    .SLAVES    (APB_SLAVES)
  ) apb_mux_inst1 (
    // Common signals
    .PRESETn(PRESETn),
    .PCLK   (PCLK),

    // To/From APB master
    .MST_PSEL   (PSEL),
    .MST_PADDR  (PADDR),   // MSBs of address bus
    .MST_PRDATA (PRDATA),
    .MST_PREADY (PREADY),
    .MST_PSLVERR(PSLVERR),

    // To/from APB slaves
    .slv_addr   (slv_addr),    // address compare for each slave
    .slv_mask   (slv_mask),    // mask per address (which bits to compare)
    .SLV_PSEL   (SLV_PSEL),
    .SLV_PRDATA (SLV_PRDATA),
    .SLV_PREADY (SLV_PREADY),
    .SLV_PSLVERR(SLV_PSLVERR)
  );

  // Hookup Slaves

  // PLIC
  apb4_plic_top #(
    .PADDR_SIZE(10),
    .PDATA_SIZE(PDATA_SIZE),

    // PLIC Parameters
    .SOURCES          (PLIC_SOURCES),        // Number of interrupt sources
    .TARGETS          (PLIC_TARGETS),        // Number of interrupt targets
    .PRIORITIES       (PLIC_PRIORITIES),     // Number of Priority levels
    .MAX_PENDING_COUNT(PLIC_PENDING_CNT),    // Max. number of 'pending' events
    .HAS_THRESHOLD    (PLIC_HAS_THRESHOLD),  // Is 'threshold' implemented?
    .HAS_CONFIG_REG   (1)
  ) plic_inst (
    // Is the 'configuration' register implemented?
    .PRESETn(PRESETn),
    .PCLK   (PCLK),
    .PSEL   (SLV_PSEL[PLIC_SLV_OFFS]),
    .PENABLE(PENABLE),
    .PADDR  (PADDR[9:0]),
    .PWRITE (PWRITE),
    .PSTRB  (PSTRB),
    .PWDATA (PWDATA),
    .PRDATA (SLV_PRDATA[PLIC_SLV_OFFS]),
    .PREADY (SLV_PREADY[PLIC_SLV_OFFS]),
    .PSLVERR(SLV_PSLVERR[PLIC_SLV_OFFS]),

    .src(plic_src),   //Interrupt sources
    .irq(plic_int_o)
  );

  // Assign interrupts
  always_comb begin
    plic_src[PLIC_SRC_JSP] = int_jsp_i;

    for (int n = 0; n < UART_CNT; n++) begin
      plic_src[PLIC_SRC_UART + n] = int_uart_i[n];
    end

    for (int n = 0; n < GPIO_CNT; n++) begin
      plic_src[PLIC_SRC_GPIO + n] = int_gpio_i[n];
    end

    for (int n = 0; n < I2C_CNT; n++) begin
      plic_src[PLIC_SRC_I2C + n] = int_i2c_i[n];
    end

    for (int n = 0; n < SPI_CNT; n++) begin
      plic_src[PLIC_SRC_SPI + n] = int_spi_i[n];
    end

    for (int n = 0; n < USR_INT_CNT; n++) begin
      plic_src[PLIC_SRC_USR + n] = int_usr_i[n];
    end
  end

  generate
    genvar n;

    // USR APB
    for (n = 0; n < MAX_USR; n++) begin
      if (n < USR_CNT) begin
        assign usr_PSEL[n]                   = SLV_PSEL[USR_SLV_OFFS + n];
        assign usr_PENABLE[n]                = PENABLE;
        assign usr_PADDR[n]                  = PADDR[USR_PADDR_SIZE-1:0];
        assign usr_PWRITE[n]                 = PWRITE;
        assign usr_PSTRB[n]                  = PSTRB;
        assign usr_PWDATA[n]                 = PWDATA;
        assign usr_PPROT[n]                  = PPROT;
        assign SLV_PRDATA[USR_SLV_OFFS + n]  = usr_PRDATA[n];
        assign SLV_PREADY[USR_SLV_OFFS + n]  = usr_PREADY[n];
        assign SLV_PSLVERR[USR_SLV_OFFS + n] = usr_PSLVERR[n];
      end else begin
        apb_error #(
          .PDATA_SIZE(PDATA_SIZE)
        ) usr_error (
          .PRESETn(PRESETn),
          .PCLK   (PCLK),
          .PSEL   (SLV_PSEL[USR_SLV_OFFS + n]),
          .PENABLE(PENABLE),
          .PRDATA (SLV_PRDATA[USR_SLV_OFFS + n]),
          .PREADY (SLV_PREADY[USR_SLV_OFFS + n]),
          .PSLVERR(SLV_PSLVERR[USR_SLV_OFFS + n])
        );
      end
    end
  endgenerate

endmodule
