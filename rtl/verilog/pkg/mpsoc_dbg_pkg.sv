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
//              Degub Interface                                               //
//              AMBA3 AHB-Lite Bus Interface                                  //
//              WishBone Bus Interface                                        //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/* Copyright (c) 2018-2019 by the author(s)
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

  `define DBG_TOP_DATAREG_LEN 64

  // How many modules can be supported by the module id length
  `define DBG_TOP_MAX_MODULES 4

  // Length of the MODULE ID register
  `define DBG_TOP_MODULE_ID_LENGTH $clog2(`DBG_TOP_MAX_MODULES)

  // Chains
  `define DBG_TOP_BUSIF_DEBUG_MODULE  'h0
  `define DBG_TOP_CPU_DEBUG_MODULE    'h1
  `define DBG_TOP_JSP_DEBUG_MODULE    'h2
  `define DBG_TOP_RESERVED_DBG_MODULE 'h3

  // Size of data-shift-register
  // 01bit cmd
  // 04bit operation
  // 04bit core/thread select
  // 32bit address
  // 16bit count
  // Should we put this in a packed struct?!
  `define DBG_OR1K_DATAREG_LEN 64

  // Size of the register-select register
  `define DBG_OR1K_REGSELECT_LEN 1

  // Register index definitions for module-internal registers
  // Index 0 is the Status register, used for stall and reset
  `define DBG_OR1K_INTREG_STATUS 'h0

  // Valid commands/opcodes for the or1k debug module
  // 0000        NOP
  // 0001 - 0010 Reserved
  // 0011        Write burst, 32-bit access
  // 0100 - 0110 Reserved
  // 0111        Read burst, 32-bit access
  // 1000        Reserved
  // 1001        Internal register select/write
  // 1010 - 1100 Reserved
  // 1101        Internal register select
  // 1110 - 1111 Reserved
  `define DBG_OR1K_CMD_BWRITE32 'h3
  `define DBG_OR1K_CMD_BREAD32  'h7
  `define DBG_OR1K_CMD_IREG_WR  'h9
  `define DBG_OR1K_CMD_IREG_SEL 'hd

  `define DBG_JSP_DATAREG_LEN 64

  //AMBA3 AHB-Lite Interface
  // The AHB3 debug module requires 53 bits
  `define DBG_AHB_DATAREG_LEN 64

  // These relate to the number of internal registers, and how
  // many bits are required in the Reg. Select register
  `define DBG_AHB_REGSELECT_SIZE 1
  `define DBG_AHB_NUM_INTREG     1

  // Register index definitions for module-internal registers
  // The AHB module has just 1, the error register
  `define DBG_AHB_INTREG_ERROR 'b0

  // Valid commands/opcodes for the AHB debug module (same as Wishbone)
  // 0000  NOP
  // 0001  Write burst, 8-bit access
  // 0010  Write burst, 16-bit access
  // 0011  Write burst, 32-bit access
  // 0100  Write burst, 64-bit access
  // 0101  Read burst, 8-bit access
  // 0110  Read burst, 16-bit access
  // 0111  Read burst, 32-bit access
  // 1000  Read burst, 64-bit access
  // 1001  Internal register select/write
  // 1010 - 1100 Reserved
  // 1101  Internal register select
  // 1110 - 1111 Reserved
  `define DBG_AHB_CMD_BWRITE8  'h1
  `define DBG_AHB_CMD_BWRITE16 'h2
  `define DBG_AHB_CMD_BWRITE32 'h3
  `define DBG_AHB_CMD_BWRITE64 'h4
  `define DBG_AHB_CMD_BREAD8   'h5
  `define DBG_AHB_CMD_BREAD16  'h6
  `define DBG_AHB_CMD_BREAD32  'h7
  `define DBG_AHB_CMD_BREAD64  'h8
  `define DBG_AHB_CMD_IREG_WR  'h9
  `define DBG_AHB_CMD_IREG_SEL 'hd

  //AHB definitions
  `define HTRANS_IDLE          2'b00
  `define HTRANS_BUSY          2'b01
  `define HTRANS_NONSEQ        2'b10
  `define HTRANS_SEQ           2'b11

  `define HBURST_SINGLE        3'b000
  `define HBURST_INCR          3'b001
  `define HBURST_WRAP4         3'b010
  `define HBURST_INCR4         3'b011
  `define HBURST_WRAP8         3'b100
  `define HBURST_INCR8         3'b101
  `define HBURST_WRAP16        3'b110
  `define HBURST_INCR16        3'b111

  `define HSIZE8               3'b000
  `define HSIZE16              3'b001
  `define HSIZE32              3'b010
  `define HSIZE64              3'b011
  `define HSIZE128             3'b100
  `define HSIZE256             3'b101
  `define HSIZE512             3'b110
  `define HSIZE1024            3'b111

  `define HSIZE_BYTE           `HSIZE8
  `define HSIZE_HWORD          `HSIZE16
  `define HSIZE_WORD           `HSIZE32
  `define HSIZE_DWORD          `HSIZE64
  `define HSIZE_4WLINE         `HSIZE128
  `define HSIZE_8WLINE         `HSIZE256

  `define HPROT_OPCODE         4'b0000
  `define HPROT_DATA           4'b0001
  `define HPROT_USER           4'b0000
  `define HPROT_PRIVILEGED     4'b0010
  `define HPROT_NON_BUFFERABLE 4'b0000
  `define HPROT_BUFFERABLE     4'b0100
  `define HPROT_NON_CACHEABLE  4'b0000
  `define HPROT_CACHEABLE      4'b1000

  `define HRESP_OKAY           1'b0
  `define HRESP_ERR            1'b1

  //Wishbone Interface
  // The Wishbone debug module requires 53 bits
  `define DBG_WB_DATAREG_LEN 64

  // These relate to the number of internal registers, and how
  // many bits are required in the Reg. Select register
  `define DBG_WB_REGSELECT_SIZE 1
  `define DBG_WB_NUM_INTREG     1

  // Register index definitions for module-internal registers
  // The WB module has just 1, the error register
  `define DBG_WB_INTREG_ERROR 'b0

  // Valid commands/opcodes for the wishbone debug module
  // 0000  NOP
  // 0001  Write burst, 8-bit access
  // 0010  Write burst, 16-bit access
  // 0011  Write burst, 32-bit access
  // 0100  Write burst, 64-bit access
  // 0101  Read burst, 8-bit access
  // 0110  Read burst, 16-bit access
  // 0111  Read burst, 32-bit access
  // 1000  Read burst, 64-bit access
  // 1001  Internal register select/write
  // 1010 - 1100 Reserved
  // 1101  Internal register select
  // 1110 - 1111 Reserved
  `define DBG_WB_CMD_BWRITE8  'h1
  `define DBG_WB_CMD_BWRITE16 'h2
  `define DBG_WB_CMD_BWRITE32 'h3
  `define DBG_WB_CMD_BWRITE64 'h4
  `define DBG_WB_CMD_BREAD8   'h5
  `define DBG_WB_CMD_BREAD16  'h6
  `define DBG_WB_CMD_BREAD32  'h7
  `define DBG_WB_CMD_BREAD64  'h8
  `define DBG_WB_CMD_IREG_WR  'h9
  `define DBG_WB_CMD_IREG_SEL 'hd
