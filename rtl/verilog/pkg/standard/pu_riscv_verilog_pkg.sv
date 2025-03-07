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
//              RISC-V Package                                                //
//              AMBA3 AHB-Lite Bus Interface                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2017-2018 by the author(s)
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

package pu_riscv_verilog_pkg;

  //////////////////////////////////////////////////////////////////////////////
  // Processing Unit
  //////////////////////////////////////////////////////////////////////////////

  // Core Parameters
  localparam XLEN = 64;
  localparam PLEN = 64;
  localparam FLEN = 64;
  localparam PC_INIT = 'h8000_0000;  // Start here after reset
  localparam BASE = PC_INIT;  // offset where to load program in memory
  localparam INIT_FILE = "test.hex";
  localparam MEM_LATENCY = 1;
  localparam HAS_USER = 1;
  localparam HAS_SUPER = 1;
  localparam HAS_HYPER = 1;
  localparam HAS_BPU = 1;
  localparam HAS_FPU = 1;
  localparam HAS_MMU = 1;
  localparam HAS_RVM = 1;
  localparam HAS_RVA = 1;
  localparam HAS_RVC = 1;
  localparam HAS_RVN = 1;
  localparam HAS_RVB = 1;
  localparam HAS_RVT = 1;
  localparam HAS_RVP = 1;
  localparam HAS_EXT = 1;

  localparam IS_RV32E = 1;

  localparam MULT_LATENCY = 1;

  localparam HTIF = 0;  // Host-interface
  localparam TOHOST = 32'h80001000;
  localparam UART_TX = 32'h80001080;

  localparam BREAKPOINTS = 8;  // Number of hardware breakpoints

  localparam PMA_CNT = 4;
  localparam PMP_CNT = 16;  // Number of Physical Memory Protection entries

  localparam BP_GLOBAL_BITS = 2;
  localparam BP_LOCAL_BITS = 10;
  localparam BP_LOCAL_BITS_LSB = 2;

  localparam ICACHE_SIZE = 64;  // in KBytes
  localparam ICACHE_BLOCK_SIZE = 64;  // in Bytes
  localparam ICACHE_WAYS = 2;  // 'n'-way set associative
  localparam ICACHE_REPLACE_ALG = 0;
  localparam ITCM_SIZE = 0;

  localparam DCACHE_SIZE = 64;  // in KBytes
  localparam DCACHE_BLOCK_SIZE = 64;  // in Bytes
  localparam DCACHE_WAYS = 2;  // 'n'-way set associative
  localparam DCACHE_REPLACE_ALG = 0;
  localparam DTCM_SIZE = 0;
  localparam WRITEBUFFER_SIZE = 8;

  localparam TECHNOLOGY = "GENERIC";
  localparam AVOID_X = 0;

  localparam MNMIVEC_DEFAULT = PC_INIT - 'h004;
  localparam MTVEC_DEFAULT = PC_INIT - 'h040;
  localparam HTVEC_DEFAULT = PC_INIT - 'h080;
  localparam STVEC_DEFAULT = PC_INIT - 'h0C0;
  localparam UTVEC_DEFAULT = PC_INIT - 'h100;

  localparam JEDEC_BANK = 10;
  localparam JEDEC_MANUFACTURER_ID = 'h6e;

  localparam HARTID = 0;

  localparam PARCEL_SIZE = 32;

  localparam SYNC_DEPTH = 3;

  localparam BUFFER_DEPTH = 4;

  // RF Access
  localparam RDPORTS = 1;
  localparam WRPORTS = 1;
  localparam AR_BITS = 5;

  localparam PMPCFG_MASK = 8'h9F;

  // Definitions Package
  localparam ARCHID = 12;
  localparam REVPRV_MAJOR = 1;
  localparam REVPRV_MINOR = 10;
  localparam REVUSR_MAJOR = 2;
  localparam REVUSR_MINOR = 2;

  //////////////////////////////////////////////////////////////////////////////
  // Execution Unit
  //////////////////////////////////////////////////////////////////////////////

  // RISCV Opcodes Package
  localparam ILEN = 64;
  localparam INSTR_NOP = 64'h13;

  // Opcodes
  localparam OPC_LOAD = 5'b00_000;
  localparam OPC_LOAD_FP = 5'b00_001;
  localparam OPC_MISC_MEM = 5'b00_011;
  localparam OPC_OP_IMM = 5'b00_100;
  localparam OPC_AUIPC = 5'b00_101;
  localparam OPC_OP_IMM32 = 5'b00_110;
  localparam OPC_STORE = 5'b01_000;
  localparam OPC_STORE_FP = 5'b01_001;
  localparam OPC_AMO = 5'b01_011;
  localparam OPC_OP = 5'b01_100;
  localparam OPC_LUI = 5'b01_101;
  localparam OPC_OP32 = 5'b01_110;
  localparam OPC_MADD = 5'b10_000;
  localparam OPC_MSUB = 5'b10_001;
  localparam OPC_NMSUB = 5'b10_010;
  localparam OPC_NMADD = 5'b10_011;
  localparam OPC_OP_FP = 5'b10_100;
  localparam OPC_BRANCH = 5'b11_000;
  localparam OPC_JALR = 5'b11_001;
  localparam OPC_JAL = 5'b11_011;
  localparam OPC_SYSTEM = 5'b11_100;

  // RV32/RV64 Base instructions

  // f7 f3 opcode
  localparam LUI = 15'b???????_???_01101;
  localparam AUIPC = 15'b???????_???_00101;
  localparam JAL = 15'b???????_???_11011;
  localparam JALR = 15'b???????_000_11001;
  localparam BEQ = 15'b???????_000_11000;
  localparam BNE = 15'b???????_001_11000;
  localparam BLT = 15'b???????_100_11000;
  localparam BGE = 15'b???????_101_11000;
  localparam BLTU = 15'b???????_110_11000;
  localparam BGEU = 15'b???????_111_11000;
  localparam LB = 15'b???????_000_00000;
  localparam LH = 15'b???????_001_00000;
  localparam LW = 15'b???????_010_00000;
  localparam LBU = 15'b???????_100_00000;
  localparam LHU = 15'b???????_101_00000;
  localparam LWU = 15'b???????_110_00000;
  localparam LD = 15'b???????_011_00000;
  localparam SB = 15'b???????_000_01000;
  localparam SH = 15'b???????_001_01000;
  localparam SW = 15'b???????_010_01000;
  localparam SD = 15'b???????_011_01000;
  localparam ADDI = 15'b???????_000_00100;
  localparam ADDIW = 15'b???????_000_00110;
  localparam ADD = 15'b0000000_000_01100;
  localparam ADDW = 15'b0000000_000_01110;
  localparam SUB = 15'b0100000_000_01100;
  localparam SUBW = 15'b0100000_000_01110;
  localparam XORI = 15'b???????_100_00100;
  localparam XORX = 15'b0000000_100_01100;
  localparam ORI = 15'b???????_110_00100;
  localparam ORX = 15'b0000000_110_01100;
  localparam ANDI = 15'b???????_111_00100;
  localparam ANDX = 15'b0000000_111_01100;
  localparam SLLI = 15'b000000?_001_00100;
  localparam SLLIW = 15'b0000000_001_00110;
  localparam SLLX = 15'b0000000_001_01100;
  localparam SLLW = 15'b0000000_001_01110;
  localparam SLTI = 15'b???????_010_00100;
  localparam SLT = 15'b0000000_010_01100;
  localparam SLTU = 15'b0000000_011_01100;
  localparam SLTIU = 15'b???????_011_00100;
  localparam SRLI = 15'b000000?_101_00100;
  localparam SRLIW = 15'b0000000_101_00110;
  localparam SRLX = 15'b0000000_101_01100;
  localparam SRLW = 15'b0000000_101_01110;
  localparam SRAI = 15'b010000?_101_00100;
  localparam SRAIW = 15'b0100000_101_00110;
  localparam SRAX = 15'b0100000_101_01100;
  localparam SRAW = 15'b0100000_101_01110;

  // pseudo instructions
  localparam SYSTEM = 15'b???????_000_11100;  // excludes RDxxx instructions
  localparam MISCMEM = 15'b???????_???_00011;

  // SYSTEM/MISC_MEM opcodes
  localparam FENCE = 32'b0000????????_00000_000_00000_0001111;
  localparam SFENCE_VM = 32'b000100000100_?????_000_00000_1110011;
  localparam FENCE_I = 32'b000000000000_00000_001_00000_0001111;
  localparam ECALL = 32'b000000000000_00000_000_00000_1110011;
  localparam EBREAK = 32'b000000000001_00000_000_00000_1110011;
  localparam MRET = 32'b001100000010_00000_000_00000_1110011;
  localparam HRET = 32'b001000000010_00000_000_00000_1110011;
  localparam SRET = 32'b000100000010_00000_000_00000_1110011;
  localparam URET = 32'b000000000010_00000_000_00000_1110011;
  localparam MRTS = 32'b001100000101_00000_000_00000_1110011;
  localparam MRTH = 32'b001100000110_00000_000_00000_1110011;
  localparam HRTS = 32'b001000000101_00000_000_00000_1110011;
  localparam WFI = 32'b000100000101_00000_000_00000_1110011;

  // f7 f3 opcode
  localparam CSRRW = 15'b???????_001_11100;
  localparam CSRRS = 15'b???????_010_11100;
  localparam CSRRC = 15'b???????_011_11100;
  localparam CSRRWI = 15'b???????_101_11100;
  localparam CSRRSI = 15'b???????_110_11100;
  localparam CSRRCI = 15'b???????_111_11100;

  // RV32/RV64 A-Extensions instructions

  // f7 f3 opcode
  localparam LRW = 15'b00010??_010_01011;
  localparam SCW = 15'b00011??_010_01011;
  localparam AMOSWAPW = 15'b00001??_010_01011;
  localparam AMOADDW = 15'b00000??_010_01011;
  localparam AMOXORW = 15'b00100??_010_01011;
  localparam AMOANDW = 15'b01100??_010_01011;
  localparam AMOORW = 15'b01000??_010_01011;
  localparam AMOMINW = 15'b10000??_010_01011;
  localparam AMOMAXW = 15'b10100??_010_01011;
  localparam AMOMINUW = 15'b11000??_010_01011;
  localparam AMOMAXUW = 15'b11100??_010_01011;

  localparam LRD = 15'b00010??_011_01011;
  localparam SCD = 15'b00011??_011_01011;
  localparam AMOSWAPD = 15'b00001??_011_01011;
  localparam AMOADDD = 15'b00000??_011_01011;
  localparam AMOXORD = 15'b00100??_011_01011;
  localparam AMOANDD = 15'b01100??_011_01011;
  localparam AMOORD = 15'b01000??_011_01011;
  localparam AMOMIND = 15'b10000??_011_01011;
  localparam AMOMAXD = 15'b10100??_011_01011;
  localparam AMOMINUD = 15'b11000??_011_01011;
  localparam AMOMAXUD = 15'b11100??_011_01011;

  // RV32/RV64 M-Extensions instructions

  // f7 f3 opcode
  localparam MUL = 15'b0000001_000_01100;
  localparam MULH = 15'b0000001_001_01100;
  localparam MULW = 15'b0000001_000_01110;
  localparam MULHSU = 15'b0000001_010_01100;
  localparam MULHU = 15'b0000001_011_01100;
  localparam DIV = 15'b0000001_100_01100;
  localparam DIVW = 15'b0000001_100_01110;
  localparam DIVU = 15'b0000001_101_01100;
  localparam DIVUW = 15'b0000001_101_01110;
  localparam REM = 15'b0000001_110_01100;
  localparam REMW = 15'b0000001_110_01110;
  localparam REMU = 15'b0000001_111_01100;
  localparam REMUW = 15'b0000001_111_01110;

  //////////////////////////////////////////////////////////////////////////////
  // Memory Unit
  //////////////////////////////////////////////////////////////////////////////

  localparam MEM_TYPE_EMPTY = 2'h0;
  localparam MEM_TYPE_MAIN = 2'h1;
  localparam MEM_TYPE_IO = 2'h2;
  localparam MEM_TYPE_TCM = 2'h3;

  localparam AMO_TYPE_NONE = 2'h0;
  localparam AMO_TYPE_SWAP = 2'h1;
  localparam AMO_TYPE_LOGICAL = 2'h2;
  localparam AMO_TYPE_ARITHMETIC = 2'h3;

  //////////////////////////////////////////////////////////////////////////////
  // State Unit
  //////////////////////////////////////////////////////////////////////////////

  // Per Supervisor Spec draft 1.10

  // PMP-CFG Register
  localparam OFF = 2'd0;
  localparam TOR = 2'd1;
  localparam NA4 = 2'd2;
  localparam NAPOT = 2'd3;

  // CSR mapping
  // User
  // User Trap Setup
  localparam USTATUS = 'h000;
  localparam UIE = 'h004;
  localparam UTVEC = 'h005;

  // User Trap Handling
  localparam USCRATCH = 'h040;
  localparam UEPC = 'h041;
  localparam UCAUSE = 'h042;
  localparam UBADADDR = 'h043;
  localparam UTVAL = 'h043;
  localparam UIP = 'h044;

  // User Floating-Point CSRs
  localparam FFLAGS = 'h001;
  localparam FRM = 'h002;
  localparam FCSR = 'h003;

  // User Counters/Timers
  localparam CYCLE = 'hC00;
  localparam TIMEX = 'hC01;
  localparam INSTRET = 'hC02;
  localparam HPMCOUNTER3 = 'hC03;  // until HPMCOUNTER31='hC1F
  localparam CYCLEH = 'hC80;
  localparam TIMEH = 'hC81;
  localparam INSTRETH = 'hC82;
  localparam HPMCOUNTER3H = 'hC83;  // until HPMCONTER31='hC9F

  // Supervisor
  // Supervisor Trap Setup
  localparam SSTATUS = 'h100;
  localparam SEDELEG = 'h102;
  localparam SIDELEG = 'h103;
  localparam SIE = 'h104;
  localparam STVEC = 'h105;
  localparam SCOUNTEREN = 'h106;

  // Supervisor Trap Handling
  localparam SSCRATCH = 'h140;
  localparam SEPC = 'h141;
  localparam SCAUSE = 'h142;
  localparam STVAL = 'h143;
  localparam SIP = 'h144;

  // Supervisor Protection and Translation
  localparam SATP = 'h180;

  // Hypervisor
  // Hypervisor trap setup
  localparam HSTATUS = 'h200;
  localparam HEDELEG = 'h202;
  localparam HIDELEG = 'h203;
  localparam HIE = 'h204;
  localparam HTVEC = 'h205;

  // Hypervisor Trap Handling
  localparam HSCRATCH = 'h240;
  localparam HEPC = 'h241;
  localparam HCAUSE = 'h242;
  localparam HTVAL = 'h243;
  localparam HIP = 'h244;

  // Machine
  // Machine Information
  localparam MVENDORID = 'hF11;
  localparam MARCHID = 'hF12;
  localparam MIMPID = 'hF13;
  localparam MHARTID = 'hF14;

  // Machine Trap Setup
  localparam MSTATUS = 'h300;
  localparam MISA = 'h301;
  localparam MEDELEG = 'h302;
  localparam MIDELEG = 'h303;
  localparam MIE = 'h304;
  localparam MNMIVEC = 'h7C0;  // NMI Vector
  localparam MTVEC = 'h305;
  localparam MCOUNTEREN = 'h306;

  // Machine Trap Handling
  localparam MSCRATCH = 'h340;
  localparam MEPC = 'h341;
  localparam MCAUSE = 'h342;
  localparam MTVAL = 'h343;
  localparam MIP = 'h344;

  // Machine Protection and Translation
  localparam PMPCFG0 = 'h3A0;
  localparam PMPCFG1 = 'h3A1;  // RV32 only
  localparam PMPCFG2 = 'h3A2;
  localparam PMPCFG3 = 'h3A3;  // RV32 only
  localparam PMPADDR0 = 'h3B0;
  localparam PMPADDR1 = 'h3B1;
  localparam PMPADDR2 = 'h3B2;
  localparam PMPADDR3 = 'h3B3;
  localparam PMPADDR4 = 'h3B4;
  localparam PMPADDR5 = 'h3B5;
  localparam PMPADDR6 = 'h3B6;
  localparam PMPADDR7 = 'h3B7;
  localparam PMPADDR8 = 'h3B8;
  localparam PMPADDR9 = 'h3B9;
  localparam PMPADDR10 = 'h3BA;
  localparam PMPADDR11 = 'h3BB;
  localparam PMPADDR12 = 'h3BC;
  localparam PMPADDR13 = 'h3BD;
  localparam PMPADDR14 = 'h3BE;
  localparam PMPADDR15 = 'h3BF;

  // Machine Counters/Timers
  localparam MCYCLE = 'hB00;
  localparam MINSTRET = 'hB02;
  localparam MHPMCOUNTER3 = 'hB03;  // until MHPMCOUNTER31='hB1F
  localparam MCYCLEH = 'hB80;
  localparam MINSTRETH = 'hB82;
  localparam MHPMCOUNTER3H = 'hB83;  // until MHPMCOUNTER31H='hB9F
  // Machine Counter Setup
  localparam MHPEVENT3 = 'h323;  // until MHPEVENT31 'h33f

  // Debug
  localparam TSELECT = 'h7A0;
  localparam TDATA1 = 'h7A1;
  localparam TDATA2 = 'h7A2;
  localparam TDATA3 = 'h7A3;
  localparam DCSR = 'h7B0;
  localparam DPC = 'h7B1;
  localparam DSCRATCH = 'h7B2;

  // MXL mapping
  localparam RV32I = 2'b01;
  localparam RV32E = 2'b01;
  localparam RV64I = 2'b10;
  localparam RV128I = 2'b11;

  // Privilege Levels
  localparam PRV_M = 2'b11;
  localparam PRV_H = 2'b10;
  localparam PRV_S = 2'b01;
  localparam PRV_U = 2'b00;

  // Virtualisation
  localparam VM_MBARE = 4'd0;
  localparam VM_SV32 = 4'd1;
  localparam VM_SV39 = 4'd8;
  localparam VM_SV48 = 4'd9;
  localparam VM_SV57 = 4'd10;
  localparam VM_SV64 = 4'd11;

  // MIE MIP
  localparam MEI = 11;
  localparam HEI = 10;
  localparam SEI = 9;
  localparam UEI = 8;
  localparam MTI = 7;
  localparam HTI = 6;
  localparam STI = 5;
  localparam UTI = 4;
  localparam MSI = 3;
  localparam HSI = 2;
  localparam SSI = 1;
  localparam USI = 0;

  // Performance Counters
  localparam CY = 0;
  localparam TM = 1;
  localparam IR = 2;

  // Exception Causes
  localparam EXCEPTION_SIZE = 16;

  localparam CAUSE_MISALIGNED_INSTRUCTION = 0;
  localparam CAUSE_INSTRUCTION_ACCESS_FAULT = 1;
  localparam CAUSE_ILLEGAL_INSTRUCTION = 2;
  localparam CAUSE_BREAKPOINT = 3;
  localparam CAUSE_MISALIGNED_LOAD = 4;
  localparam CAUSE_LOAD_ACCESS_FAULT = 5;
  localparam CAUSE_MISALIGNED_STORE = 6;
  localparam CAUSE_STORE_ACCESS_FAULT = 7;
  localparam CAUSE_UMODE_ECALL = 8;
  localparam CAUSE_SMODE_ECALL = 9;
  localparam CAUSE_HMODE_ECALL = 10;
  localparam CAUSE_MMODE_ECALL = 11;
  localparam CAUSE_INSTRUCTION_PAGE_FAULT = 12;
  localparam CAUSE_LOAD_PAGE_FAULT = 13;
  localparam CAUSE_STORE_PAGE_FAULT = 15;

  localparam CAUSE_USINT = 0;
  localparam CAUSE_SSINT = 1;
  localparam CAUSE_HSINT = 2;
  localparam CAUSE_MSINT = 3;
  localparam CAUSE_UTINT = 4;
  localparam CAUSE_STINT = 5;
  localparam CAUSE_HTINT = 6;
  localparam CAUSE_MTINT = 7;
  localparam CAUSE_UEINT = 8;
  localparam CAUSE_SEINT = 9;
  localparam CAUSE_HEINT = 10;
  localparam CAUSE_MEINT = 11;

  //////////////////////////////////////////////////////////////////////////////
  // Debug Unit
  //////////////////////////////////////////////////////////////////////////////

  // One Debug Unit per Hardware Thread (hart)
  localparam DU_ADDR_SIZE = 12;  // 12bit internal address bus

  localparam MAX_BREAKPOINTS = 8;

 // Debug Unit Memory Map
 //
 // addr_bits  Description
 // ------------------------------
 // 15-12      Debug bank
 // 11- 0      Address inside bank

 // Bank0      Control & Status
 // Bank1      GPRs
 // Bank2      CSRs
 // Bank3-15   reserved

  localparam DBG_INTERNAL = 4'h0;
  localparam DBG_GPRS = 4'h1;
  localparam DBG_CSRS = 4'h2;

 // Control registers
 // 0 00 00 ctrl
 // 0 00 01
 // 0 00 10 ie
 // 0 00 11 cause
 //  reserved
 //
 // 1 0000 BP0 Ctrl
 // 1 0001 BP0 Data
 // 1 0010 BP1 Ctrl
 // 1 0011 BP1 Data
 // ...
 // 1 1110 BP7 Ctrl
 // 1 1111 BP7 Data

  localparam DBG_CTRL = 'h00;  // debug control
  localparam DBG_HIT = 'h01;  // debug HIT register
  localparam DBG_IE = 'h02;  // debug interrupt enable (which exception halts the CPU?)
  localparam DBG_CAUSE = 'h03;  // debug cause (which exception halted the CPU?)
  localparam DBG_BPCTRL0 = 'h10;  // hardware breakpoint0 control
  localparam DBG_BPDATA0 = 'h11;  // hardware breakpoint0 data
  localparam DBG_BPCTRL1 = 'h12;  // hardware breakpoint1 control
  localparam DBG_BPDATA1 = 'h13;  // hardware breakpoint1 data
  localparam DBG_BPCTRL2 = 'h14;  // hardware breakpoint2 control
  localparam DBG_BPDATA2 = 'h15;  // hardware breakpoint2 data
  localparam DBG_BPCTRL3 = 'h16;  // hardware breakpoint3 control
  localparam DBG_BPDATA3 = 'h17;  // hardware breakpoint3 data
  localparam DBG_BPCTRL4 = 'h18;  // hardware breakpoint4 control
  localparam DBG_BPDATA4 = 'h19;  // hardware breakpoint4 data
  localparam DBG_BPCTRL5 = 'h1a;  // hardware breakpoint5 control
  localparam DBG_BPDATA5 = 'h1b;  // hardware breakpoint5 data
  localparam DBG_BPCTRL6 = 'h1c;  // hardware breakpoint6 control
  localparam DBG_BPDATA6 = 'h1d;  // hardware breakpoint6 data
  localparam DBG_BPCTRL7 = 'h1e;  // hardware breakpoint7 control
  localparam DBG_BPDATA7 = 'h1f;  // hardware breakpoint7 data

  // Debug Codes
  localparam DEBUG_SINGLE_STEP_TRACE = 0;
  localparam DEBUG_BRANCH_TRACE = 1;

  localparam BP_CTRL_IMP = 0;
  localparam BP_CTRL_ENA = 1;
  localparam BP_CTRL_CC_FETCH = 3'h0;
  localparam BP_CTRL_CC_LD_ADR = 3'h1;
  localparam BP_CTRL_CC_ST_ADR = 3'h2;
  localparam BP_CTRL_CC_LDST_ADR = 3'h3;

 // addr         Key  Description
 // --------------------------------------------
 // 0x000-0x01f  GPR  General Purpose Registers
 // 0x100-0x11f  FPR  Floating Point Registers
 // 0x200        PC   Program Counter
 // 0x201        PPC  Previous Program Counter

  localparam DBG_GPR = 12'b0000_0000_0000;
  localparam DBG_FPR = 12'b0001_0000_0000;
  localparam DBG_NPC = 12'h200;
  localparam DBG_PPC = 12'h201;

 // Bank2 - CSRs
 //
 // Direct mapping to the 12bit CSR address space

endpackage
