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

import peripheral_ahb4_verilog_pkg::*;
import pu_riscv_verilog_pkg::*;

module soc_riscv_ahb4 #(
  parameter [15:0] JTAG_USERIDCODE = 16'h0,  // Upper 16-bit of IDCODE
  parameter [31:0] JTAG_USERCODE   = 32'h0,  // UserCode

  parameter TECHNOLOGY   = "GENERIC",  //GENERIC = inferred (FPGA)
  parameter INIT_FILE    = "",
  parameter BOOTROM_SIZE = 4,          // in kBytes
  parameter RAM_SIZE     = 4,          // in kBytes
  parameter SDRAM_SIZE   = 8,          // in MBytes

  parameter GPIO_CNT = 10,  // Number of (8port) GPIO blocks. Max 32
  parameter UART_CNT = 1,   // Number of UARTS. Max 31 (UART32=JSP)
  parameter I2C_CNT  = 0,   // Number of I2C blocks. Max 32 (not implemented yet)
  parameter SPI_CNT  = 0,   // Number of SPI blocks. Max 32 (not implemented yet)

  parameter USR_MAHB_CNT  = 1,  // Number of User AHB Master buses
  parameter USR_SAHB_CNT  = 3,  // Number of User AHB Slave buses
  parameter USR_APB8_CNT  = 1,  // Number of 8-bit User APB buses
  parameter USR_APB32_CNT = 2,  // Number of 32-bit User APB buses

  parameter USR_INT_CNT = 3,  // Number of user interrupts

  parameter APB_CLK_FREQ  = 25.0,  // in MHz
  parameter UART_BAUDRATE = 9600,

  // CPU options
  parameter XLEN      = 32,
  parameter PLEN      = 32,
  parameter PC_INIT   = 'h0010_0000,
  parameter HAS_USER  = 0,
  parameter HAS_SUPER = 0,
  parameter HAS_HYPER = 0,
  parameter HAS_BPU   = 1,
  parameter HAS_FPU   = 0,
  parameter HAS_MMU   = 0,
  parameter HAS_RVM   = 1,
  parameter HAS_RVA   = 0,
  parameter HAS_RVC   = 1,

  parameter MULT_LATENCY = 3,  // ECP5 too slow

  parameter BP_GLOBAL_BITS = 2,
  parameter BP_LOCAL_BITS  = 10,

  parameter ICACHE_SIZE        = 1,   // in KBytes
  parameter ICACHE_BLOCK_SIZE  = 32,  // in Bytes
  parameter ICACHE_WAYS        = 2,   // 'n'-way set associative
  parameter ICACHE_REPLACE_ALG = 0,

  parameter DCACHE_SIZE        = 1,   // in KBytes
  parameter DCACHE_BLOCK_SIZE  = 32,  // in Bytes
  parameter DCACHE_WAYS        = 2,   // 'n'-way set associative
  parameter DCACHE_REPLACE_ALG = 0,

  // Localparams
  localparam GPIO_CHK      = GPIO_CNT < 1 ? 1 : GPIO_CNT > 32 ? 32 : GPIO_CNT,
  localparam UART_CHK      = UART_CNT < 1 ? 1 : UART_CNT > 31 ? 31 : UART_CNT,  // UART32 = JSP
  localparam I2C_CHK       = I2C_CNT < 1 ? 1 : I2C_CNT > 32 ? 32 : I2C_CNT,
  localparam SPI_CHK       = SPI_CNT < 1 ? 1 : SPI_CNT > 32 ? 32 : SPI_CNT,
  localparam USR_MAHB_CHK  = USR_MAHB_CNT < 1 ? 1 : USR_MAHB_CNT,
  localparam USR_SAHB_CHK  = USR_SAHB_CNT < 1 ? 1 : USR_SAHB_CNT,
  localparam USR_APB8_CHK  = USR_APB8_CNT < 1 ? 1 : USR_APB8_CNT,
  localparam USR_APB32_CHK = USR_APB32_CNT < 1 ? 1 : USR_APB32_CNT,

  localparam EXT_HADDR_SIZE   = 24,
  localparam APB32_PADDR_SIZE = 20,
  localparam APB32_PDATA_SIZE = 32,
  localparam APB8_PADDR_SIZE  = 20,
  localparam APB8_PDATA_SIZE  = 8,

  localparam MAX_USR_SAHB  = 1 << $clog2(USR_SAHB_CHK),
  localparam MAX_USR_APB32 = 1 << $clog2(USR_APB32_CHK),
  localparam MAX_USR_APB8  = 1 << $clog2(USR_APB8_CHK),

  localparam USR_SAHB_HADDR_SIZE  = 25 - $clog2(MAX_USR_SAHB) - 1,
  localparam USR_APB32_PADDR_SIZE = APB32_PADDR_SIZE - $clog2(MAX_USR_APB32) - 1,
  localparam USR_APB8_PADDR_SIZE  = APB8_PADDR_SIZE - $clog2(MAX_USR_APB8) - 1,

  localparam SDRAM_PLEN = 31
) (
  // global power-on reset (for JTAG TAP)
  // JTAG interface (TAP controller)
  input  poweron_rst_ni,
  input  jtag_trst_ni,
  input  jtag_tck_i,
  input  jtag_tms_i,
  input  jtag_tdi_i,
  output jtag_tdo_o,
  output jtag_tdoe_o,

  // system Clock and Reset ports
  input rst_ahb_ni,  // AHB subsystem asynchronous, active low reset
  input clk_ahb_i,   // AHB subsystem clock

  input rst_apb_ni,  // APB asynchronos, active low reset
  input clk_apb_i,   // APB subsystem clock

  output rst_sys_o,  // Debug System Reset

  // SDRAM AHB
  output                            sdram_HSEL,
  output [SDRAM_PLEN          -1:0] sdram_HADDR,
  output [XLEN                -1:0] sdram_HWDATA,
  input  [XLEN                -1:0] sdram_HRDATA,
  output                            sdram_HWRITE,
  output [HSIZE_SIZE          -1:0] sdram_HSIZE,
  output [HBURST_SIZE         -1:0] sdram_HBURST,
  output [HPROT_SIZE          -1:0] sdram_HPROT,
  output [HTRANS_SIZE         -1:0] sdram_HTRANS,
  output                            sdram_HMASTLOCK,
  output                            sdram_HREADY,
  input                             sdram_HREADYOUT,
  input                             sdram_HRESP,

  // Ext (Flash) AHB
  output                            ext_HSEL,
  output [EXT_HADDR_SIZE      -1:0] ext_HADDR,
  output [XLEN                -1:0] ext_HWDATA,
  input  [XLEN                -1:0] ext_HRDATA,
  output                            ext_HWRITE,
  output [HSIZE_SIZE          -1:0] ext_HSIZE,
  output [HBURST_SIZE         -1:0] ext_HBURST,
  output [HPROT_SIZE          -1:0] ext_HPROT,
  output [HTRANS_SIZE         -1:0] ext_HTRANS,
  output                            ext_HMASTLOCK,
  output                            ext_HREADY,
  input                             ext_HREADYOUT,
  input                             ext_HRESP,

  // User Slave AHB
  output                            usr_HSEL     [USR_SAHB_CHK],
  output [USR_SAHB_HADDR_SIZE -1:0] usr_HADDR    [USR_SAHB_CHK],
  output [XLEN                -1:0] usr_HWDATA   [USR_SAHB_CHK],
  input  [XLEN                -1:0] usr_HRDATA   [USR_SAHB_CHK],
  output                            usr_HWRITE   [USR_SAHB_CHK],
  output [HSIZE_SIZE          -1:0] usr_HSIZE    [USR_SAHB_CHK],
  output [HBURST_SIZE         -1:0] usr_HBURST   [USR_SAHB_CHK],
  output [HPROT_SIZE          -1:0] usr_HPROT    [USR_SAHB_CHK],
  output [HTRANS_SIZE         -1:0] usr_HTRANS   [USR_SAHB_CHK],
  output                            usr_HMASTLOCK[USR_SAHB_CHK],
  output                            usr_HREADY   [USR_SAHB_CHK],
  input                             usr_HREADYOUT[USR_SAHB_CHK],
  input                             usr_HRESP    [USR_SAHB_CHK],

  // User 32b APB
  output                            usr_PSEL32   [USR_APB32_CHK],
  output                            usr_PENABLE32[USR_APB32_CHK],
  output [                     2:0] usr_PPROT32  [USR_APB32_CHK],
  output                            usr_PWRITE32 [USR_APB32_CHK],
  output [                     3:0] usr_PSTRB32  [USR_APB32_CHK],
  output [USR_APB32_PADDR_SIZE-1:0] usr_PADDR32  [USR_APB32_CHK],
  output [                    31:0] usr_PWDATA32 [USR_APB32_CHK],
  input  [                    31:0] usr_PRDATA32 [USR_APB32_CHK],
  input                             usr_PREADY32 [USR_APB32_CHK],
  input                             usr_PSLVERR32[USR_APB32_CHK],

  // User 8b APB
  output                            usr_PSEL8   [USR_APB8_CHK],
  output                            usr_PENABLE8[USR_APB8_CHK],
  output [                     2:0] usr_PPROT8  [USR_APB8_CHK],
  output                            usr_PWRITE8 [USR_APB8_CHK],
  output [USR_APB8_PADDR_SIZE -1:0] usr_PADDR8  [USR_APB8_CHK],
  output [                     7:0] usr_PWDATA8 [USR_APB8_CHK],
  input  [                     7:0] usr_PRDATA8 [USR_APB8_CHK],
  input                             usr_PREADY8 [USR_APB8_CHK],
  input                             usr_PSLVERR8[USR_APB8_CHK],

  // GPIOs
  input  [7:0] gpio_i   [GPIO_CHK],
  output [7:0] gpio_o   [GPIO_CHK],
  output [7:0] gpio_oe_o[GPIO_CHK],

  // UART
  input  uart_rxd_i[UART_CHK],
  output uart_txd_o[UART_CHK],

  // External Interrupts
  input [USR_INT_CNT         -1:0] int_usr_i
);

  //////////////////////////////////////////////////////////////////////////////
  // Constants
  //////////////////////////////////////////////////////////////////////////////

  localparam HADDR_SIZE = PLEN;
  localparam HDATA_SIZE = XLEN;

  // Masters                        Priority
  // 0: CPU Instruction Interface   2
  // 1: CPU Data Interface          3
  // 2: CPU Debug Interface         4
  // 3: DMA0                        0
  // 4: DMA1                        1

  // Slaves:
  // 0: BootROM
  // 1: RAM Block
  // 2: Timer
  // 3: AHB-2-APB 32-bit Interface
  // 4: AHB-2-APB 8-bit Interface
  // 5: SDRAM Memory
  // 6: External AHB
  // 7: User AHB

  localparam AHB_MASTERS = 3;
  localparam AHB_SLAVES = 7 + MAX_USR_SAHB;

  // Single IP for multiple timers
  localparam TIMERS = 3;

  // Master Switch Port Assignments
  localparam CPU_INS = 0;
  localparam CPU_DAT = 1;
  localparam CPU_DBG = 2;

  // Master Priority assignment
  localparam CPU_INS_PRIORITY = 0;
  localparam CPU_DAT_PRIORITY = 1;
  localparam CPU_DBG_PRIORITY = 2;

  // Slave Switch Port Assignments
  localparam BOOTROM = 0;
  localparam RAM = 1;
  localparam TIMER = 2;
  localparam AHB2APB_32b = 3;
  localparam AHB2APB_8b = 4;
  localparam DRAM = 5;
  localparam EXTAHB = 6;
  localparam USRAHB = 7;

  //  -- Memory Map --

  // Description  Space  Address                    Size
  // BOOTROM      64kB   0x0010_0000 - 0x0010_FFFF  4kB
  // RAM          64kB   0x0011_0000 - 0x0011_FFFF  4kB
  // TIMERS        4kB   0x0020_0000 - 0x0020_0FFF  64B
  // AHB2APB 8b    2MB   0x0040_0000 - 0x004F_FFFF
  // AHB2APB 32b   4MB   0x0080_0000 - 0x008F_FFFF
  // EXTAHB       16MB   0x0100_0000 - 0x01FF_FFFF  Flash
  // USRAHB       32MB   0x0200_0000 - 0x03FF_FFFF
  // DRAM          2GB   0x8000_0000 - 0xFFFF_FFFF

  localparam [PLEN-1:0] ALLONES = {PLEN{1'b1}};

  localparam [PLEN-1:0] BOOTROM_BASE = 'h0010_0000;
  localparam [PLEN-1:0] BOOTROM_MASK = ALLONES << 16;
  localparam [PLEN-1:0] RAM_BASE = 'h0011_0000;
  localparam [PLEN-1:0] RAM_MASK = ALLONES << 16;
  localparam [PLEN-1:0] TIMER_BASE = 'h0020_0000;
  localparam [PLEN-1:0] TIMER_MASK = ALLONES << 12;
  localparam [PLEN-1:0] AHB2APB_8b_BASE = 'h0040_0000;
  localparam [PLEN-1:0] AHB2APB_8b_MASK = ALLONES << 20;
  localparam [PLEN-1:0] AHB2APB_32b_BASE = 'h0080_0000;
  localparam [PLEN-1:0] AHB2APB_32b_MASK = ALLONES << 20;
  localparam [PLEN-1:0] EXTAHB_BASE = 'h0100_0000;
  localparam [PLEN-1:0] EXTAHB_MASK = ALLONES << 24;
  localparam [PLEN-1:0] USRAHB_BASE = 'h0200_0000;
  localparam [PLEN-1:0] USRAHB_BYTES = USRAHB_BASE / MAX_USR_SAHB;
  localparam [PLEN-1:0] USRAHB_MASK = ~{$clog2(USRAHB_BYTES) {1'b1}};
  localparam [PLEN-1:0] USRAHB_PMAMASK = ALLONES << 25;
  localparam [PLEN-1:0] DRAM_BASE = 'h8000_0000;
  localparam [PLEN-1:0] DRAM_MASK = ALLONES << 31;

  localparam PMA_CFG_CNT = 8;  // 8 memory type regions

  // PLIC configuration
  localparam PLIC_TARGETS = 1;  // only M-mode
  localparam PLIC_PRIORITIES = 3;
  localparam PLIC_PENDING_CNT = 3;
  localparam PLIC_HAS_THRESHOLD = 1;

  //////////////////////////////////////////////////////////////////////////////
  // Variables
  //////////////////////////////////////////////////////////////////////////////

  // Interrupts

  // NMI
  logic                              cpu_nmi;
  // timer interrupt
  logic                              cpu_tint;
  // machine software interrupt for interprocessor interrupts
  logic                              cpu_sint;
  // external interrupt per privilege mode (M=3,H=2,S=1,U=0)
  logic    [                    3:0] cpu_int;
  // Interrupt from PLIC (==external)
  logic                              plic_int;

  logic                              int_jsp;
  logic    [       UART_CHK    -1:0] int_uart;
  logic    [       GPIO_CHK    -1:0] int_gpio;
  logic    [       I2C_CHK     -1:0] int_i2c;
  logic    [       SPI_CHK     -1:0] int_spi;

  // PMA configuration
  logic [PMA_CNT-1:0][    13:0] pma_cfg;
  logic [PMA_CNT-1:0][XLEN-1:0] pma_adr;

  // AHB Buses

  // system ports
  logic                              HRESETn;
  logic                              HCLK;

  logic    [$clog2(AHB_MASTERS)-1:0] mstpriority    [AHB_MASTERS];
  logic                              mstHSEL        [AHB_MASTERS];
  logic    [HADDR_SIZE         -1:0] mstHADDR       [AHB_MASTERS];
  logic    [HDATA_SIZE         -1:0] mstHWDATA      [AHB_MASTERS];
  logic    [HDATA_SIZE         -1:0] mstHRDATA      [AHB_MASTERS];
  logic                              mstHWRITE      [AHB_MASTERS];
  logic    [                    2:0] mstHSIZE       [AHB_MASTERS];
  logic    [                    2:0] mstHBURST      [AHB_MASTERS];
  logic    [                    3:0] mstHPROT       [AHB_MASTERS];
  logic    [                    1:0] mstHTRANS      [AHB_MASTERS];
  logic                              mstHMASTLOCK   [AHB_MASTERS];
  logic                              mstHREADY      [AHB_MASTERS];
  logic                              mstHREADYOUT   [AHB_MASTERS];
  logic                              mstHRESP       [AHB_MASTERS];

  logic    [HADDR_SIZE         -1:0] slv_adrmask    [ AHB_SLAVES];
  logic    [HADDR_SIZE         -1:0] slv_adrbase    [ AHB_SLAVES];
  logic                              slvHSEL        [ AHB_SLAVES];
  logic    [HADDR_SIZE         -1:0] slvHADDR       [ AHB_SLAVES];
  logic    [HDATA_SIZE         -1:0] slvHWDATA      [ AHB_SLAVES];
  logic    [HDATA_SIZE         -1:0] slvHRDATA      [ AHB_SLAVES];
  logic                              slvHWRITE      [ AHB_SLAVES];
  logic    [                    2:0] slvHSIZE       [ AHB_SLAVES];
  logic    [                    2:0] slvHBURST      [ AHB_SLAVES];
  logic    [                    3:0] slvHPROT       [ AHB_SLAVES];
  logic    [                    1:0] slvHTRANS      [ AHB_SLAVES];
  logic                              slvHMASTLOCK   [ AHB_SLAVES];
  logic                              slvHREADYOUT   [ AHB_SLAVES];
  logic                              slvHREADY      [ AHB_SLAVES];
  logic                              slvHRESP       [ AHB_SLAVES];

  // APB bus
  logic                              PRESETn;
  logic                              PCLK;

  // 32-bit APB bus
  logic                              PSEL_32b;
  logic                              PENABLE_32b;
  logic    [                    2:0] PPROT_32b;
  logic                              PWRITE_32b;
  logic    [APB32_PDATA_SIZE/8 -1:0] PSTRB_32b;
  logic    [APB32_PADDR_SIZE   -1:0] PADDR_32b;
  logic    [APB32_PDATA_SIZE   -1:0] PWDATA_32b;
  logic    [APB32_PDATA_SIZE   -1:0] PRDATA_32b;
  logic                              PREADY_32b;
  logic                              PSLVERR_32b;

  // 8-bit APB bus
  logic                              PSEL_8b;
  logic                              PENABLE_8b;
  logic    [                    2:0] PPROT_8b;
  logic                              PWRITE_8b;
  logic    [APB8_PDATA_SIZE/8  -1:0] PSTRB_8b;
  logic    [APB8_PADDR_SIZE    -1:0] PADDR_8b;
  logic    [APB8_PDATA_SIZE    -1:0] PWDATA_8b;
  logic    [APB8_PDATA_SIZE    -1:0] PRDATA_8b;
  logic                              PREADY_8b;
  logic                              PSLVERR_8b;

  logic                              jsp_PSEL_8b;
  logic                              jsp_PENABLE_8b;
  logic                              jsp_PWRITE_8b;
  logic    [                    2:0] jsp_PADDR_8b;
  logic    [APB8_PDATA_SIZE    -1:0] jsp_PWDATA_8b;
  logic    [APB8_PDATA_SIZE    -1:0] jsp_PRDATA_8b;
  logic                              jsp_PREADY_8b;
  logic                              jsp_PSLVERR_8b;

  //////////////////////////////////////////////////////////////////////////////
  // Body
  //////////////////////////////////////////////////////////////////////////////

  // Clock & Reset
  assign HRESETn             = rst_ahb_ni;
  assign PRESETn             = rst_apb_ni;
  assign HCLK                = clk_ahb_i;
  assign PCLK                = clk_apb_i;

  // PMA struct (from CPU point of view)
  // mem_type = Memory Type (empty, main, IO)
  // r        = readable
  // w        = writeable
  // x        = executable
  // c        = cacheable
  // cc       = cache-coherent             (not used)
  // ri       = read-idempotent (IO memory, not used)
  // wi       = write-idempoten (IO memory, not used)
  // m        = misaligned access support
  // AMO      = Atomicity                  (not used)
  // a        = map-type (TOR=Top Of Range, NAPOT=Naturally Aligned Power of Two)

  // BootROM region
  // pma_adr is for a 34/56bit physical address
  assign pma_adr[0] = (BOOTROM_BASE | (~BOOTROM_MASK >> 1)) >> 2;
  assign pma_cfg[0] = {MEM_TYPE_IO, 8'b0000_0000, AMO_TYPE_NONE, NAPOT};

  // RAM Region
  assign pma_adr[1] = (RAM_BASE | (~RAM_MASK >> 1)) >> 2;
  assign pma_cfg[1] = {MEM_TYPE_MAIN, 8'b1110_0000, AMO_TYPE_NONE, NAPOT};

  // TIMER region
  assign pma_adr[2] = (TIMER_BASE | (~TIMER_MASK >> 1)) >> 2;
  assign pma_cfg[2] = {MEM_TYPE_IO, 8'b1100_0000, AMO_TYPE_NONE, NAPOT};

  // AHB2APB-8b region
  assign pma_adr[3] = (AHB2APB_8b_BASE | (~AHB2APB_8b_MASK >> 1)) >> 2;
  assign pma_cfg[3] = {MEM_TYPE_IO, 8'b1100_0000, AMO_TYPE_NONE, NAPOT};

  // AHB2APB-32b region
  assign pma_adr[4] = (AHB2APB_32b_BASE | (~AHB2APB_32b_MASK >> 1)) >> 2;
  assign pma_cfg[4] = {MEM_TYPE_IO, 8'b1100_0000, AMO_TYPE_NONE, NAPOT};

  // EXTAHB region
  assign pma_adr[5] = (EXTAHB_BASE | (~EXTAHB_MASK >> 1)) >> 2;
  assign pma_cfg[5] = {MEM_TYPE_IO, 8'b1100_0000, AMO_TYPE_NONE, NAPOT};

  // USRAHB region
  assign pma_adr[6] = (USRAHB_BASE | (~USRAHB_PMAMASK >> 1)) >> 2;
  assign pma_cfg[6] = {MEM_TYPE_IO, 8'b1100_0000, AMO_TYPE_NONE, NAPOT};

  // DRAM region
  assign pma_adr[7] = (DRAM_BASE | (~DRAM_MASK >> 1)) >> 2;
  assign pma_cfg[7] = {MEM_TYPE_MAIN, 8'b1111_0000, AMO_TYPE_NONE, NAPOT};

  // Instantiate RISC-V subsystem
  // - CPU(s)
  // - TAP controller
  // - Debug Interface
  // - JSP

  pu_riscv_system_ahb4 #(
    .XLEN     (XLEN),
    .PLEN     (PLEN),
    .PC_INIT  (PC_INIT),
    .HAS_USER (HAS_USER),
    .HAS_SUPER(HAS_SUPER),
    .HAS_HYPER(HAS_HYPER),
    .HAS_BPU  (HAS_BPU),
    .HAS_FPU  (HAS_FPU),
    .HAS_MMU  (HAS_MMU),
    .HAS_RVM  (HAS_RVM),
    .HAS_RVA  (HAS_RVA),
    .HAS_RVC  (HAS_RVC),

    .MULT_LATENCY(MULT_LATENCY),

    .PMA_CNT(PMA_CFG_CNT),
    .PMP_CNT(0),

    .BP_GLOBAL_BITS(BP_GLOBAL_BITS),
    .BP_LOCAL_BITS (BP_LOCAL_BITS),

    .ICACHE_SIZE       (ICACHE_SIZE),
    .ICACHE_BLOCK_SIZE (ICACHE_BLOCK_SIZE),
    .ICACHE_WAYS       (ICACHE_WAYS),
    .ICACHE_REPLACE_ALG(ICACHE_REPLACE_ALG),

    .DCACHE_SIZE       (DCACHE_SIZE),
    .DCACHE_BLOCK_SIZE (DCACHE_BLOCK_SIZE),
    .DCACHE_WAYS       (DCACHE_WAYS),
    .DCACHE_REPLACE_ALG(DCACHE_REPLACE_ALG),

    .TECHNOLOGY(TECHNOLOGY),

    .JTAG_USERIDCODE(JTAG_USERIDCODE),  //upper 16-bit
    .JTAG_USERCODE  (JTAG_USERCODE)
  ) cpu_subsys (
    // all 32-bit
    .poweron_rstn(poweron_rst_ni),
    .jtag_trstn  (jtag_trst_ni),
    .jtag_tck    (jtag_tck_i),
    .jtag_tms    (jtag_tms_i),
    .jtag_tdi    (jtag_tdi_i),
    .jtag_tdo    (jtag_tdo_o),
    .jtag_tdo_oe (jtag_tdoe_o),

    .pma_cfg_i(pma_cfg),
    .pma_adr_i(pma_adr),

    // Common signals
    .HRESETn(HRESETn),
    .HCLK   (HCLK),

    // CPU Instruction Interface
    .ins_HSEL     (mstHSEL[CPU_INS]),
    .ins_HADDR    (mstHADDR[CPU_INS]),
    .ins_HRDATA   (mstHRDATA[CPU_INS]),
    .ins_HWDATA   (mstHWDATA[CPU_INS]),
    .ins_HWRITE   (mstHWRITE[CPU_INS]),
    .ins_HSIZE    (mstHSIZE[CPU_INS]),
    .ins_HBURST   (mstHBURST[CPU_INS]),
    .ins_HPROT    (mstHPROT[CPU_INS]),
    .ins_HTRANS   (mstHTRANS[CPU_INS]),
    .ins_HMASTLOCK(mstHMASTLOCK[CPU_INS]),
    .ins_HREADY   (mstHREADY[CPU_INS]),
    .ins_HRESP    (mstHRESP[CPU_INS]),

    // CPU Data Interface
    .dat_HSEL     (mstHSEL[CPU_DAT]),
    .dat_HADDR    (mstHADDR[CPU_DAT]),
    .dat_HWDATA   (mstHWDATA[CPU_DAT]),
    .dat_HRDATA   (mstHRDATA[CPU_DAT]),
    .dat_HWRITE   (mstHWRITE[CPU_DAT]),
    .dat_HSIZE    (mstHSIZE[CPU_DAT]),
    .dat_HBURST   (mstHBURST[CPU_DAT]),
    .dat_HPROT    (mstHPROT[CPU_DAT]),
    .dat_HTRANS   (mstHTRANS[CPU_DAT]),
    .dat_HMASTLOCK(mstHMASTLOCK[CPU_DAT]),
    .dat_HREADY   (mstHREADY[CPU_DAT]),
    .dat_HRESP    (mstHRESP[CPU_DAT]),

    // Debug Memory Interface
    .dbg_HSEL     (mstHSEL[CPU_DBG]),
    .dbg_HADDR    (mstHADDR[CPU_DBG]),
    .dbg_HWDATA   (mstHWDATA[CPU_DBG]),
    .dbg_HRDATA   (mstHRDATA[CPU_DBG]),
    .dbg_HWRITE   (mstHWRITE[CPU_DBG]),
    .dbg_HSIZE    (mstHSIZE[CPU_DBG]),
    .dbg_HBURST   (mstHBURST[CPU_DBG]),
    .dbg_HPROT    (mstHPROT[CPU_DBG]),
    .dbg_HTRANS   (mstHTRANS[CPU_DBG]),
    .dbg_HMASTLOCK(mstHMASTLOCK[CPU_DBG]),
    .dbg_HREADY   (mstHREADY[CPU_DBG]),
    .dbg_HRESP    (mstHRESP[CPU_DBG]),

    .dbg_sysrst(rst_sys_o),

    // Debug JSP Interface
    .PRESETn    (PRESETn),
    .PCLK       (PCLK),
    .jsp_PSEL   (jsp_PSEL_8b),
    .jsp_PENABLE(jsp_PENABLE_8b),
    .jsp_PWRITE (jsp_PWRITE_8b),
    .jsp_PADDR  (jsp_PADDR_8b),
    .jsp_PWDATA (jsp_PWDATA_8b),
    .jsp_PRDATA (jsp_PRDATA_8b),
    .jsp_PREADY (jsp_PREADY_8b),
    .jsp_PSLVERR(jsp_PSLVERR_8b),

    // Interrupts
    .ext_nmi (cpu_nmi),
    .ext_int (cpu_int),
    .ext_sint(cpu_sint),
    .ext_tint(cpu_tint),

    .jsp_int(int_jsp)
  );

  // tie-off unused interrupt signals
  assign cpu_int[3]   = plic_int;
  assign cpu_int[2:0] = 3'h0;
  assign cpu_sint     = 1'b0;
  assign cpu_nmi      = 1'b0;  // watchdog timer?

  // Instantiate AHB Switch
  always_comb begin
    mstpriority[CPU_INS]     = CPU_INS_PRIORITY;
    mstpriority[CPU_DAT]     = CPU_DAT_PRIORITY;
    mstpriority[CPU_DBG]     = CPU_DBG_PRIORITY;

    slv_adrbase[BOOTROM]     = BOOTROM_BASE;
    slv_adrmask[BOOTROM]     = BOOTROM_MASK;
    slv_adrbase[RAM]         = RAM_BASE;
    slv_adrmask[RAM]         = RAM_MASK;
    slv_adrbase[TIMER]       = TIMER_BASE;
    slv_adrmask[TIMER]       = TIMER_MASK;

    slv_adrbase[AHB2APB_32b] = AHB2APB_32b_BASE;
    slv_adrmask[AHB2APB_32b] = AHB2APB_32b_MASK;
    slv_adrbase[AHB2APB_8b]  = AHB2APB_8b_BASE;
    slv_adrmask[AHB2APB_8b]  = AHB2APB_8b_MASK;
    slv_adrbase[DRAM]        = DRAM_BASE;
    slv_adrmask[DRAM]        = DRAM_MASK;
    slv_adrbase[EXTAHB]      = EXTAHB_BASE;
    slv_adrmask[EXTAHB]      = EXTAHB_MASK;

    for (int n = 0; n < MAX_USR_SAHB; n++) begin
      slv_adrbase[USRAHB + n] = USRAHB_BASE + n * USRAHB_BYTES;
      slv_adrmask[USRAHB + n] = USRAHB_MASK;
    end
  end

  peripheral_msi_interface_ahb4 #(
    .HADDR_SIZE(HADDR_SIZE),
    .HDATA_SIZE(XLEN),
    .MASTERS   (AHB_MASTERS),
    .SLAVES    (AHB_SLAVES)
  ) bus_matrix (
    // Common Interface
    .HRESETn(HRESETn),
    .HCLK   (HCLK),

    // Master Interfaces
    .mst_priority (mstpriority),
    .mst_HSEL     (mstHSEL),
    .mst_HADDR    (mstHADDR),
    .mst_HWDATA   (mstHWDATA),
    .mst_HRDATA   (mstHRDATA),
    .mst_HWRITE   (mstHWRITE),
    .mst_HSIZE    (mstHSIZE),
    .mst_HBURST   (mstHBURST),
    .mst_HPROT    (mstHPROT),
    .mst_HTRANS   (mstHTRANS),
    .mst_HMASTLOCK(mstHMASTLOCK),
    .mst_HREADYOUT(mstHREADY),
    .mst_HREADY   (mstHREADY),     // no other slaves on this bus
    .mst_HRESP    (mstHRESP),

    // Slave Interfaces
    .slv_addr_mask(slv_adrmask),
    .slv_addr_base(slv_adrbase),
    .slv_HSEL     (slvHSEL),
    .slv_HADDR    (slvHADDR),
    .slv_HWDATA   (slvHWDATA),
    .slv_HRDATA   (slvHRDATA),
    .slv_HWRITE   (slvHWRITE),
    .slv_HSIZE    (slvHSIZE),
    .slv_HBURST   (slvHBURST),
    .slv_HPROT    (slvHPROT),
    .slv_HTRANS   (slvHTRANS),
    .slv_HMASTLOCK(slvHMASTLOCK),
    .slv_HREADYOUT(slvHREADY),     // output to the bus
    .slv_HREADY   (slvHREADYOUT),  // input from the bus
    .slv_HRESP    (slvHRESP)
  );

  // AHB Peripherals

  // Boot ROM

  // Required to update bootrom using Diamond tools without resynthesizing design
  //`ifdef SIM
  localparam BOOTROM_TECHNOLOGY = "GENERIC";
  //`else
  // localparam BOOTROM_TECHNOLOGY = "LATTICE_DPRAM";
  //`endif
  peripheral_spram_ahb4 #(
    .MEM_SIZE         (BOOTROM_SIZE * 1024),
    .HADDR_SIZE       (HADDR_SIZE),
    .HDATA_SIZE       (HDATA_SIZE),
    .TECHNOLOGY       (BOOTROM_TECHNOLOGY),
    .REGISTERED_OUTPUT("YES"),
    .INIT_FILE        (INIT_FILE)
  ) bootrom_inst (
    .HRESETn(HRESETn),
    .HCLK   (HCLK),

    .HSEL     (slvHSEL[BOOTROM]),
    .HADDR    (slvHADDR[BOOTROM]),
    .HWDATA   (slvHWDATA[BOOTROM]),
    .HRDATA   (slvHRDATA[BOOTROM]),
    .HWRITE   (slvHWRITE[BOOTROM]),
    .HSIZE    (slvHSIZE[BOOTROM]),
    .HBURST   (slvHBURST[BOOTROM]),
    .HTRANS   (slvHTRANS[BOOTROM]),
    .HPROT    (slvHPROT[BOOTROM]),
    .HREADYOUT(slvHREADYOUT[BOOTROM]),
    .HREADY   (slvHREADY[BOOTROM]),
    .HRESP    (slvHRESP[BOOTROM])
  );

  // On-Chip RAM
  peripheral_spram_ahb4 #(
    .MEM_SIZE         (RAM_SIZE * 1024),
    .HADDR_SIZE       (HADDR_SIZE),
    .HDATA_SIZE       (HDATA_SIZE),
    .TECHNOLOGY       (TECHNOLOGY),
    .REGISTERED_OUTPUT("YES")
  ) ram_inst (
    .HRESETn(HRESETn),
    .HCLK   (HCLK),

    .HSEL     (slvHSEL[RAM]),
    .HADDR    (slvHADDR[RAM]),
    .HWDATA   (slvHWDATA[RAM]),
    .HRDATA   (slvHRDATA[RAM]),
    .HWRITE   (slvHWRITE[RAM]),
    .HSIZE    (slvHSIZE[RAM]),
    .HBURST   (slvHBURST[RAM]),
    .HTRANS   (slvHTRANS[RAM]),
    .HPROT    (slvHPROT[RAM]),
    .HREADYOUT(slvHREADYOUT[RAM]),
    .HREADY   (slvHREADY[RAM]),
    .HRESP    (slvHRESP[RAM])
  );

  // AHB Timer
  peripheral_timer_ahb4 #(
    .HADDR_SIZE(HADDR_SIZE),
    .HDATA_SIZE(HDATA_SIZE),
    .TIMERS    (TIMERS)
  ) timers (
    .HRESETn(HRESETn),
    .HCLK   (HCLK),

    .HSEL     (slvHSEL[TIMER]),
    .HADDR    (slvHADDR[TIMER]),
    .HWDATA   (slvHWDATA[TIMER]),
    .HRDATA   (slvHRDATA[TIMER]),
    .HWRITE   (slvHWRITE[TIMER]),
    .HSIZE    (slvHSIZE[TIMER]),
    .HBURST   (slvHBURST[TIMER]),
    .HPROT    (slvHPROT[TIMER]),
    .HTRANS   (slvHTRANS[TIMER]),
    .HREADYOUT(slvHREADYOUT[TIMER]),
    .HREADY   (slvHREADY[TIMER]),
    .HRESP    (slvHRESP[TIMER]),
    .tint     (cpu_tint)
  );

  // SDRAM AHB
  assign sdram_HSEL           = slvHSEL[DRAM];
  assign sdram_HADDR          = slvHADDR[DRAM][SDRAM_PLEN-1:0];
  assign sdram_HWDATA         = slvHWDATA[DRAM];
  assign slvHRDATA[DRAM]      = sdram_HRDATA;
  assign sdram_HWRITE         = slvHWRITE[DRAM];
  assign sdram_HSIZE          = slvHSIZE[DRAM];
  assign sdram_HBURST         = slvHBURST[DRAM];
  assign sdram_HPROT          = slvHPROT[DRAM];
  assign sdram_HTRANS         = slvHTRANS[DRAM];
  assign sdram_HMASTLOCK      = slvHMASTLOCK[DRAM];
  assign sdram_HREADY         = slvHREADY[DRAM];
  assign slvHREADYOUT[DRAM]   = sdram_HREADYOUT;
  assign slvHRESP[DRAM]       = sdram_HRESP;

  // External AHB
  assign ext_HSEL             = slvHSEL[EXTAHB];
  assign ext_HADDR            = slvHADDR[EXTAHB][EXT_HADDR_SIZE-1:0];
  assign ext_HWDATA           = slvHWDATA[EXTAHB];
  assign slvHRDATA[EXTAHB]    = ext_HRDATA;
  assign ext_HWRITE           = slvHWRITE[EXTAHB];
  assign ext_HSIZE            = slvHSIZE[EXTAHB];
  assign ext_HBURST           = slvHBURST[EXTAHB];
  assign ext_HPROT            = slvHPROT[EXTAHB];
  assign ext_HTRANS           = slvHTRANS[EXTAHB];
  assign ext_HMASTLOCK        = slvHMASTLOCK[EXTAHB];
  assign ext_HREADY           = slvHREADY[EXTAHB];
  assign slvHREADYOUT[EXTAHB] = ext_HREADYOUT;
  assign slvHRESP[EXTAHB]     = ext_HRESP;

  // User Slave AHB
  generate
    genvar n;

    for (n = 0; n < MAX_USR_SAHB; n++) begin
      if (n < USR_SAHB_CNT) begin
        assign usr_HSEL[n]              = slvHSEL[USRAHB + n];
        assign usr_HADDR[n]             = slvHADDR[USRAHB + n][USR_SAHB_HADDR_SIZE-1:0];
        assign usr_HWDATA[n]            = slvHWDATA[USRAHB + n];
        assign slvHRDATA[USRAHB + n]    = usr_HRDATA[n];
        assign usr_HWRITE[n]            = slvHWRITE[USRAHB + n];
        assign usr_HSIZE[n]             = slvHSIZE[USRAHB + n];
        assign usr_HBURST[n]            = slvHBURST[USRAHB + n];
        assign usr_HPROT[n]             = slvHPROT[USRAHB + n];
        assign usr_HTRANS[n]            = slvHTRANS[USRAHB + n];
        assign usr_HMASTLOCK[n]         = slvHMASTLOCK[USRAHB + n];
        assign usr_HREADY[n]            = slvHREADY[USRAHB + n];
        assign slvHREADYOUT[USRAHB + n] = usr_HREADYOUT[n];
        assign slvHRESP[USRAHB + n]     = usr_HRESP[n];
      end else begin : tie_off_unused_AHB
        ahb4lite_error #(HDATA_SIZE) sahb_error (
          .HRESETn  (HRESETn),
          .HCLK     (HCLK),
          .HSEL     (slvHSEL[USRAHB + n]),
          .HTRANS   (slvHTRANS[USRAHB + n]),
          .HRDATA   (slvHRDATA[USRAHB + n]),
          .HREADY   (slvHREADY[USRAHB + n]),
          .HREADYOUT(slvHREADYOUT[USRAHB + n]),
          .HRESP    (slvHRESP[USRAHB + n])
        );
      end
    end
  endgenerate

  // AHB-2-APB Bridges
  peripheral_ahb42apb4 #(
    .HADDR_SIZE(HADDR_SIZE),
    .HDATA_SIZE(HDATA_SIZE),
    .PADDR_SIZE(APB32_PADDR_SIZE),
    .PDATA_SIZE(APB32_PDATA_SIZE)
  ) ahb2apb_32b_bridge (
    .HRESETn(HRESETn),
    .HCLK   (HCLK),

    .HSEL     (slvHSEL[AHB2APB_32b]),
    .HADDR    (slvHADDR[AHB2APB_32b]),
    .HWDATA   (slvHWDATA[AHB2APB_32b]),
    .HRDATA   (slvHRDATA[AHB2APB_32b]),
    .HWRITE   (slvHWRITE[AHB2APB_32b]),
    .HSIZE    (slvHSIZE[AHB2APB_32b]),
    .HBURST   (slvHBURST[AHB2APB_32b]),
    .HPROT    (slvHPROT[AHB2APB_32b]),
    .HTRANS   (slvHTRANS[AHB2APB_32b]),
    .HMASTLOCK(slvHMASTLOCK[AHB2APB_32b]),
    .HREADYOUT(slvHREADYOUT[AHB2APB_32b]),
    .HREADY   (slvHREADY[AHB2APB_32b]),
    .HRESP    (slvHRESP[AHB2APB_32b]),

    .PRESETn(PRESETn),
    .PCLK   (PCLK),
    .PSEL   (PSEL_32b),
    .PENABLE(PENABLE_32b),
    .PPROT  (PPROT_32b),
    .PWRITE (PWRITE_32b),
    .PSTRB  (PSTRB_32b),
    .PADDR  (PADDR_32b),
    .PWDATA (PWDATA_32b),
    .PRDATA (PRDATA_32b),
    .PREADY (PREADY_32b),
    .PSLVERR(PSLVERR_32b)
  );

  // Hookup 32b slaves
  pu_riscv_slaves_32b_apb4 #(
    .PADDR_SIZE(APB32_PADDR_SIZE),
    .PDATA_SIZE(APB32_PDATA_SIZE),

    .GPIO_CNT(GPIO_CNT),
    .UART_CNT(UART_CNT),
    .I2C_CNT (I2C_CNT),
    .SPI_CNT (SPI_CNT),
    .USR_CNT (USR_APB32_CNT),

    .USR_INT_CNT(USR_INT_CNT),

    .PLIC_TARGETS      (PLIC_TARGETS),
    .PLIC_PRIORITIES   (PLIC_PRIORITIES),
    .PLIC_PENDING_CNT  (PLIC_PENDING_CNT),
    .PLIC_HAS_THRESHOLD(PLIC_HAS_THRESHOLD)
  ) apb_slaves_32b_inst (
    .PRESETn(PRESETn),
    .PCLK   (PCLK),

    .PSEL   (PSEL_32b),
    .PENABLE(PENABLE_32b),
    .PPROT  (PPROT_32b),
    .PWRITE (PWRITE_32b),
    .PSTRB  (PSTRB_32b),
    .PADDR  (PADDR_32b),
    .PWDATA (PWDATA_32b),
    .PRDATA (PRDATA_32b),
    .PREADY (PREADY_32b),
    .PSLVERR(PSLVERR_32b),

    .usr_PSEL   (usr_PSEL32),
    .usr_PENABLE(usr_PENABLE32),
    .usr_PPROT  (usr_PPROT32),
    .usr_PWRITE (usr_PWRITE32),
    .usr_PSTRB  (usr_PSTRB32),
    .usr_PADDR  (usr_PADDR32),
    .usr_PWDATA (usr_PWDATA32),
    .usr_PRDATA (usr_PRDATA32),
    .usr_PREADY (usr_PREADY32),
    .usr_PSLVERR(usr_PSLVERR32),

    .int_jsp_i (int_jsp),
    .int_uart_i(int_uart),
    .int_gpio_i(int_gpio),
    .int_i2c_i (int_i2c),
    .int_spi_i (int_spi),
    .int_usr_i (int_usr_i),

    .plic_int_o(plic_int)
  );

  peripheral_ahb42apb4 #(
    .HADDR_SIZE(HADDR_SIZE),
    .HDATA_SIZE(HDATA_SIZE),
    .PADDR_SIZE(APB8_PADDR_SIZE),
    .PDATA_SIZE(APB8_PDATA_SIZE)
  ) ahb2apb_8b_bridge (
    .HRESETn(HRESETn),
    .HCLK   (HCLK),

    .HSEL     (slvHSEL[AHB2APB_8b]),
    .HADDR    (slvHADDR[AHB2APB_8b]),
    .HWDATA   (slvHWDATA[AHB2APB_8b]),
    .HRDATA   (slvHRDATA[AHB2APB_8b]),
    .HWRITE   (slvHWRITE[AHB2APB_8b]),
    .HSIZE    (slvHSIZE[AHB2APB_8b]),
    .HBURST   (slvHBURST[AHB2APB_8b]),
    .HPROT    (slvHPROT[AHB2APB_8b]),
    .HTRANS   (slvHTRANS[AHB2APB_8b]),
    .HMASTLOCK(slvHMASTLOCK[AHB2APB_8b]),
    .HREADYOUT(slvHREADYOUT[AHB2APB_8b]),
    .HREADY   (slvHREADY[AHB2APB_8b]),
    .HRESP    (slvHRESP[AHB2APB_8b]),

    .PRESETn(PRESETn),
    .PCLK   (PCLK),
    .PSEL   (PSEL_8b),
    .PENABLE(PENABLE_8b),
    .PPROT  (PPROT_8b),
    .PWRITE (PWRITE_8b),
    .PSTRB  (PSTRB_8b),
    .PADDR  (PADDR_8b),
    .PWDATA (PWDATA_8b),
    .PRDATA (PRDATA_8b),
    .PREADY (PREADY_8b),
    .PSLVERR(PSLVERR_8b)
  );

  // Hookup 8b slaves
  pu_riscv_slaves_8b_apb4 #(
    .PADDR_SIZE(APB8_PADDR_SIZE),
    .PDATA_SIZE(APB8_PDATA_SIZE),

    .GPIO_CNT(GPIO_CNT),
    .UART_CNT(UART_CNT),
    .I2C_CNT (I2C_CNT),
    .SPI_CNT (SPI_CNT),

    .SYS_CLK_FREQ (APB_CLK_FREQ),
    .UART_BAUDRATE(UART_BAUDRATE)
  ) apb_slaves_8b_inst (
    .PRESETn(PRESETn),
    .PCLK   (PCLK),

    .PSEL   (PSEL_8b),
    .PENABLE(PENABLE_8b),
    .PPROT  (PPROT_8b),
    .PWRITE (PWRITE_8b),
    .PSTRB  (PSTRB_8b),
    .PADDR  (PADDR_8b),
    .PWDATA (PWDATA_8b),
    .PRDATA (PRDATA_8b),
    .PREADY (PREADY_8b),
    .PSLVERR(PSLVERR_8b),

    .jsp_PSEL   (jsp_PSEL_8b),
    .jsp_PENABLE(jsp_PENABLE_8b),
    .jsp_PWRITE (jsp_PWRITE_8b),
    .jsp_PADDR  (jsp_PADDR_8b),
    .jsp_PWDATA (jsp_PWDATA_8b),
    .jsp_PRDATA (jsp_PRDATA_8b),
    .jsp_PREADY (jsp_PREADY_8b),
    .jsp_PSLVERR(jsp_PSLVERR_8b),

    .usr_PSEL   (usr_PSEL8),
    .usr_PENABLE(usr_PENABLE8),
    .usr_PPROT  (usr_PPROT8),
    .usr_PWRITE (usr_PWRITE8),
    .usr_PSTRB  (),
    .usr_PADDR  (usr_PADDR8),
    .usr_PWDATA (usr_PWDATA8),
    .usr_PRDATA (usr_PRDATA8),
    .usr_PREADY (usr_PREADY8),
    .usr_PSLVERR(usr_PSLVERR8),

    .gpio_i    (gpio_i),
    .gpio_o    (gpio_o),
    .gpio_oe_o (gpio_oe_o),
    .gpio_int_o(int_gpio),

    .uart_rxd_i(uart_rxd_i),
    .uart_txd_o(uart_txd_o),
    .uart_int_o(int_uart)
  );

endmodule
