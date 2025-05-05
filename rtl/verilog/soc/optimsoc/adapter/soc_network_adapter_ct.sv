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
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019-2020 by the author(s)
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

import soc_optimsoc_configuration::*;

module soc_network_adapter_ct #(
  parameter PLEN = 32,
  parameter XLEN = 32,

  parameter config_t CONFIG = 'x,

  parameter TILEID   = 'x,
  parameter COREBASE = 'x,

  localparam CHANNELS   = CONFIG.NOC_CHANNELS,
  localparam FLIT_WIDTH = CONFIG.NOC_FLIT_WIDTH
) (
`ifdef OPTIMSOC_CLOCKDOMAINS
`ifdef OPTIMSOC_CDC_DYNAMIC
  output [2:0] cdc_conf,
  output       cdc_enable,
`endif
`endif

  input clk,
  input rst,

  input  [CHANNELS-1:0][FLIT_WIDTH-1:0] noc_in_flit,
  input  [CHANNELS-1:0]                 noc_in_last,
  input  [CHANNELS-1:0]                 noc_in_valid,
  output [CHANNELS-1:0]                 noc_in_ready,

  output [CHANNELS-1:0][FLIT_WIDTH-1:0] noc_out_flit,
  output [CHANNELS-1:0]                 noc_out_last,
  output [CHANNELS-1:0]                 noc_out_valid,
  input  [CHANNELS-1:0]                 noc_out_ready,

  output            ahb4m_hsel_o,
  output [PLEN-1:0] ahb4m_haddr_o,
  output [XLEN-1:0] ahb4m_hwdata_o,
  output            ahb4m_hwrite_o,
  output [     2:0] ahb4m_hsize_o,
  output [     2:0] ahb4m_hburst_o,
  output [     3:0] ahb4m_hprot_o,
  output [     1:0] ahb4m_htrans_o,
  output            ahb4m_hmastlock_o,

  input [XLEN-1:0] ahb4m_hrdata_i,
  input            ahb4m_hready_i,
  input            ahb4m_hresp_i,

  input            ahb4s_hsel_i,
  input [PLEN-1:0] ahb4s_haddr_i,
  input [XLEN-1:0] ahb4s_hwdata_i,
  input            ahb4s_hwrite_i,
  input [     2:0] ahb4s_hsize_i,
  input [     2:0] ahb4s_hburst_i,
  input [     3:0] ahb4s_hprot_i,
  input [     1:0] ahb4s_htrans_i,
  input            ahb4s_hmastlock_i,

  output [XLEN-1:0] ahb4s_hrdata_o,
  output            ahb4s_hready_o,
  output            ahb4s_hresp_o,

  output [1:0] irq
);

  //////////////////////////////////////////////////////////////////////////////
  // Constants
  //////////////////////////////////////////////////////////////////////////////

  // Those are the actual channels from the modules
  localparam C_MPSIMPLE_REQ = 0;
  localparam C_MPSIMPLE_RES = 1;
  localparam C_DMA_REQ = 2;
  localparam C_DMA_RES = 3;
  localparam MODCHANNELS = 4;

  // The different interfaces at the bus slave
  //  slave 0: configuration
  //           NABASE + 0x000000
  //  slave 1: mp_simple
  //           NABASE + 0x100000
  //  slave 2: dma
  //           NABASE + 0x200000
  // If a slave is not present there is a gap

  localparam ID_CONF = 0;
  localparam ID_MPSIMPLE = 1;
  localparam ID_DMA = 2;
  localparam SLAVES = 3;  // This is the number of maximum slaves

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////

  wire [MODCHANNELS-1:0]                 mod_out_ready;
  wire [MODCHANNELS-1:0]                 mod_out_valid;
  wire [MODCHANNELS-1:0]                 mod_out_last;
  wire [MODCHANNELS-1:0][FLIT_WIDTH-1:0] mod_out_flit;
  wire [MODCHANNELS-1:0]                 mod_in_ready;
  wire [MODCHANNELS-1:0]                 mod_in_valid;
  wire [MODCHANNELS-1:0]                 mod_in_last;
  wire [MODCHANNELS-1:0][FLIT_WIDTH-1:0] mod_in_flit;

  wire [     SLAVES-1:0]                 ahb4if_hsel_i;
  wire [     SLAVES-1:0][          23:0] ahb4if_haddr_i;
  wire [     SLAVES-1:0][      XLEN-1:0] ahb4if_hwdata_i;
  wire [     SLAVES-1:0]                 ahb4if_hwrite_i;
  wire [     SLAVES-1:0][           2:0] ahb4if_hsize_i;
  wire [     SLAVES-1:0][           2:0] ahb4if_hburst_i;
  wire [     SLAVES-1:0][           3:0] ahb4if_hprot_i;
  wire [     SLAVES-1:0][           1:0] ahb4if_htrans_i;
  wire [     SLAVES-1:0]                 ahb4if_hmastlock_i;

  wire [     SLAVES-1:0][      XLEN-1:0] ahb4if_hrdata_o;
  wire [     SLAVES-1:0]                 ahb4if_hready_o;
  wire [     SLAVES-1:0]                 ahb4if_hresp_o;

  //////////////////////////////////////////////////////////////////////////////
  // Body
  //////////////////////////////////////////////////////////////////////////////

  soc_decode_ahb4 #(
    .SLAVES        (3),
    .XLEN          (32),
    .PLEN          (24),
    .S0_RANGE_WIDTH(4),
    .S0_RANGE_MATCH(4'h0),
    .S1_RANGE_WIDTH(4),
    .S1_RANGE_MATCH(4'h1),
    .S2_RANGE_WIDTH(4),
    .S2_RANGE_MATCH(4'h2)
  ) u_slavedecode (
    .clk_i(clk),
    .rst_i(rst),

    .m_hsel_i     (ahb4s_hsel_i),
    .m_haddr_i    (ahb4s_haddr_i[23:0]),
    .m_hwdata_i   (ahb4s_hwdata_i),
    .m_hwrite_i   (ahb4s_hwrite_i),
    .m_hsize_i    (ahb4s_hsize_i),
    .m_hburst_i   (ahb4s_hburst_i),
    .m_hprot_i    (ahb4s_hprot_i),
    .m_htrans_i   (ahb4s_htrans_i),
    .m_hmastlock_i(ahb4s_hmastlock_i),

    .m_hrdata_o(ahb4s_hrdata_o),
    .m_hready_o(ahb4s_hready_o),
    .m_hresp_o (ahb4s_hresp_o),

    .s_hsel_o     (ahb4if_hsel_i),
    .s_haddr_o    (ahb4if_haddr_i),
    .s_hwdata_o   (ahb4if_hwdata_i),
    .s_hwrite_o   (ahb4if_hwrite_i),
    .s_hsize_o    (ahb4if_hsize_i),
    .s_hburst_o   (ahb4if_hburst_i),
    .s_hprot_o    (ahb4if_hprot_i),
    .s_htrans_o   (ahb4if_htrans_i),
    .s_hmastlock_o(ahb4if_hmastlock_i),

    .s_hrdata_i(ahb4if_hrdata_o),
    .s_hready_i(ahb4if_hready_o),
    .s_hresp_i (ahb4if_hresp_o)
  );

  soc_network_adapter_configuration #(
    .CONFIG  (CONFIG),
    .TILEID  (TILEID),
    .COREBASE(COREBASE)
  ) u_conf (
`ifdef OPTIMSOC_CLOCKDOMAINS
`ifdef OPTIMSOC_CDC_DYNAMIC
    .cdc_conf  (cdc_conf[2:0]),
    .cdc_enable(cdc_enable),
`endif
`endif
    .clk       (clk),
    .rst       (rst),

    .hsel     (ahb4s_hsel_i),
    .haddr    (ahb4s_haddr_i[15:0]),
    .hwrite   (ahb4s_hwrite_i),
    .hsize    (ahb4s_hsize_i),
    .hburst   (ahb4s_hburst_i),
    .hprot    (ahb4s_hprot_i),
    .htrans   (ahb4s_htrans_i),
    .hmastlock(ahb4s_hmastlock_i),

    .hrdata(ahb4if_hrdata_o[ID_CONF]),
    .hwdata(ahb4if_hwdata_i[ID_CONF]),

    .hready(ahb4if_hready_o[ID_CONF]),
    .hresp (ahb4if_hresp_o[ID_CONF])
  );

  peripheral_mpi_ahb4 #(
    .PLEN(PLEN),
    .XLEN(XLEN),

    .NOC_FLIT_WIDTH(CONFIG.NOC_FLIT_WIDTH),
    .SIZE          (16),
    .N             (2)
  ) u_mpi (
    .*,
    .noc_out_flit ({mod_out_flit[C_MPSIMPLE_RES], mod_out_flit[C_MPSIMPLE_REQ]}),
    .noc_out_last ({mod_out_last[C_MPSIMPLE_RES], mod_out_last[C_MPSIMPLE_REQ]}),
    .noc_out_valid({mod_out_valid[C_MPSIMPLE_RES], mod_out_valid[C_MPSIMPLE_REQ]}),
    .noc_out_ready({mod_out_ready[C_MPSIMPLE_RES], mod_out_ready[C_MPSIMPLE_REQ]}),

    .noc_in_flit ({mod_in_flit[C_MPSIMPLE_RES], mod_in_flit[C_MPSIMPLE_REQ]}),
    .noc_in_last ({mod_in_last[C_MPSIMPLE_RES], mod_in_last[C_MPSIMPLE_REQ]}),
    .noc_in_valid({mod_in_valid[C_MPSIMPLE_RES], mod_in_valid[C_MPSIMPLE_REQ]}),
    .noc_in_ready({mod_in_ready[C_MPSIMPLE_RES], mod_in_ready[C_MPSIMPLE_REQ]}),

    .ahb4_hsel_i     (ahb4if_hsel_i[ID_MPSIMPLE]),
    .ahb4_haddr_i    ({8'h0, ahb4if_haddr_i[ID_MPSIMPLE]}),
    .ahb4_hwdata_i   (ahb4if_hwdata_i[ID_MPSIMPLE]),
    .ahb4_hwrite_i   (ahb4if_hwrite_i[ID_MPSIMPLE]),
    .ahb4_hsize_i    (ahb4if_hsize_i[ID_MPSIMPLE]),
    .ahb4_hburst_i   (ahb4if_hburst_i[ID_MPSIMPLE]),
    .ahb4_hprot_i    (ahb4if_hprot_i[ID_MPSIMPLE]),
    .ahb4_htrans_i   (ahb4if_htrans_i[ID_MPSIMPLE]),
    .ahb4_hmastlock_i(ahb4if_hmastlock_i[ID_MPSIMPLE]),

    .ahb4_hrdata_o(ahb4if_hrdata_o[ID_MPSIMPLE]),
    .ahb4_hready_o(ahb4if_hready_o[ID_MPSIMPLE]),
    .ahb4_hresp_o (ahb4if_hresp_o[ID_MPSIMPLE]),

    .irq(irq[0])
  );

  generate
    if (CONFIG.NA_ENABLE_DMA) begin
      wire [3:0] irq_dma;
      assign irq[1] = |irq_dma;

      wire [1:0][CONFIG.NOC_FLIT_WIDTH+1:0] dma_in_flit, dma_out_flit;
      assign dma_in_flit[0]          = {mod_in_last[C_DMA_REQ], 1'b0, mod_in_flit[C_DMA_REQ]};
      assign dma_in_flit[1]          = {mod_in_last[C_DMA_RES], 1'b0, mod_in_flit[C_DMA_RES]};
      assign mod_out_last[C_DMA_REQ] = dma_out_flit[0][CONFIG.NOC_FLIT_WIDTH+1];
      assign mod_out_flit[C_DMA_REQ] = dma_out_flit[0][CONFIG.NOC_FLIT_WIDTH-1:0];
      assign mod_out_last[C_DMA_RES] = dma_out_flit[1][CONFIG.NOC_FLIT_WIDTH+1];
      assign mod_out_flit[C_DMA_RES] = dma_out_flit[1][CONFIG.NOC_FLIT_WIDTH-1:0];

      peripheral_dma_top_ahb4 #(
        .TILEID       (TILEID),
        .TABLE_ENTRIES(CONFIG.NA_DMA_ENTRIES)
      ) u_dma (
        .clk(clk),
        .rst(rst),

        .noc_in_req_flit (dma_in_flit[0]),
        .noc_in_req_valid(mod_in_valid[C_DMA_REQ]),
        .noc_in_req_ready(mod_in_ready[C_DMA_REQ]),

        .noc_in_res_ready(mod_in_ready[C_DMA_RES]),
        .noc_in_res_flit (dma_in_flit[1]),
        .noc_in_res_valid(mod_in_valid[C_DMA_RES]),

        .noc_out_req_flit (dma_out_flit[0]),
        .noc_out_req_valid(mod_out_valid[C_DMA_REQ]),
        .noc_out_res_ready(mod_out_ready[C_DMA_RES]),

        .noc_out_res_flit (dma_out_flit[1]),
        .noc_out_res_valid(mod_out_valid[C_DMA_RES]),
        .noc_out_req_ready(mod_out_ready[C_DMA_REQ]),

        .ahb4_if_hsel     (ahb4if_hsel_i[ID_DMA]),
        .ahb4_if_haddr    ({8'h0, ahb4if_haddr_i[ID_DMA]}),
        .ahb4_if_hwdata   (ahb4if_hwdata_i[ID_DMA]),
        .ahb4_if_hwrite   (ahb4if_hwrite_i[ID_DMA]),
        .ahb4_if_hsize    (ahb4if_hsize_i[ID_DMA]),
        .ahb4_if_hburst   (ahb4if_hburst_i[ID_DMA]),
        .ahb4_if_hprot    (ahb4if_hprot_i[ID_DMA]),
        .ahb4_if_htrans   (ahb4if_htrans_i[ID_DMA]),
        .ahb4_if_hmastlock(ahb4if_hmastlock_i[ID_DMA]),

        .ahb4_if_hrdata(ahb4if_hrdata_o[ID_DMA]),
        .ahb4_if_hready(ahb4if_hready_o[ID_DMA]),
        .ahb4_if_hresp (ahb4if_hresp_o[ID_DMA]),

        .ahb4_hsel     (ahb4m_hsel_o),
        .ahb4_haddr    (ahb4m_haddr_o),
        .ahb4_hwdata   (ahb4m_hwdata_o),
        .ahb4_hwrite   (ahb4m_hwrite_o),
        .ahb4_hsize    (ahb4m_hsize_o),
        .ahb4_hburst   (ahb4m_hburst_o),
        .ahb4_hprot    (ahb4m_hprot_o),
        .ahb4_htrans   (ahb4m_htrans_o),
        .ahb4_hmastlock(ahb4m_hmastlock_o),

        .ahb4_hrdata(ahb4m_hrdata_i),
        .ahb4_hready(ahb4m_hready_i),
        .ahb4_hresp (ahb4m_hresp_i),

        .irq(irq_dma)
      );
    end else begin
      assign irq[1] = 1'b0;
    end
  endgenerate

  wire [1:0][FLIT_WIDTH-1:0] muxed_flit;
  wire [1:0] muxed_last, muxed_valid, muxed_ready;

  peripheral_noc_mux #(
    .FLIT_WIDTH(FLIT_WIDTH),
    .CHANNELS  (2)
  ) u_mux0 (
    .*,
    .in_flit  ({mod_out_flit[C_MPSIMPLE_REQ], mod_out_flit[C_DMA_REQ]}),
    .in_last  ({mod_out_last[C_MPSIMPLE_REQ], mod_out_last[C_DMA_REQ]}),
    .in_valid ({mod_out_valid[C_MPSIMPLE_REQ], mod_out_valid[C_DMA_REQ]}),
    .in_ready ({mod_out_ready[C_MPSIMPLE_REQ], mod_out_ready[C_DMA_REQ]}),
    .out_flit (muxed_flit[0]),
    .out_last (muxed_last[0]),
    .out_valid(muxed_valid[0]),
    .out_ready(muxed_ready[0])
  );

  peripheral_noc_mux #(
    .FLIT_WIDTH(FLIT_WIDTH),
    .CHANNELS  (2)
  ) u_mux1 (
    .*,
    .in_flit  ({mod_out_flit[C_MPSIMPLE_RES], mod_out_flit[C_DMA_RES]}),
    .in_last  ({mod_out_last[C_MPSIMPLE_RES], mod_out_last[C_DMA_RES]}),
    .in_valid ({mod_out_valid[C_MPSIMPLE_RES], mod_out_valid[C_DMA_RES]}),
    .in_ready ({mod_out_ready[C_MPSIMPLE_RES], mod_out_ready[C_DMA_RES]}),
    .out_flit (muxed_flit[1]),
    .out_last (muxed_last[1]),
    .out_valid(muxed_valid[1]),
    .out_ready(muxed_ready[1])
  );

  peripheral_noc_buffer #(
    .FLIT_WIDTH(FLIT_WIDTH),
    .DEPTH     (4)
  ) u_outbuffer0 (
    .*,
    .in_flit    (muxed_flit[0]),
    .in_last    (muxed_last[0]),
    .in_valid   (muxed_valid[0]),
    .in_ready   (muxed_ready[0]),
    .out_flit   (noc_out_flit[0]),
    .out_last   (noc_out_last[0]),
    .out_valid  (noc_out_valid[0]),
    .out_ready  (noc_out_ready[0]),
    .packet_size()
  );

  peripheral_noc_buffer #(
    .FLIT_WIDTH(FLIT_WIDTH),
    .DEPTH     (4)
  ) u_outbuffer1 (
    .*,
    .in_flit    (muxed_flit[1]),
    .in_last    (muxed_last[1]),
    .in_valid   (muxed_valid[1]),
    .in_ready   (muxed_ready[1]),
    .out_flit   (noc_out_flit[1]),
    .out_last   (noc_out_last[1]),
    .out_valid  (noc_out_valid[1]),
    .out_ready  (noc_out_ready[1]),
    .packet_size()
  );

  wire [1:0][FLIT_WIDTH-1:0] inbuffer_flit;
  wire [1:0]                 inbuffer_last;
  wire [1:0]                 inbuffer_valid;
  wire [1:0]                 inbuffer_ready;

  peripheral_noc_buffer #(
    .FLIT_WIDTH(FLIT_WIDTH),
    .DEPTH     (4)
  ) u_inbuffer0 (
    .*,
    .in_flit    (noc_in_flit[0]),
    .in_last    (noc_in_last[0]),
    .in_valid   (noc_in_valid[0]),
    .in_ready   (noc_in_ready[0]),
    .out_flit   (inbuffer_flit[0]),
    .out_last   (inbuffer_last[0]),
    .out_valid  (inbuffer_valid[0]),
    .out_ready  (inbuffer_ready[0]),
    .packet_size()
  );

  peripheral_noc_demux #(
    .FLIT_WIDTH(FLIT_WIDTH),
    .CHANNELS  (2),
    .MAPPING   ({48'h0, 8'h2, 8'h1})
  ) u_demux0 (
    .*,
    .in_flit  (inbuffer_flit[0]),
    .in_last  (inbuffer_last[0]),
    .in_valid (inbuffer_valid[0]),
    .in_ready (inbuffer_ready[0]),
    .out_flit ({mod_in_flit[C_DMA_REQ], mod_in_flit[C_MPSIMPLE_REQ]}),
    .out_last ({mod_in_last[C_DMA_REQ], mod_in_last[C_MPSIMPLE_REQ]}),
    .out_valid({mod_in_valid[C_DMA_REQ], mod_in_valid[C_MPSIMPLE_REQ]}),
    .out_ready({mod_in_ready[C_DMA_REQ], mod_in_ready[C_MPSIMPLE_REQ]})
  );

  peripheral_noc_buffer #(
    .FLIT_WIDTH(FLIT_WIDTH),
    .DEPTH     (4)
  ) u_inbuffer1 (
    .*,
    .in_flit    (noc_in_flit[1]),
    .in_last    (noc_in_last[1]),
    .in_valid   (noc_in_valid[1]),
    .in_ready   (noc_in_ready[1]),
    .out_flit   (inbuffer_flit[1]),
    .out_last   (inbuffer_last[1]),
    .out_valid  (inbuffer_valid[1]),
    .out_ready  (inbuffer_ready[1]),
    .packet_size()
  );

  peripheral_noc_demux #(
    .FLIT_WIDTH(FLIT_WIDTH),
    .CHANNELS  (2),
    .MAPPING   ({48'h0, 8'h2, 8'h1})
  ) u_demux1 (
    .*,
    .in_flit  (inbuffer_flit[1]),
    .in_last  (inbuffer_last[1]),
    .in_valid (inbuffer_valid[1]),
    .in_ready (inbuffer_ready[1]),
    .out_flit ({mod_in_flit[C_DMA_RES], mod_in_flit[C_MPSIMPLE_RES]}),
    .out_last ({mod_in_last[C_DMA_RES], mod_in_last[C_MPSIMPLE_RES]}),
    .out_valid({mod_in_valid[C_DMA_RES], mod_in_valid[C_MPSIMPLE_RES]}),
    .out_ready({mod_in_ready[C_DMA_RES], mod_in_ready[C_MPSIMPLE_RES]})
  );
endmodule
