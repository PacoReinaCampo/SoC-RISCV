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

// 8-bit APB slaves reside here;
// GPIO
// UART
// I2C
// SPI
// User-8-bit APB buses

module pu_riscv_slaves_8b_apb4 #(
  parameter PADDR_SIZE = 16,
  parameter PDATA_SIZE = 8,

  parameter GPIO_CNT = 8,  // max 32
  parameter UART_CNT = 2,  // max 31, UART32=JSP
  parameter I2C_CNT  = 0,  // max 32
  parameter SPI_CNT  = 0,  // max 32
  parameter USR_CNT  = 1,

  parameter SYS_CLK_FREQ  = 25.0,  // in MHz
  parameter UART_BAUDRATE = 9600,

  localparam GPIO_CHK = GPIO_CNT < 1 ? 1 : GPIO_CNT > 32 ? 32 : GPIO_CNT,
  localparam UART_CHK = UART_CNT < 1 ? 1 : UART_CNT > 31 ? 31 : UART_CNT,  // UART32 = JSP

  localparam I2C_CHK = I2C_CNT < 1 ? 1 : I2C_CNT > 32 ? 32 : I2C_CNT,
  localparam SPI_CHK = SPI_CNT < 1 ? 1 : SPI_CNT > 32 ? 32 : SPI_CNT,
  localparam USR_CHK = USR_CNT < 1 ? 1 : USR_CNT,

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

  // JSP Bus
  output                        jsp_PSEL,
  output                        jsp_PENABLE,
  output                        jsp_PWRITE,
  output [                 2:0] jsp_PADDR,
  output [PDATA_SIZE      -1:0] jsp_PWDATA,
  input  [PDATA_SIZE      -1:0] jsp_PRDATA,
  input                         jsp_PREADY,
  input                         jsp_PSLVERR,

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

  // GPIOs
  input  [                 7:0] gpio_i    [GPIO_CHK],
  output [                 7:0] gpio_o    [GPIO_CHK],
  output [                 7:0] gpio_oe_o [GPIO_CHK],
  output [GPIO_CHK        -1:0] gpio_int_o,

  // UART
  input                         uart_rxd_i[UART_CHK],
  output                        uart_txd_o[UART_CHK],
  output [UART_CHK        -1:0] uart_int_o

  // I2C

  // SPI
);

  //////////////////////////////////////////////////////////////////////////////
  // Constants
  //////////////////////////////////////////////////////////////////////////////

  // amount of maximum instances (per slave type)
  localparam MAX_GPIO = 32;
  localparam MAX_UART = 32;
  localparam MAX_I2C = 32;
  localparam MAX_SPI = 32;

  // address space per slave type
  localparam GPIO_BYTES = 16;  // 16bytes
  localparam UART_BYTES = 8;  // 8bytes
  localparam I2C_BYTES = 16;  // 16bytes
  localparam SPI_BYTES = 16;  // 16bytes

  // offset per slave type
  localparam GPIO_BASE = 0;
  localparam UART_BASE = GPIO_BASE + MAX_GPIO * GPIO_BYTES;
  localparam I2C_BASE = UART_BASE + MAX_UART * UART_BYTES;
  localparam SPI_BASE = I2C_BASE + MAX_I2C * I2C_BYTES;
  localparam RES_BASE = SPI_BASE + MAX_SPI * SPI_BYTES;
  localparam USR_BASE = 1 << (PADDR_SIZE - 1);

  localparam USR_BYTES = USR_BASE / MAX_USR;

  localparam APB_SLAVES = MAX_GPIO + MAX_UART + MAX_I2C + MAX_SPI + MAX_USR;

  localparam RES_SLV_OFFS = 0;
  localparam GPIO_SLV_OFFS = 0;
  localparam UART_SLV_OFFS = GPIO_SLV_OFFS + MAX_GPIO;
  localparam I2C_SLV_OFFS = UART_SLV_OFFS + MAX_UART;
  localparam SPI_SLV_OFFS = I2C_SLV_OFFS + MAX_I2C;
  localparam USR_SLV_OFFS = SPI_SLV_OFFS + MAX_SPI;

  // UART16550 Clock divider
  localparam UART16550_DL = (SYS_CLK_FREQ * 1000_000) / (16 * UART_BAUDRATE);

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////

  logic [PADDR_SIZE-1:0] slv_addr   [APB_SLAVES];
  logic [PADDR_SIZE-1:0] slv_mask   [APB_SLAVES];

  logic                  SLV_PSEL   [APB_SLAVES];
  logic [PDATA_SIZE-1:0] SLV_PRDATA [APB_SLAVES];
  logic                  SLV_PREADY [APB_SLAVES];
  logic                  SLV_PSLVERR[APB_SLAVES];

  //////////////////////////////////////////////////////////////////////////////
  // Body
  //////////////////////////////////////////////////////////////////////////////

  // Hookup ABP Decoder
  always_comb begin
    //assign GPIO base address locations
    for (int n = 0; n < MAX_GPIO; n++) begin
      slv_addr[GPIO_SLV_OFFS + n] = GPIO_BASE + n * GPIO_BYTES;
      slv_mask[GPIO_SLV_OFFS + n] = ~{$clog2(GPIO_BYTES) {1'b1}};
    end

    //assign UART base address locations
    for (int n = 0; n < MAX_UART; n++) begin
      slv_addr[UART_SLV_OFFS + n] = UART_BASE + n * UART_BYTES;
      slv_mask[UART_SLV_OFFS + n] = ~{$clog2(UART_BYTES) {1'b1}};
    end

    //assign I2C base address locations
    for (int n = 0; n < MAX_I2C; n++) begin
      slv_addr[I2C_SLV_OFFS + n] = I2C_BASE + n * I2C_BYTES;
      slv_mask[I2C_SLV_OFFS + n] = ~{$clog2(I2C_BYTES) {1'b1}};
    end

    //assign SPI base address locations
    for (int n = 0; n < MAX_SPI; n++) begin
      slv_addr[SPI_SLV_OFFS + n] = SPI_BASE + n * SPI_BYTES;
      slv_mask[SPI_SLV_OFFS + n] = ~{$clog2(SPI_BYTES) {1'b1}};
    end

    //assign USR base address locations
    for (int n = 0; n < USR_CNT; n++) begin
      slv_addr[USR_SLV_OFFS + n] = USR_BASE + n * USR_BYTES;
      slv_mask[USR_SLV_OFFS + n] = ~{$clog2(USR_BYTES) {1'b1}};
    end
  end

  // Actual bus mux/decoder
  peripheral_mux_apb4 #(
    .PADDR_SIZE(PADDR_SIZE),  //TODO: number of (MSB) bits to compare
    .PDATA_SIZE(PDATA_SIZE),
    .SLAVES    (APB_SLAVES)
  ) apb_mux_inst (
    // Common signals
    .PRESETn(PRESETn),
    .PCLK   (PCLK),

    // To/From APB master
    .MST_PSEL   (PSEL),
    .MST_PADDR  (PADDR),   //MSBs of address bus
    .MST_PRDATA (PRDATA),
    .MST_PREADY (PREADY),
    .MST_PSLVERR(PSLVERR),

    // To/from APB slaves
    .slv_addr   (slv_addr),    //address compare for each slave
    .slv_mask   (slv_mask),    //mask per address (which bits to compare)
    .SLV_PSEL   (SLV_PSEL),
    .SLV_PRDATA (SLV_PRDATA),
    .SLV_PREADY (SLV_PREADY),
    .SLV_PSLVERR(SLV_PSLVERR)
  );

  // Hookup Slaves
  generate
    genvar n;

    //GPIO
    for (n = 0; n < MAX_GPIO; n++) begin
      if (n < GPIO_CNT) begin : gen_gpio
        apb_gpio #(PDATA_SIZE) gpio_inst (
          .PRESETn(PRESETn),
          .PCLK   (PCLK),
          .PSEL   (SLV_PSEL[GPIO_SLV_OFFS + n]),
          .PENABLE(PENABLE),
          .PADDR  (PADDR[3:0]),
          .PWRITE (PWRITE),
          .PSTRB  (PSTRB),
          .PWDATA (PWDATA),
          .PRDATA (SLV_PRDATA[GPIO_SLV_OFFS + n]),
          .PREADY (SLV_PREADY[GPIO_SLV_OFFS + n]),
          .PSLVERR(SLV_PSLVERR[GPIO_SLV_OFFS + n]),
          .gpio_i (gpio_i[n]),
          .gpio_o (gpio_o[n]),
          .gpio_oe(gpio_oe_o[n]),
          .irq_o  (gpio_int_o[n])
        );
      end else begin : gen_gpio_error
        apb_error #(PDATA_SIZE) gpio_error (
          .PRESETn(PRESETn),
          .PCLK   (PCLK),
          .PSEL   (SLV_PSEL[GPIO_SLV_OFFS + n]),
          .PENABLE(PENABLE),
          .PRDATA (SLV_PRDATA[GPIO_SLV_OFFS + n]),
          .PREADY (SLV_PREADY[GPIO_SLV_OFFS + n]),
          .PSLVERR(SLV_PSLVERR[GPIO_SLV_OFFS + n])
        );
      end
    end

    // UART
    for (n = 0; n < MAX_UART; n++) begin
      if (n == MAX_UART - 1) begin : gen_jsp_apb
        // JSP UART
        assign jsp_PSEL                       = SLV_PSEL[UART_SLV_OFFS + n];
        assign jsp_PENABLE                    = PENABLE;
        assign jsp_PADDR                      = PADDR[2:0];
        assign jsp_PWRITE                     = PWRITE;
        assign jsp_PWDATA                     = PWDATA;
        assign SLV_PRDATA[UART_SLV_OFFS + n]  = jsp_PRDATA;
        assign SLV_PREADY[UART_SLV_OFFS + n]  = jsp_PREADY;
        assign SLV_PSLVERR[UART_SLV_OFFS + n] = jsp_PSLVERR;
      end else if (n < UART_CNT) begin : gen_uart
        apb_uart16550 #(
          .FIFO_DEPTH     (16),
          .DL_RESET_VALUE (UART16550_DL),
          .WLS_RESET_VALUE(2'b11),         //8-bit
          .STB_RESET_VALUE(1'b0),          // 1stop bit
          .PEN_RESET_VALUE(1'b0)
        ) uart_inst (
          // no parity
          .PRESETn(PRESETn),
          .PCLK   (PCLK),
          .PSEL   (SLV_PSEL[UART_SLV_OFFS + n]),
          .PENABLE(PENABLE),
          .PADDR  (PADDR[2:0]),
          .PWRITE (PWRITE),
          .PWDATA (PWDATA),
          .PRDATA (SLV_PRDATA[UART_SLV_OFFS + n]),
          .PREADY (SLV_PREADY[UART_SLV_OFFS + n]),
          .PSLVERR(SLV_PSLVERR[UART_SLV_OFFS + n]),

          .sout_o(uart_txd_o[n]),
          .sin_i (uart_rxd_i[n]),
          .rts_no(),
          .dtr_no(),
          .dsr_ni(),
          .dcd_ni(),
          .cts_ni(),
          .ri_ni (),

          .out1_no(),
          .out2_no(),

          .baudout_no(),

          .txrdy_no(),
          .rxrdy_no(),
          .intr_o  (uart_int_o[n])
        );
      end else begin : gen_uart_error
        apb_error #(PDATA_SIZE) gpio_error (
          .PRESETn(PRESETn),
          .PCLK   (PCLK),
          .PSEL   (SLV_PSEL[UART_SLV_OFFS + n]),
          .PENABLE(PENABLE),
          .PRDATA (SLV_PRDATA[UART_SLV_OFFS + n]),
          .PREADY (SLV_PREADY[UART_SLV_OFFS + n]),
          .PSLVERR(SLV_PSLVERR[UART_SLV_OFFS + n])
        );
      end
    end

    // I2C

    // SPI

    // USR APB
    for (n = 0; n < MAX_USR; n++) begin
      if (n < USR_CNT) begin : gen_usr_apb
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
      end else begin : gen_usr_apb_error
        apb_error #(
          .PDATA_SIZE(PDATA_SIZE)
        ) gpio_error (
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
