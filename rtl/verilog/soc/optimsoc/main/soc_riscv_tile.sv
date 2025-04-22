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

import peripheral_dbg_soc_dii_channel::dii_flit;
import opensocdebug::peripheral_dbg_soc_mriscv_trace_exec;
import soc_optimsoc_configuration::*;
import soc_optimsoc_functions::*;

module soc_riscv_tile #(
  parameter PLEN = 32,
  parameter XLEN = 32,

  parameter config_t CONFIG = 'x,

  parameter ID       = 'x,
  parameter COREBASE = 'x,

  parameter DEBUG_BASEID = 'x,

  parameter MEM_FILE = 'x,

  localparam CHANNELS   = CONFIG.NOC_CHANNELS,
  localparam FLIT_WIDTH = CONFIG.NOC_FLIT_WIDTH
) (
  input  dii_flit [1:0] debug_ring_in,
  output dii_flit [1:0] debug_ring_out,

  output [1:0] debug_ring_in_ready,
  input  [1:0] debug_ring_out_ready,

  output            ahb4_ext_hsel_i,
  output [PLEN-1:0] ahb4_ext_haddr_i,
  output [XLEN-1:0] ahb4_ext_hwdata_i,
  output            ahb4_ext_hwrite_i,
  output [     2:0] ahb4_ext_hsize_i,
  output [     2:0] ahb4_ext_hburst_i,
  output [     3:0] ahb4_ext_hprot_i,
  output [     1:0] ahb4_ext_htrans_i,
  output            ahb4_ext_hmastlock_i,

  input [XLEN-1:0] ahb4_ext_hrdata_o,
  input            ahb4_ext_hready_o,
  input            ahb4_ext_hresp_o,

  input clk,
  input rst_dbg,
  input rst_cpu,
  input rst_sys,

  input  [CHANNELS-1:0][FLIT_WIDTH-1:0] noc_in_flit,
  input  [CHANNELS-1:0]                 noc_in_last,
  input  [CHANNELS-1:0]                 noc_in_valid,
  output [CHANNELS-1:0]                 noc_in_ready,
  output [CHANNELS-1:0][FLIT_WIDTH-1:0] noc_out_flit,
  output [CHANNELS-1:0]                 noc_out_last,
  output [CHANNELS-1:0]                 noc_out_valid,
  input  [CHANNELS-1:0]                 noc_out_ready
);

  //////////////////////////////////////////////////////////////////////////////
  // Constants
  //////////////////////////////////////////////////////////////////////////////

  localparam NR_MASTERS = CONFIG.CORES_PER_TILE * 2 + 1;
  localparam NR_SLAVES = 5;
  localparam SLAVE_DM = 0;
  localparam SLAVE_PGAS = 1;
  localparam SLAVE_NA = 2;
  localparam SLAVE_BOOT = 3;
  localparam SLAVE_UART = 4;

  localparam RISCV_FEATURE_FPU = (CONFIG.CORE_ENABLE_FPU ? "ENABLED" : "NONE");
  localparam RISCV_FEATURE_PERFCOUNTERS = (CONFIG.CORE_ENABLE_PERFCOUNTERS ? "ENABLED" : "NONE");
  localparam RISCV_FEATURE_DEBUGUNIT = "NONE";  // XXX: Enable debug unit with OSD CDM module (once it's ready)

  // create DI ring segment with routers
  localparam DEBUG_MODS_PER_TILE_NONZERO = (CONFIG.DEBUG_MODS_PER_TILE == 0) ? 1 : CONFIG.DEBUG_MODS_PER_TILE;

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////

  peripheral_dbg_soc_mriscv_trace_exec [CONFIG.CORES_PER_TILE-1:0] trace;

  logic            ahb4_mem_clk_i;
  logic            ahb4_mem_rst_i;

  logic            ahb4_mem_hsel_i;
  logic [PLEN-1:0] ahb4_mem_haddr_i;
  logic [XLEN-1:0] ahb4_mem_hwdata_i;
  logic            ahb4_mem_hwrite_i;
  logic [     2:0] ahb4_mem_hsize_i;
  logic [     2:0] ahb4_mem_hburst_i;
  logic [     3:0] ahb4_mem_hprot_i;
  logic [     1:0] ahb4_mem_htrans_i;
  logic            ahb4_mem_hmastlock_i;

  logic [XLEN-1:0] ahb4_mem_hrdata_o;
  logic            ahb4_mem_hready_o;
  logic            ahb4_mem_hresp_o;

  dii_flit [DEBUG_MODS_PER_TILE_NONZERO-1:0] dii_in;
  dii_flit [DEBUG_MODS_PER_TILE_NONZERO-1:0] dii_out;

  logic [DEBUG_MODS_PER_TILE_NONZERO-1:0] dii_in_ready;
  logic [DEBUG_MODS_PER_TILE_NONZERO-1:0] dii_out_ready;

  wire            busms_hsel_o      [0:NR_MASTERS-1];
  wire [PLEN-1:0] busms_haddr_o     [0:NR_MASTERS-1];
  wire [XLEN-1:0] busms_hwdata_o    [0:NR_MASTERS-1];
  wire            busms_hwrite_o    [0:NR_MASTERS-1];
  wire [     2:0] busms_hsize_o     [0:NR_MASTERS-1];
  wire [     2:0] busms_hburst_o    [0:NR_MASTERS-1];
  wire [     3:0] busms_hprot_o     [0:NR_MASTERS-1];
  wire [     1:0] busms_htrans_o    [0:NR_MASTERS-1];
  wire            busms_hmastlock_o [0:NR_MASTERS-1];

  wire [XLEN-1:0] busms_hrdata_i    [0:NR_MASTERS-1];
  wire            busms_hready_i    [0:NR_MASTERS-1];
  wire            busms_hresp_i     [0:NR_MASTERS-1];

  wire            bussl_hsel_i      [0:NR_SLAVES-1];
  wire [PLEN-1:0] bussl_haddr_i     [0:NR_SLAVES-1];
  wire [XLEN-1:0] bussl_hwdata_i    [0:NR_SLAVES-1];
  wire            bussl_hwrite_i    [0:NR_SLAVES-1];
  wire [     2:0] bussl_hsize_i     [0:NR_SLAVES-1];
  wire [     2:0] bussl_hburst_i    [0:NR_SLAVES-1];
  wire [     3:0] bussl_hprot_i     [0:NR_SLAVES-1];
  wire [     1:0] bussl_htrans_i    [0:NR_SLAVES-1];
  wire            bussl_hmastlock_i [0:NR_SLAVES-1];

  wire [XLEN-1:0] bussl_hrdata_o    [0:NR_SLAVES-1];
  wire            bussl_hready_o    [0:NR_SLAVES-1];
  wire            bussl_hresp_o     [0:NR_SLAVES-1];

  wire        snoop_enable;
  wire [31:0] snoop_adr;

  wire [31:0] pic_ints_i [0:CONFIG.CORES_PER_TILE-1];

  genvar c, m, s;

  wire  [NR_MASTERS-1:0]           busms_hsel_o_flat;
  wire  [NR_MASTERS-1:0][PLEN-1:0] busms_haddr_o_flat;
  wire  [NR_MASTERS-1:0][XLEN-1:0] busms_hwdata_o_flat;
  wire  [NR_MASTERS-1:0]           busms_hwrite_o_flat;
  wire  [NR_MASTERS-1:0][     2:0] busms_hsize_o_flat;
  wire  [NR_MASTERS-1:0][     2:0] busms_hburst_o_flat;
  wire  [NR_MASTERS-1:0][     3:0] busms_hprot_o_flat;
  wire  [NR_MASTERS-1:0][     1:0] busms_htrans_o_flat;
  wire  [NR_MASTERS-1:0]           busms_hmastlock_o_flat;

  wire  [NR_MASTERS-1:0][XLEN-1:0] busms_hrdata_i_flat;
  wire  [NR_MASTERS-1:0]           busms_hready_i_flat;
  wire  [NR_MASTERS-1:0]           busms_hresp_i_flat;

  wire  [ NR_SLAVES-1:0]           bussl_hsel_i_flat;
  wire  [ NR_SLAVES-1:0][PLEN-1:0] bussl_haddr_i_flat;
  wire  [ NR_SLAVES-1:0][XLEN-1:0] bussl_hwdata_i_flat;
  wire  [ NR_SLAVES-1:0]           bussl_hwrite_i_flat;
  wire  [ NR_SLAVES-1:0][     2:0] bussl_hsize_i_flat;
  wire  [ NR_SLAVES-1:0][     2:0] bussl_hburst_i_flat;
  wire  [ NR_SLAVES-1:0][     3:0] bussl_hprot_i_flat;
  wire  [ NR_SLAVES-1:0][     1:0] bussl_htrans_i_flat;
  wire  [ NR_SLAVES-1:0]           bussl_hmastlock_i_flat;

  wire  [ NR_SLAVES-1:0][XLEN-1:0] bussl_hrdata_o_flat;
  wire  [ NR_SLAVES-1:0]           bussl_hready_o_flat;
  wire  [ NR_SLAVES-1:0]           bussl_hresp_o_flat;

  // MAM - AHB4 adapter signals
  logic                            mam_dm_hsel_o;
  logic [      PLEN-1:0]           mam_dm_haddr_o;
  logic [      XLEN-1:0]           mam_dm_hwdata_o;
  logic                            mam_dm_hwrite_o;
  logic [           2:0]           mam_dm_hsize_o;
  logic [           2:0]           mam_dm_hburst_o;
  logic [           3:0]           mam_dm_hprot_o;
  logic [           1:0]           mam_dm_htrans_o;
  logic                            mam_dm_hmastlock_o;

  logic [      XLEN-1:0]           mam_dm_hrdata_i;
  logic                            mam_dm_hready_i;
  logic                            mam_dm_hresp_i;

  //////////////////////////////////////////////////////////////////////////////
  // Body
  //////////////////////////////////////////////////////////////////////////////

  assign pic_ints_i[0][31:5] = 27'h0;
  assign pic_ints_i[0][1:0]  = 2'b00;

  generate
    if (CONFIG.USE_DEBUG == 1) begin : gen_debug_ring
      genvar i;
      logic [CONFIG.DEBUG_MODS_PER_TILE-1:0][15:0] id_map;
      for (i = 0; i < CONFIG.DEBUG_MODS_PER_TILE; i = i + 1) begin
        assign id_map[i][15:0] = 16'(DEBUG_BASEID + i);
      end

      peripheral_dbg_soc_debug_ring_expand #(
        .BUFFER_SIZE(CONFIG.DEBUG_ROUTER_BUFFER_SIZE),
        .PORTS      (CONFIG.DEBUG_MODS_PER_TILE)
      ) u_debug_ring_segment (
        .clk          (clk),
        .rst          (rst_dbg),
        .id_map       (id_map),
        .dii_in       (dii_in),
        .dii_in_ready (dii_in_ready),
        .dii_out      (dii_out),
        .dii_out_ready(dii_out_ready),
        .ext_in       (debug_ring_in),
        .ext_in_ready (debug_ring_in_ready),
        .ext_out      (debug_ring_out),
        .ext_out_ready(debug_ring_out_ready)
      );
    end
  endgenerate

  generate
    for (m = 0; m < NR_MASTERS; m = m + 1) begin : gen_busms_flat
      assign busms_hsel_o_flat[m]      = busms_hsel_o[m];
      assign busms_haddr_o_flat[m]     = busms_haddr_o[m];
      assign busms_hwdata_o_flat[m]    = busms_hwdata_o[m];
      assign busms_hwrite_o_flat[m]    = busms_hwrite_o[m];
      assign busms_hsize_o_flat[m]     = busms_hsize_o[m];
      assign busms_hburst_o_flat[m]    = busms_hburst_o[m];
      assign busms_hprot_o_flat[m]     = busms_hprot_o[m];
      assign busms_htrans_o_flat[m]    = busms_htrans_o[m];
      assign busms_hmastlock_o_flat[m] = busms_hmastlock_o[m];

      assign busms_hrdata_i[m]         = busms_hrdata_i_flat[m];
      assign busms_hready_i[m]         = busms_hready_i_flat[m];
      assign busms_hresp_i[m]          = busms_hresp_i_flat[m];
    end

    for (s = 0; s < NR_SLAVES; s = s + 1) begin : gen_bussl_flat
      assign bussl_hsel_i[s]        = bussl_hsel_i_flat[s];
      assign bussl_haddr_i[s]       = bussl_haddr_i_flat[s];
      assign bussl_hwdata_i[s]      = bussl_hwdata_i_flat[s];
      assign bussl_hwrite_i[s]      = bussl_hwrite_i_flat[s];
      assign bussl_hsize_i[s]       = bussl_hsize_i_flat[s];
      assign bussl_hburst_i[s]      = bussl_hburst_i_flat[s];
      assign bussl_hprot_i[s]       = bussl_hprot_i_flat[s];
      assign bussl_htrans_i[s]      = bussl_htrans_i_flat[s];
      assign bussl_hmastlock_i[s]   = bussl_hmastlock_i_flat[s];

      assign bussl_hrdata_o_flat[s] = bussl_hrdata_o[s];
      assign bussl_hready_o_flat[s] = bussl_hready_o[s];
      assign bussl_hresp_o_flat[s]  = bussl_hresp_o[s];
    end
  endgenerate

  generate
    for (c = 1; c < CONFIG.CORES_PER_TILE; c = c + 1) begin
      assign pic_ints_i[c] = 32'h0;
    end
  endgenerate

  generate
    for (c = 0; c < CONFIG.CORES_PER_TILE; c = c + 1) begin : gen_cores
      pu_riscv_module_ahb4 #(
        .XLEN(XLEN),
        .PLEN(PLEN)
      ) u_core (
        // Common signals
        .HRESETn(rst_cpu),
        .HCLK   (clk),

        // PMA configuration
        .pma_cfg_i('0),
        .pma_adr_i('0),

        // AHB instruction
        .ins_HSEL     (busms_hsel_o[2*c]),
        .ins_HADDR    (busms_haddr_o[2*c][PLEN-1:0]),
        .ins_HWDATA   (busms_hwdata_o[2*c][XLEN-1:0]),
        .ins_HWRITE   (busms_hwrite_o[2*c]),
        .ins_HSIZE    (busms_hsize_o[2*c][2:0]),
        .ins_HBURST   (busms_hburst_o[2*c][2:0]),
        .ins_HPROT    (busms_hprot_o[2*c][3:0]),
        .ins_HTRANS   (busms_htrans_o[2*c][1:0]),
        .ins_HMASTLOCK(busms_hmastlock_o[2*c]),

        .ins_HRDATA(busms_hrdata_i[2*c][XLEN-1:0]),
        .ins_HREADY(busms_hready_i[2*c]),
        .ins_HRESP (busms_hresp_i[2*c]),

        // AHB data
        .dat_HSEL     (busms_hsel_o[2*c+1]),
        .dat_HADDR    (busms_haddr_o[2*c+1][PLEN-1:0]),
        .dat_HWDATA   (busms_hwdata_o[2*c+1][XLEN-1:0]),
        .dat_HWRITE   (busms_hwrite_o[2*c+1]),
        .dat_HSIZE    (busms_hsize_o[2*c+1][2:0]),
        .dat_HBURST   (busms_hburst_o[2*c+1][2:0]),
        .dat_HPROT    (busms_hprot_o[2*c+1][3:0]),
        .dat_HTRANS   (busms_htrans_o[2*c+1][1:0]),
        .dat_HMASTLOCK(busms_hmastlock_o[2*c+1]),

        .dat_HRDATA(busms_hrdata_i[2*c+1][XLEN-1:0]),
        .dat_HREADY(busms_hready_i[2*c+1]),
        .dat_HRESP (busms_hresp_i[2*c+1]),

        // Interrupts Interface
        .ext_nmi ('0),
        .ext_tint('0),
        .ext_sint('0),
        .ext_int ('0),

        // Debug Interface
        .dbg_stall('0),
        .dbg_strb ('0),
        .dbg_we   ('0),
        .dbg_addr ('0),
        .dbg_dati ('0),
        .dbg_dato (),
        .dbg_ack  (),
        .dbg_bp   ()
      );

      if (CONFIG.USE_DEBUG == 1) begin : gen_ctm_stm
        peripheral_dbg_soc_osd_stm_mriscv #(
          .MAX_PKT_LEN(CONFIG.DEBUG_MAX_PKT_LEN)
        ) u_stm (
          .clk            (clk),
          .rst            (rst_dbg),
          .id             (16'(DEBUG_BASEID + 1 + c * CONFIG.DEBUG_MODS_PER_CORE)),
          .debug_in       (dii_out[1+c*CONFIG.DEBUG_MODS_PER_CORE]),
          .debug_out      (dii_in[1+c*CONFIG.DEBUG_MODS_PER_CORE]),
          .debug_in_ready (dii_out_ready[1 + c*CONFIG.DEBUG_MODS_PER_CORE]),
          .debug_out_ready(dii_in_ready[1 + c*CONFIG.DEBUG_MODS_PER_CORE]),
          .trace_port     (trace[c])
        );

        peripheral_dbg_soc_osd_ctm_mriscv #(
          .MAX_PKT_LEN(CONFIG.DEBUG_MAX_PKT_LEN)
        ) u_ctm (
          .clk            (clk),
          .rst            (rst_dbg),
          .id             (16'(DEBUG_BASEID + 1 + c * CONFIG.DEBUG_MODS_PER_CORE + 1)),
          .debug_in       (dii_out[1 + c*CONFIG.DEBUG_MODS_PER_CORE + 1]),
          .debug_out      (dii_in[1 + c*CONFIG.DEBUG_MODS_PER_CORE + 1]),
          .debug_in_ready (dii_out_ready[1 + c*CONFIG.DEBUG_MODS_PER_CORE + 1]),
          .debug_out_ready(dii_in_ready[1 + c*CONFIG.DEBUG_MODS_PER_CORE + 1]),
          .trace_port     (trace[c])
        );
      end
    end
  endgenerate

  generate
    if (CONFIG.USE_DEBUG != 0 && CONFIG.DEBUG_DEM_UART != 0) begin : gen_dem_uart
      peripheral_dbg_soc_osd_dem_uart_ahb4 u_dem_uart (
        .clk            (clk),
        .rst            (rst_sys),
        .id             (16'(DEBUG_BASEID + CONFIG.DEBUG_MODS_PER_TILE - 1)),
        .irq            (pic_ints_i[0][2]),
        .debug_in       (dii_out[CONFIG.DEBUG_MODS_PER_TILE - 1]),
        .debug_out      (dii_in[CONFIG.DEBUG_MODS_PER_TILE - 1]),
        .debug_in_ready (dii_out_ready[CONFIG.DEBUG_MODS_PER_TILE - 1]),
        .debug_out_ready(dii_in_ready[CONFIG.DEBUG_MODS_PER_TILE - 1]),

        .ahb4_hsel_i     (bussl_hsel_i[SLAVE_UART]),
        .ahb4_haddr_i    (bussl_haddr_i[SLAVE_UART][3:0]),
        .ahb4_hwdata_i   (bussl_hwdata_i[SLAVE_UART]),
        .ahb4_hwrite_i   (bussl_hwrite_i[SLAVE_UART]),
        .ahb4_hsize_i    (bussl_hsize_i[SLAVE_UART]),
        .ahb4_hburst_i   (bussl_hburst_i[SLAVE_UART]),
        .ahb4_hprot_i    (bussl_hprot_i[SLAVE_UART]),
        .ahb4_htrans_i   (bussl_htrans_i[SLAVE_UART]),
        .ahb4_hmastlock_i(bussl_hmastlock_i[SLAVE_UART]),

        .ahb4_hrdata_o(bussl_hrdata_o[SLAVE_UART]),
        .ahb4_hready_o(bussl_hready_o[SLAVE_UART]),
        .ahb4_hresp_o (bussl_hresp_o[SLAVE_UART])
      );
    end
  endgenerate

  soc_b3_ahb4 #(
    .MASTERS       (NR_MASTERS),
    .SLAVES        (NR_SLAVES),
    .S0_ENABLE     (CONFIG.ENABLE_DM),
    .S0_RANGE_WIDTH(CONFIG.DM_RANGE_WIDTH),
    .S0_RANGE_MATCH(CONFIG.DM_RANGE_MATCH),
    .S1_ENABLE     (CONFIG.ENABLE_PGAS),
    .S1_RANGE_WIDTH(CONFIG.PGAS_RANGE_WIDTH),
    .S1_RANGE_MATCH(CONFIG.PGAS_RANGE_MATCH),
    .S2_RANGE_WIDTH(4),
    .S2_RANGE_MATCH(4'he),
    .S3_ENABLE     (CONFIG.ENABLE_BOOTROM),
    .S3_RANGE_WIDTH(4),
    .S3_RANGE_MATCH(4'hf),
    .S4_ENABLE     (CONFIG.DEBUG_DEM_UART),
    .S4_RANGE_WIDTH(28),
    .S4_RANGE_MATCH(28'h9000000)
  ) u_bus (
    .clk_i(clk),
    .rst_i(rst_sys),

    // Masters
    .m_hsel_i     (busms_hsel_o_flat),
    .m_haddr_i    (busms_haddr_o_flat),
    .m_hwdata_i   (busms_hwdata_o_flat),
    .m_hwrite_i   (busms_hwrite_o_flat),
    .m_hsize_i    (busms_hsize_o_flat),
    .m_hburst_i   (busms_hburst_o_flat),
    .m_hprot_i    (busms_hprot_o_flat),
    .m_htrans_i   (busms_htrans_o_flat),
    .m_hmastlock_i(busms_hmastlock_o_flat),

    .m_hrdata_o(busms_hrdata_i_flat),
    .m_hready_o(busms_hready_i_flat),
    .m_hresp_o (busms_hresp_i_flat),

    // Slaves
    .s_hsel_o     (bussl_hsel_i_flat),
    .s_haddr_o    (bussl_haddr_i_flat),
    .s_hwdata_o   (bussl_hwdata_i_flat),
    .s_hwrite_o   (bussl_hwrite_i_flat),
    .s_hsize_o    (bussl_hsize_i_flat),
    .s_hburst_o   (bussl_hburst_i_flat),
    .s_hprot_o    (bussl_hprot_i_flat),
    .s_htrans_o   (bussl_htrans_i_flat),
    .s_hmastlock_o(bussl_hmastlock_i_flat),

    .s_hrdata_i(bussl_hrdata_o_flat),
    .s_hready_i(bussl_hready_o_flat),
    .s_hresp_i (bussl_hresp_o_flat),

    .snoop_adr_o(snoop_adr),
    .snoop_en_o (snoop_enable),

    .bus_hold    (1'b0),
    .bus_hold_ack()
  );

  if (CONFIG.USE_DEBUG == 1) begin : gen_mam_dm_ahb4
    // MAM
    peripheral_dbg_soc_osd_mam_ahb4 #(
      .PLEN(16),
      .XLEN(XLEN),

      .MAX_PKT_LEN(CONFIG.DEBUG_MAX_PKT_LEN),
      .MEM_SIZE0  (CONFIG.LMEM_SIZE),
      .BASE_ADDR0 (0)
    ) u_mam_dm_ahb4 (
      .clk_i          (clk),
      .rst_i          (rst_dbg),
      .debug_in       (dii_out[0]),
      .debug_out      (dii_in[0]),
      .debug_in_ready (dii_out_ready[0]),
      .debug_out_ready(dii_in_ready[0]),

      .id(16'(DEBUG_BASEID)),

      .ahb4_hsel_o     (mam_dm_hsel_o),
      .ahb4_haddr_o    (mam_dm_haddr_o),
      .ahb4_hwdata_o   (mam_dm_hwdata_o),
      .ahb4_hwrite_o   (mam_dm_hwrite_o),
      .ahb4_hsize_o    (mam_dm_hsize_o),
      .ahb4_hburst_o   (mam_dm_hburst_o),
      .ahb4_hprot_o    (mam_dm_hprot_o),
      .ahb4_htrans_o   (mam_dm_htrans_o),
      .ahb4_hmastlock_o(mam_dm_hmastlock_o),

      .ahb4_hrdata_i(mam_dm_hrdata_i),
      .ahb4_hready_i(mam_dm_hready_i),
      .ahb4_hresp_i (mam_dm_hresp_i)
    );
  end

  if (CONFIG.ENABLE_DM) begin : gen_mam_adapter_ahb4
    peripheral_dbg_soc_mam_adapter_ahb4 #(
      .PLEN(PLEN),
      .XLEN(XLEN)
    ) u_mam_adapter_ahb4_dm (
      .ahb4_mam_hsel_o     (mam_dm_hsel_o),
      .ahb4_mam_haddr_o    (mam_dm_haddr_o),
      .ahb4_mam_hwdata_o   (mam_dm_hwdata_o),
      .ahb4_mam_hwrite_o   (mam_dm_hwrite_o),
      .ahb4_mam_hsize_o    (mam_dm_hsize_o),
      .ahb4_mam_hburst_o   (mam_dm_hburst_o),
      .ahb4_mam_hprot_o    (mam_dm_hprot_o),
      .ahb4_mam_htrans_o   (mam_dm_htrans_o),
      .ahb4_mam_hmastlock_o(mam_dm_hmastlock_o),

      .ahb4_mam_hrdata_i(mam_dm_hrdata_i),
      .ahb4_mam_hready_i(mam_dm_hready_i),
      .ahb4_mam_hresp_i (mam_dm_hresp_i),

      // Out
      .ahb4_out_hsel_i     (ahb4_mem_hsel_i),
      .ahb4_out_haddr_i    (ahb4_mem_haddr_i),
      .ahb4_out_hwdata_i   (ahb4_mem_hwdata_i),
      .ahb4_out_hwrite_i   (ahb4_mem_hwrite_i),
      .ahb4_out_hsize_i    (ahb4_mem_hsize_i),
      .ahb4_out_hburst_i   (ahb4_mem_hburst_i),
      .ahb4_out_hprot_i    (ahb4_mem_hprot_i),
      .ahb4_out_htrans_i   (ahb4_mem_htrans_i),
      .ahb4_out_hmastlock_i(ahb4_mem_hmastlock_i),

      .ahb4_out_hrdata_o(ahb4_mem_hrdata_o),
      .ahb4_out_hready_o(ahb4_mem_hready_o),
      .ahb4_out_hresp_o (ahb4_mem_hresp_o),

      .ahb4_out_clk_i(ahb4_mem_clk_i),
      .ahb4_out_rst_i(ahb4_mem_rst_i),

      // In
      .ahb4_in_hsel_i     (bussl_hsel_i[SLAVE_DM]),
      .ahb4_in_haddr_i    (bussl_haddr_i[SLAVE_DM]),
      .ahb4_in_hwdata_i   (bussl_hwdata_i[SLAVE_DM]),
      .ahb4_in_hwrite_i   (bussl_hwrite_i[SLAVE_DM]),
      .ahb4_in_hsize_i    (bussl_hsize_i[SLAVE_DM]),
      .ahb4_in_hburst_i   (bussl_hburst_i[SLAVE_DM]),
      .ahb4_in_hprot_i    (bussl_hprot_i[SLAVE_DM]),
      .ahb4_in_htrans_i   (bussl_htrans_i[SLAVE_DM]),
      .ahb4_in_hmastlock_i(bussl_hmastlock_i[SLAVE_DM]),

      .ahb4_in_hrdata_o(bussl_hrdata_o[SLAVE_DM]),
      .ahb4_in_hready_o(bussl_hready_o[SLAVE_DM]),
      .ahb4_in_hresp_o (bussl_hresp_o[SLAVE_DM]),

      .ahb4_in_clk_i(clk),
      .ahb4_in_rst_i(rst_sys)
    );
  end else begin
    assign mam_dm_hrdata_i          = '0;
    assign mam_dm_hready_i          = 1'b0;
    assign mam_dm_hresp_i           = 1'b0;

    assign bussl_hrdata_o[SLAVE_DM] = '0;
    assign bussl_hready_o[SLAVE_DM] = 1'b0;
    assign bussl_hresp_o[SLAVE_DM]  = 1'b0;
  end

  if (!CONFIG.ENABLE_PGAS) begin : gen_tieoff_pgas
    assign bussl_hrdata_o[SLAVE_PGAS] = '0;
    assign bussl_hready_o[SLAVE_PGAS] = 1'b0;
    assign bussl_hresp_o[SLAVE_PGAS]  = 1'b0;
  end

  generate
    if ((CONFIG.ENABLE_DM) && (CONFIG.LMEM_STYLE == PLAIN)) begin : gen_sram
      soc_sram_sp_ahb4 #(
        .XLEN         (XLEN),
        .PLEN         (clog2_width(CONFIG.LMEM_SIZE)),
        .MEM_SIZE_BYTE(CONFIG.LMEM_SIZE),
        .MEM_FILE     (MEM_FILE),
        .MEM_IMPL_TYPE("PLAIN")
      ) u_ram (

        .ahb4_clk_i(ahb4_mem_clk_i),
        .ahb4_rst_i(ahb4_mem_rst_i),

        .ahb4_hsel_i     (ahb4_mem_hsel_i),
        .ahb4_haddr_i    (ahb4_mem_haddr_i[clog2_width(CONFIG.LMEM_SIZE)-1:0]),
        .ahb4_hwdata_i   (ahb4_mem_hwdata_i),
        .ahb4_hwrite_i   (ahb4_mem_hwrite_i),
        .ahb4_hsize_i    (ahb4_mem_hsize_i),
        .ahb4_hburst_i   (ahb4_mem_hburst_i),
        .ahb4_hprot_i    (ahb4_mem_hprot_i),
        .ahb4_htrans_i   (ahb4_mem_htrans_i),
        .ahb4_hmastlock_i(ahb4_mem_hmastlock_i),

        .ahb4_hrdata_o(ahb4_mem_hrdata_o),
        .ahb4_hready_o(ahb4_mem_hready_o),
        .ahb4_hresp_o (ahb4_mem_hresp_o)
      );
    end else begin
      assign ahb4_ext_hsel_i      = ahb4_mem_hsel_i;
      assign ahb4_ext_haddr_i     = ahb4_mem_haddr_i;
      assign ahb4_ext_hwdata_i    = ahb4_mem_hwdata_i;
      assign ahb4_ext_hwrite_i    = ahb4_mem_hwrite_i;
      assign ahb4_ext_hsize_i     = ahb4_mem_hsize_i;
      assign ahb4_ext_hburst_i    = ahb4_mem_hburst_i;
      assign ahb4_ext_hprot_i     = ahb4_mem_hprot_i;
      assign ahb4_ext_htrans_i    = ahb4_mem_htrans_i;
      assign ahb4_ext_hmastlock_i = ahb4_mem_hmastlock_i;

      assign ahb4_mem_hrdata_o    = ahb4_ext_hrdata_o;
      assign ahb4_mem_hready_o    = ahb4_ext_hready_o;
      assign ahb4_mem_hresp_o     = ahb4_ext_hresp_o;
    end
  endgenerate

  soc_network_adapter_ct #(
    .CONFIG  (CONFIG),
    .TILEID  (ID),
    .COREBASE(COREBASE)
  ) u_na (
`ifdef OPTIMSOC_CLOCKDOMAINS
`ifdef OPTIMSOC_CDC_DYNAMIC
    .cdc_conf  (cdc_conf[2:0]),
    .cdc_enable(cdc_enable),
`endif
`endif
    .clk       (clk),
    .rst       (rst_sys),

    .noc_in_ready (noc_in_ready),
    .noc_out_flit (noc_out_flit),
    .noc_out_last (noc_out_last),
    .noc_out_valid(noc_out_valid),

    .noc_in_flit  (noc_in_flit),
    .noc_in_last  (noc_in_last),
    .noc_in_valid (noc_in_valid),
    .noc_out_ready(noc_out_ready),

    .irq(pic_ints_i[0][4:3]),

    // Masters
    .ahb4m_hsel_o     (busms_hsel_o[NR_MASTERS-1]),
    .ahb4m_haddr_o    (busms_haddr_o[NR_MASTERS-1]),
    .ahb4m_hwdata_o   (busms_hwdata_o[NR_MASTERS-1]),
    .ahb4m_hwrite_o   (busms_hwrite_o[NR_MASTERS-1]),
    .ahb4m_hsize_o    (busms_hsize_o[NR_MASTERS-1]),
    .ahb4m_hburst_o   (busms_hburst_o[NR_MASTERS-1]),
    .ahb4m_hprot_o    (busms_hprot_o[NR_MASTERS-1]),
    .ahb4m_htrans_o   (busms_htrans_o[NR_MASTERS-1]),
    .ahb4m_hmastlock_o(busms_hmastlock_o[NR_MASTERS-1]),

    .ahb4m_hrdata_i(busms_hrdata_i[NR_MASTERS-1]),
    .ahb4m_hready_i(busms_hready_i[NR_MASTERS-1]),
    .ahb4m_hresp_i (busms_hresp_i[NR_MASTERS-1]),

    // Slaves
    .ahb4s_hsel_i     (bussl_hsel_i[SLAVE_NA]),
    .ahb4s_haddr_i    (bussl_haddr_i[SLAVE_NA]),
    .ahb4s_hwdata_i   (bussl_hwdata_i[SLAVE_NA]),
    .ahb4s_hwrite_i   (bussl_hwrite_i[SLAVE_NA]),
    .ahb4s_hsize_i    (bussl_hsize_i[SLAVE_NA]),
    .ahb4s_hburst_i   (bussl_hburst_i[SLAVE_NA]),
    .ahb4s_hprot_i    (bussl_hprot_i[SLAVE_NA]),
    .ahb4s_htrans_i   (bussl_htrans_i[SLAVE_NA]),
    .ahb4s_hmastlock_i(bussl_hmastlock_i[SLAVE_NA]),

    .ahb4s_hrdata_o(bussl_hrdata_o[SLAVE_NA]),
    .ahb4s_hready_o(bussl_hready_o[SLAVE_NA]),
    .ahb4s_hresp_o (bussl_hresp_o[SLAVE_NA])
  );

  generate
    if (CONFIG.ENABLE_BOOTROM) begin : gen_soc_bootrom
      soc_bootrom u_bootrom (
        .clk(clk),
        .rst(rst_sys),

        // Outputs
        .ahb4_hrdata_o(bussl_hrdata_o[SLAVE_BOOT]),
        .ahb4_hready_o(bussl_hready_o[SLAVE_BOOT]),
        .ahb4_hresp_o (bussl_hresp_o[SLAVE_BOOT]),

        // Inputs
        .ahb4_hsel_i     (bussl_hsel_i[SLAVE_BOOT]),
        .ahb4_haddr_i    (bussl_haddr_i[SLAVE_BOOT]),
        .ahb4_hwdata_i   (bussl_hwdata_i[SLAVE_BOOT]),
        .ahb4_hwrite_i   (bussl_hwrite_i[SLAVE_BOOT]),
        .ahb4_hsize_i    (bussl_hsize_i[SLAVE_BOOT]),
        .ahb4_hburst_i   (bussl_hburst_i[SLAVE_BOOT]),
        .ahb4_hprot_i    (bussl_hprot_i[SLAVE_BOOT]),
        .ahb4_htrans_i   (bussl_htrans_i[SLAVE_BOOT]),
        .ahb4_hmastlock_i(bussl_hmastlock_i[SLAVE_BOOT])
      );
    end else begin
      assign bussl_hrdata_o[SLAVE_BOOT] = 'x;
      assign bussl_hready_o[SLAVE_BOOT] = 1'b0;
      assign bussl_hresp_o[SLAVE_BOOT]  = 1'b0;
    end
  endgenerate
endmodule
