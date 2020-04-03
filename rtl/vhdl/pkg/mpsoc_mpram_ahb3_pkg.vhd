-- Converted from pkg/mpsoc_mpram_ahb3_pkg.sv
-- by verilog2vhdl - QueenField

--//////////////////////////////////////////////////////////////////////////////
--                                            __ _      _     _               //
--                                           / _(_)    | |   | |              //
--                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              //
--               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              //
--              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              //
--               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              //
--                  | |                                                       //
--                  |_|                                                       //
--                                                                            //
--                                                                            //
--              MPSoC-RISCV CPU                                               //
--              RISC-V Package                                                //
--              AMBA3 AHB-Lite Bus Interface                                  //
--                                                                            //
--//////////////////////////////////////////////////////////////////////////////

-- Copyright (c) 2017-2018 by the author(s)
-- *
-- * Permission is hereby granted, free of charge, to any person obtaining a copy
-- * of this software and associated documentation files (the "Software"), to deal
-- * in the Software without restriction, including without limitation the rights
-- * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- * copies of the Software, and to permit persons to whom the Software is
-- * furnished to do so, subject to the following conditions:
-- *
-- * The above copyright notice and this permission notice shall be included in
-- * all copies or substantial portions of the Software.
-- *
-- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- * THE SOFTWARE.
-- *
-- * =============================================================================
-- * Author(s):
-- *   Francisco Javier Reina Campo <frareicam@gmail.com>
-- */

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package mpsoc_mpram_ahb3_pkg is

  --core parameters
  constant XLEN                   : integer := 64;
  constant PLEN                   : integer := 64;
  constant FLEN                   : integer := 64;

  constant PC_INIT                : std_logic_vector(XLEN-1 downto 0) := X"0000000080000000";  --Start here after reset
  constant BASE                   : std_logic_vector(XLEN-1 downto 0) := PC_INIT;  --offset where to load program in memory

  constant INIT_FILE              : string    := "test.hex";

  constant MEM_LATENCY            : std_logic := '1';
  constant HAS_USER               : std_logic := '1';
  constant HAS_SUPER              : std_logic := '1';
  constant HAS_HYPER              : std_logic := '1';
  constant HAS_BPU                : std_logic := '1';
  constant HAS_FPU                : std_logic := '1';
  constant HAS_MMU                : std_logic := '1';
  constant HAS_RVM                : std_logic := '1';
  constant HAS_RVA                : std_logic := '1';
  constant HAS_RVC                : std_logic := '1';
  constant HAS_RVN                : std_logic := '1';
  constant HAS_RVB                : std_logic := '1';
  constant HAS_RVT                : std_logic := '1';
  constant HAS_RVP                : std_logic := '1';
  constant HAS_EXT                : std_logic := '1';

  constant IS_RV32E               : std_logic := '1';

  constant MULT_LATENCY           : integer := 1;

  constant HTIF                   : std_logic := '0';  --Host-interface

  constant TOHOST                 : std_logic_vector(XLEN-1 downto 0) := X"0000000080001000";
  constant UART_TX                : std_logic_vector(XLEN-1 downto 0) := X"0000000080001080";

  constant BREAKPOINTS            : integer := 8;  --Number of hardware breakpoints

  constant PMA_CNT                : integer := 4;
  constant PMP_CNT                : integer := 16;  --Number of Physical Memory Protection entries

  constant BP_GLOBAL_BITS         : integer := 2;
  constant BP_LOCAL_BITS          : integer := 10;
  constant BP_LOCAL_BITS_LSB      : integer := 2; 

  constant ICACHE_SIZE            : integer := 64;  --in KBytes
  constant ICACHE_BLOCK_SIZE      : integer := 64;  --in Bytes
  constant ICACHE_WAYS            : integer := 2;  --'n'-way set associative

  constant ICACHE_REPLACE_ALG     : std_logic := '0';
  constant ITCM_SIZE              : integer := 0;

  constant DCACHE_SIZE            : integer := 64;  --in KBytes
  constant DCACHE_BLOCK_SIZE      : integer := 64;  --in Bytes
  constant DCACHE_WAYS            : integer := 2;  --'n'-way set associative
  constant WRITEBUFFER_SIZE       : integer := 8;

  constant DCACHE_REPLACE_ALG     : std_logic := '0';
  constant DTCM_SIZE              : integer := 0;

  constant TECHNOLOGY             : string    := "GENERIC";

  constant AVOID_X                : std_logic := '0';

  constant MNMIVEC_DEFAULT        : std_logic_vector(XLEN-1 downto 0) := X"0000000000000004";
  constant MTVEC_DEFAULT          : std_logic_vector(XLEN-1 downto 0) := X"0000000000000040";
  constant HTVEC_DEFAULT          : std_logic_vector(XLEN-1 downto 0) := X"0000000000000080";
  constant STVEC_DEFAULT          : std_logic_vector(XLEN-1 downto 0) := X"00000000000000C0";
  constant UTVEC_DEFAULT          : std_logic_vector(XLEN-1 downto 0) := X"0000000000000100";

  constant JEDEC_BANK             : integer := 10;

  constant JEDEC_MANUFACTURER_ID  : std_logic_vector(7 downto 0) := X"6E";

  constant HARTID                 : integer := 0;

  constant PARCEL_SIZE            : integer := 64;

  constant HADDR_SIZE             : integer := XLEN;
  constant HDATA_SIZE             : integer := PLEN;
  constant PADDR_SIZE             : integer := PLEN;
  constant PDATA_SIZE             : integer := XLEN;

  constant SYNC_DEPTH             : integer := 3;

  constant BUFFER_DEPTH           : integer := 4;

  constant DW                     : integer := 32;
  constant DEPTH                  : integer := 256;
  constant AW                     : integer := integer(log2(real(DEPTH)));

  --RF access
  constant RDPORTS                : integer := 2;
  constant WRPORTS                : integer := 1;
  constant AR_BITS                : integer := 5;

  --mpsoc parameters
  constant CORES_PER_SIMD         : integer := 3;
  constant CORES_PER_MISD         : integer := 2;

  constant CORES_PER_TILE         : integer := CORES_PER_SIMD + CORES_PER_MISD;

  --soc parameters
  constant X                      : integer := 2;
  constant Y                      : integer := 1;
  constant Z                      : integer := 2;

  constant NODES                  : integer := X*Y*Z;
  constant CORES                  : integer := NODES*CORES_PER_TILE;

  --noc parameters
  constant CHANNELS               : integer := 2;
  constant PCHANNELS              : integer := 2;
  constant VCHANNELS              : integer := 2;

  constant INPUTS                 : integer := 7;
  constant OUTPUTS                : integer := 7;

  constant ENABLE_VCHANNELS       : integer := 1;

  constant ROUTER_BUFFER_SIZE     : integer := 2;
  constant REG_ADDR_WIDTH         : integer := 2;
  constant VALWIDTH               : integer := 2;
  constant MAX_PKT_LEN            : integer := 2;

  constant TILE_ID : integer := 0;

  constant GENERATE_INTERRUPT     : std_logic := '1';

  constant TABLE_ENTRIES          : integer := 4;
  constant NOC_PACKET_SIZE        : integer := 16;

  constant TABLE_ENTRIES_PTRWIDTH : integer := integer(log2(real(TABLE_ENTRIES)));

  constant MUX_PORTS : integer := 2;

  --debug parameters
  constant STDOUT_FILENAME        : integer := 4;
  constant TRACEFILE_FILENAME     : integer := 4;
  constant ENABLE_TRACE           : integer := 4;
  constant GLIP_PORT              : integer := 23000;
  constant TERM_CROSS_NUM         : integer := NODES;

  constant GLIP_UART_LIKE         : std_logic := '0';

  --RV12 Definitions Package
  constant ARCHID       : integer := 12;
  constant REVPRV_MAJOR : integer := 1;
  constant REVPRV_MINOR : integer := 10;
  constant REVUSR_MAJOR : integer := 2;
  constant REVUSR_MINOR : integer := 2;

  --BIU Constants Package
  constant BYTE       : std_logic_vector(2 downto 0) := "000";
  constant HWORD      : std_logic_vector(2 downto 0) := "001";
  constant WORD       : std_logic_vector(2 downto 0) := "010";
  constant DWORD      : std_logic_vector(2 downto 0) := "011";
  constant QWORD      : std_logic_vector(2 downto 0) := "100";
  constant UNDEF_SIZE : std_logic_vector(2 downto 0) := "XXX";

  constant SINGLE      : std_logic_vector(2 downto 0) := "000";
  constant INCR        : std_logic_vector(2 downto 0) := "001";
  constant WRAP4       : std_logic_vector(2 downto 0) := "010";
  constant INCR4       : std_logic_vector(2 downto 0) := "011";
  constant WRAP8       : std_logic_vector(2 downto 0) := "100";
  constant INCR8       : std_logic_vector(2 downto 0) := "101";
  constant WRAP16      : std_logic_vector(2 downto 0) := "110";
  constant INCR16      : std_logic_vector(2 downto 0) := "111";
  constant UNDEF_BURST : std_logic_vector(2 downto 0) := "XXX";

  --Enumeration Codes
  constant PROT_INSTRUCTION  : std_logic_vector(2 downto 0) := "000";
  constant PROT_DATA         : std_logic_vector(2 downto 0) := "001";
  constant PROT_USER         : std_logic_vector(2 downto 0) := "000";
  constant PROT_PRIVILEGED   : std_logic_vector(2 downto 0) := "010";
  constant PROT_NONCACHEABLE : std_logic_vector(2 downto 0) := "000";
  constant PROT_CACHEABLE    : std_logic_vector(2 downto 0) := "100";

  --Complex Enumerations
  constant NONCACHEABLE_USER_INSTRUCTION       : std_logic_vector(2 downto 0) := "000";
  constant NONCACHEABLE_USER_DATA              : std_logic_vector(2 downto 0) := "001";
  constant NONCACHEABLE_PRIVILEGED_INSTRUCTION : std_logic_vector(2 downto 0) := "010";
  constant NONCACHEABLE_PRIVILEGED_DATA        : std_logic_vector(2 downto 0) := "011";
  constant CACHEABLE_USER_INSTRUCTION          : std_logic_vector(2 downto 0) := "100";
  constant CACHEABLE_USER_DATA                 : std_logic_vector(2 downto 0) := "101";
  constant CACHEABLE_PRIVILEGED_INSTRUCTION    : std_logic_vector(2 downto 0) := "110";
  constant CACHEABLE_PRIVILEGED_DATA           : std_logic_vector(2 downto 0) := "111";

  --One Debug Unit per Hardware Thread (hart)
  constant DU_ADDR_SIZE : integer := 12;  -- 12bit internal address bus

  constant MAX_BREAKPOINTS : integer := 8;

  --  * Debug Unit Memory Map
  --  *
  --  * addr_bits  Description
  --  * ------------------------------
  --  * 15-12      Debug bank
  --  * 11- 0      Address inside bank

  --  * Bank0      Control & Status
  --  * Bank1      GPRs
  --  * Bank2      CSRs
  --  * Bank3-15   reserved

  constant DBG_INTERNAL : std_logic_vector(15 downto 12) := X"0";
  constant DBG_GPRS     : std_logic_vector(15 downto 12) := X"1";
  constant DBG_CSRS     : std_logic_vector(15 downto 12) := X"2";

  --  * Control registers
  --  * 0 00 00 ctrl
  --  * 0 00 01
  --  * 0 00 10 ie
  --  * 0 00 11 cause
  --  *  reserved
  --  *
  --  * 1 0000 BP0 Ctrl
  --  * 1 0001 BP0 Data
  --  * 1 0010 BP1 Ctrl
  --  * 1 0011 BP1 Data
  --  * ...
  --  * 1 1110 BP7 Ctrl
  --  * 1 1111 BP7 Data

  constant DBG_CTRL    : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"000";  --debug control
  constant DBG_HIT     : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"001";  --debug HIT register
  constant DBG_IE      : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"002";  --debug interrupt enable (which exception halts the CPU?)
  constant DBG_CAUSE   : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"003";  --debug cause (which exception halted the CPU?)
  constant DBG_BPCTRL0 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"010";  --hardware breakpoint0 control
  constant DBG_BPDATA0 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"011";  --hardware breakpoint0 data
  constant DBG_BPCTRL1 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"012";  --hardware breakpoint1 control
  constant DBG_BPDATA1 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"013";  --hardware breakpoint1 data
  constant DBG_BPCTRL2 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"014";  --hardware breakpoint2 control
  constant DBG_BPDATA2 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"015";  --hardware breakpoint2 data
  constant DBG_BPCTRL3 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"016";  --hardware breakpoint3 control
  constant DBG_BPDATA3 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"017";  --hardware breakpoint3 data
  constant DBG_BPCTRL4 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"018";  --hardware breakpoint4 control
  constant DBG_BPDATA4 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"019";  --hardware breakpoint4 data
  constant DBG_BPCTRL5 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"01A";  --hardware breakpoint5 control
  constant DBG_BPDATA5 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"01B";  --hardware breakpoint5 data
  constant DBG_BPCTRL6 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"01C";  --hardware breakpoint6 control
  constant DBG_BPDATA6 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"01D";  --hardware breakpoint6 data
  constant DBG_BPCTRL7 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"01E";  --hardware breakpoint7 control
  constant DBG_BPDATA7 : std_logic_vector(DU_ADDR_SIZE-1 downto 0) := X"01F";  --hardware breakpoint7 data

  --Debug Codes
  constant DEBUG_SINGLE_STEP_TRACE : integer := 0;
  constant DEBUG_BRANCH_TRACE      : integer := 1;
  constant BP_CTRL_IMP             : integer := 0;
  constant BP_CTRL_ENA             : integer := 1;

  constant BP_CTRL_CC_FETCH        : std_logic_vector(2 downto 0) := "000";
  constant BP_CTRL_CC_LD_ADR       : std_logic_vector(2 downto 0) := "001";
  constant BP_CTRL_CC_ST_ADR       : std_logic_vector(2 downto 0) := "010";
  constant BP_CTRL_CC_LDST_ADR     : std_logic_vector(2 downto 0) := "100";

  --  * addr         Key  Description
  --  * --------------------------------------------
  --  * 0x000-0x01f  GPR  General Purpose Registers
  --  * 0x100-0x11f  FPR  Floating Point Registers
  --  * 0x200        PC   Program Counter
  --  * 0x201        PPC  Previous Program Counter

  constant DBG_GPR : std_logic_vector(11 downto 0) := "0000000XXXXX";
  constant DBG_FPR : std_logic_vector(11 downto 0) := "0001000XXXXX";
  constant DBG_NPC : std_logic_vector(11 downto 0) := X"200";
  constant DBG_PPC : std_logic_vector(11 downto 0) := X"201";

  --  * Bank2 - CSRs
  --  *
  --  * Direct mapping to the 12bit CSR address space

  --RISCV Opcodes Package
  constant ILEN      : integer := 64;
  constant INSTR_NOP : std_logic_vector(ILEN-1 downto 0) := X"0000000000000013";

  --Opcodes
  constant OPC_LOAD     : std_logic_vector(6 downto 2) := "00000";
  constant OPC_LOAD_FP  : std_logic_vector(6 downto 2) := "00001";
  constant OPC_MISC_MEM : std_logic_vector(6 downto 2) := "00011";
  constant OPC_OP_IMM   : std_logic_vector(6 downto 2) := "00100";
  constant OPC_AUIPC    : std_logic_vector(6 downto 2) := "00101";
  constant OPC_OP_IMM32 : std_logic_vector(6 downto 2) := "00110";
  constant OPC_STORE    : std_logic_vector(6 downto 2) := "01000";
  constant OPC_STORE_FP : std_logic_vector(6 downto 2) := "01001";
  constant OPC_AMO      : std_logic_vector(6 downto 2) := "01011";
  constant OPC_OP       : std_logic_vector(6 downto 2) := "01100";
  constant OPC_LUI      : std_logic_vector(6 downto 2) := "01101";
  constant OPC_OP32     : std_logic_vector(6 downto 2) := "01110";
  constant OPC_MADD     : std_logic_vector(6 downto 2) := "10000";
  constant OPC_MSUB     : std_logic_vector(6 downto 2) := "10001";
  constant OPC_NMSUB    : std_logic_vector(6 downto 2) := "10010";
  constant OPC_NMADD    : std_logic_vector(6 downto 2) := "10011";
  constant OPC_OP_FP    : std_logic_vector(6 downto 2) := "10100";
  constant OPC_BRANCH   : std_logic_vector(6 downto 2) := "11000";
  constant OPC_JALR     : std_logic_vector(6 downto 2) := "11001";
  constant OPC_JAL      : std_logic_vector(6 downto 2) := "11011";
  constant OPC_SYSTEM   : std_logic_vector(6 downto 2) := "11100";

  constant OPC00_LOAD   : std_logic_vector(6 downto 0) := "0000000";
  constant OPC00_STORE  : std_logic_vector(6 downto 0) := "0001000";

  constant OPC0_BRANCH  : std_logic_vector(7 downto 2) := "011000";
  constant OPC0_JAL     : std_logic_vector(7 downto 2) := "001011";
  constant OPC0_JALR    : std_logic_vector(7 downto 2) := "011001";

  --RV32/RV64 Base instructions
  constant LUI   : std_logic_vector(15 downto 0) := "XXXXXXXXXXX01101";
  constant AUIPC : std_logic_vector(15 downto 0) := "XXXXXXXXXXX00101";
  constant JAL   : std_logic_vector(15 downto 0) := "XXXXXXXXXXX11011";
  constant JALR  : std_logic_vector(15 downto 0) := "XXXXXXXX00011001";
  constant BEQ   : std_logic_vector(15 downto 0) := "XXXXXXXX00011000";
  constant BNE   : std_logic_vector(15 downto 0) := "XXXXXXXX00111000";
  constant BLT   : std_logic_vector(15 downto 0) := "XXXXXXXX10011000";
  constant BGE   : std_logic_vector(15 downto 0) := "XXXXXXXX10111000";
  constant BLTU  : std_logic_vector(15 downto 0) := "XXXXXXXX11011000";
  constant BGEU  : std_logic_vector(15 downto 0) := "XXXXXXXX11111000";
  constant LB    : std_logic_vector(15 downto 0) := "XXXXXXXX00000000";
  constant LH    : std_logic_vector(15 downto 0) := "XXXXXXXX00100000";
  constant LW    : std_logic_vector(15 downto 0) := "XXXXXXXX01000000";
  constant LBU   : std_logic_vector(15 downto 0) := "XXXXXXXX10000000";
  constant LHU   : std_logic_vector(15 downto 0) := "XXXXXXXX10100000";
  constant LWU   : std_logic_vector(15 downto 0) := "XXXXXXXX11000000";
  constant LD    : std_logic_vector(15 downto 0) := "XXXXXXXX01100000";
  constant SB    : std_logic_vector(15 downto 0) := "XXXXXXXX00001000";
  constant SH    : std_logic_vector(15 downto 0) := "XXXXXXXX00101000";
  constant SW    : std_logic_vector(15 downto 0) := "XXXXXXXX01001000";
  constant SD    : std_logic_vector(15 downto 0) := "XXXXXXXX01101000";
  constant ADDI  : std_logic_vector(15 downto 0) := "XXXXXXXX00000100";
  constant ADDIW : std_logic_vector(15 downto 0) := "0XXXXXXX00000110";
  constant ADDX  : std_logic_vector(15 downto 0) := "X000000000001100";
  constant ADDW  : std_logic_vector(15 downto 0) := "0000000000001110";
  constant SUBX  : std_logic_vector(15 downto 0) := "X010000000001100";
  constant SUBW  : std_logic_vector(15 downto 0) := "0010000000001110";
  constant XORI  : std_logic_vector(15 downto 0) := "XXXXXXXX10000100";
  constant XORX  : std_logic_vector(15 downto 0) := "X000000010001100";
  constant ORI   : std_logic_vector(15 downto 0) := "XXXXXXXX11000100";
  constant ORX   : std_logic_vector(15 downto 0) := "X000000011001100";
  constant ANDI  : std_logic_vector(15 downto 0) := "XXXXXXXX11100100";
  constant ANDX  : std_logic_vector(15 downto 0) := "X000000011101100";
  constant SLLI  : std_logic_vector(15 downto 0) := "X000000X00100100";
  constant SLLIW : std_logic_vector(15 downto 0) := "0000000000100110";
  constant SLLX  : std_logic_vector(15 downto 0) := "X000000000101100";
  constant SLLW  : std_logic_vector(15 downto 0) := "0000000000101110";
  constant SLTI  : std_logic_vector(15 downto 0) := "XXXXXXXX01000100";
  constant SLT   : std_logic_vector(15 downto 0) := "X000000001001100";
  constant SLTU  : std_logic_vector(15 downto 0) := "X000000001101100";
  constant SLTIU : std_logic_vector(15 downto 0) := "XXXXXXXX01100100";
  constant SRLI  : std_logic_vector(15 downto 0) := "X000000X10100100";
  constant SRLIW : std_logic_vector(15 downto 0) := "0000000010100110";
  constant SRLX  : std_logic_vector(15 downto 0) := "X000000010101100";
  constant SRLW  : std_logic_vector(15 downto 0) := "0000000010101110";
  constant SRAI  : std_logic_vector(15 downto 0) := "X010000X10100100";
  constant SRAIW : std_logic_vector(15 downto 0) := "0010000010100110";
  constant SRAX  : std_logic_vector(15 downto 0) := "X010000010101100";
  constant SRAW  : std_logic_vector(15 downto 0) := "X010000010101110";

  --pseudo instructions
  constant SYSTEM  : std_logic_vector(15 downto 0) := "0XXXXXXX00011100";  --excludes RDxxx instructions
  constant MISCMEM : std_logic_vector(15 downto 0) := "0XXXXXXXXXX00011";

  --SYSTEM/MISC_MEM opcodes
  constant FENCE     : std_logic_vector(63 downto 0) := "000000000000000000000000000000000000XXXXXXXX00000000000000001111";
  constant SFENCE_VM : std_logic_vector(63 downto 0) := "00000000000000000000000000000000000100000100XXXXX000000001110011";
  constant FENCE_I   : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000000000000000000001000000001111";
  constant ECALL     : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000000000000000000000000001110011";
  constant EBREAK    : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000000000000100000000000001110011";
  constant MRET      : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000110000001000000000000001110011";
  constant HRET      : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000100000001000000000000001110011";
  constant SRET      : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000010000001000000000000001110011";
  constant URET      : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000000000001000000000000001110011";
  constant MRTS      : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000110000010100000000000001110011";
  constant MRTH      : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000110000011000000000000001110011";
  constant HRTS      : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000100000010100000000000001110011";

  constant WFI       : std_logic_vector(63 downto 0) := "0000000000000000000000000000000000010000010100000000000001110011";

  constant CSRRW  : std_logic_vector(15 downto 0) := "0XXXXXXX00111100";
  constant CSRRS  : std_logic_vector(15 downto 0) := "0XXXXXXX01011100";
  constant CSRRC  : std_logic_vector(15 downto 0) := "0XXXXXXX01111100";
  constant CSRRWI : std_logic_vector(15 downto 0) := "0XXXXXXX10111100";
  constant CSRRSI : std_logic_vector(15 downto 0) := "0XXXXXXX11011100";
  constant CSRRCI : std_logic_vector(15 downto 0) := "0XXXXXXX11111100";

  --RV32/RV64 A-Extensions instructions
  constant LRW      : std_logic_vector(14 downto 0) := "00010XX01001011";
  constant SCW      : std_logic_vector(14 downto 0) := "00011XX01001011";
  constant AMOSWAPW : std_logic_vector(14 downto 0) := "00001XX01001011";
  constant AMOADDW  : std_logic_vector(14 downto 0) := "00000XX01001011";
  constant AMOXORW  : std_logic_vector(14 downto 0) := "00100XX01001011";
  constant AMOANDW  : std_logic_vector(14 downto 0) := "01100XX01001011";
  constant AMOORW   : std_logic_vector(14 downto 0) := "01000XX01001011";
  constant AMOMINW  : std_logic_vector(14 downto 0) := "10000XX01001011";
  constant AMOMAXW  : std_logic_vector(14 downto 0) := "10100XX01001011";
  constant AMOMINUW : std_logic_vector(14 downto 0) := "11000XX01001011";
  constant AMOMAXUW : std_logic_vector(14 downto 0) := "11100XX01001011";

  constant LRD      : std_logic_vector(14 downto 0) := "00010XX01101011";
  constant SCD      : std_logic_vector(14 downto 0) := "00011XX01101011";
  constant AMOSWAPD : std_logic_vector(14 downto 0) := "00001XX01101011";
  constant AMOADDD  : std_logic_vector(14 downto 0) := "00000XX01101011";
  constant AMOXORD  : std_logic_vector(14 downto 0) := "00100XX01101011";
  constant AMOANDD  : std_logic_vector(14 downto 0) := "01100XX01101011";
  constant AMOORD   : std_logic_vector(14 downto 0) := "01000XX01101011";
  constant AMOMIND  : std_logic_vector(14 downto 0) := "10000XX01101011";
  constant AMOMAXD  : std_logic_vector(14 downto 0) := "10100XX01101011";
  constant AMOMINUD : std_logic_vector(14 downto 0) := "11000XX01101011";
  constant AMOMAXUD : std_logic_vector(14 downto 0) := "11100XX01101011";

  --RV32/RV64 M-Extensions instructions
  constant MUL    : std_logic_vector(15 downto 0) := "X000000100001100";
  constant MULH   : std_logic_vector(15 downto 0) := "X000000100101100";
  constant MULW   : std_logic_vector(15 downto 0) := "X000000100001110";
  constant MULHSU : std_logic_vector(15 downto 0) := "X000000101001100";
  constant MULHU  : std_logic_vector(15 downto 0) := "X000000101101100";
  constant DIV    : std_logic_vector(15 downto 0) := "X000000110001100";
  constant DIVW   : std_logic_vector(15 downto 0) := "0000000110001110";
  constant DIVU   : std_logic_vector(15 downto 0) := "X000000110101100";
  constant DIVUW  : std_logic_vector(15 downto 0) := "0000000110101110";
  constant REMX   : std_logic_vector(15 downto 0) := "X000000111001100";
  constant REMW   : std_logic_vector(15 downto 0) := "0000000111001110";
  constant REMU   : std_logic_vector(15 downto 0) := "X000000111101100";
  constant REMUW  : std_logic_vector(15 downto 0) := "0000000111101110";

  --Per Supervisor Spec draft 1.10

  --PMP-CFG Register
  constant OFF   : std_logic_vector(1 downto 0) := "00";
  constant TOR   : std_logic_vector(1 downto 0) := "01";
  constant NA4   : std_logic_vector(1 downto 0) := "10";
  constant NAPOT : std_logic_vector(1 downto 0) := "11";

  constant PMPCFG_MASK : std_logic_vector(7 downto 0) := X"9F";

  --CSR mapping
  --User
  --User Trap Setup
  constant USTATUS      : std_logic_vector(11 downto 0) := X"000";
  constant UIE          : std_logic_vector(11 downto 0) := X"004";
  constant UTVEC        : std_logic_vector(11 downto 0) := X"005";
  --User Trap Handling
  constant USCRATCH     : std_logic_vector(11 downto 0) := X"040";
  constant UEPC         : std_logic_vector(11 downto 0) := X"041";
  constant UCAUSE       : std_logic_vector(11 downto 0) := X"042";
  constant UBADADDR     : std_logic_vector(11 downto 0) := X"043";
  constant UTVAL        : std_logic_vector(11 downto 0) := X"043";
  constant UIP          : std_logic_vector(11 downto 0) := X"044";
  --User Floating-Point CSRs
  constant FFLAGS       : std_logic_vector(11 downto 0) := X"001";
  constant FRM          : std_logic_vector(11 downto 0) := X"002";
  constant FCSR         : std_logic_vector(11 downto 0) := X"003";
  --User Counters/Timers
  constant CYCLE        : std_logic_vector(11 downto 0) := X"C00";
  constant TIMEX        : std_logic_vector(11 downto 0) := X"C01";
  constant INSTRET      : std_logic_vector(11 downto 0) := X"C02";
  constant HPMCOUNTER3  : std_logic_vector(11 downto 0) := X"C03";  --until HPMCOUNTER31='hC1F
  constant CYCLEH       : std_logic_vector(11 downto 0) := X"C80";
  constant TIMEH        : std_logic_vector(11 downto 0) := X"C81";
  constant INSTRETH     : std_logic_vector(11 downto 0) := X"C82";
  constant HPMCOUNTER3H : std_logic_vector(11 downto 0) := X"C83";  --until HPMCONTER31='hC9F

  --Supervisor
  --Supervisor Trap Setup
  constant SSTATUS    : std_logic_vector(11 downto 0) := X"100";
  constant SEDELEG    : std_logic_vector(11 downto 0) := X"102";
  constant SIDELEG    : std_logic_vector(11 downto 0) := X"103";
  constant SIE        : std_logic_vector(11 downto 0) := X"104";
  constant STVEC      : std_logic_vector(11 downto 0) := X"105";
  constant SCOUNTEREN : std_logic_vector(11 downto 0) := X"106";
  --Supervisor Trap Handling
  constant SSCRATCH   : std_logic_vector(11 downto 0) := X"140";
  constant SEPC       : std_logic_vector(11 downto 0) := X"141";
  constant SCAUSE     : std_logic_vector(11 downto 0) := X"142";
  constant STVAL      : std_logic_vector(11 downto 0) := X"143";
  constant SIP        : std_logic_vector(11 downto 0) := X"144";
  --Supervisor Protection and Translation
  constant SATP       : std_logic_vector(11 downto 0) := X"180";

  --Hypervisor
  --Hypervisor trap setup
  constant HSTATUS    : std_logic_vector(11 downto 0) := X"200";
  constant HEDELEG    : std_logic_vector(11 downto 0) := X"202";
  constant HIDELEG    : std_logic_vector(11 downto 0) := X"203";
  constant HIE        : std_logic_vector(11 downto 0) := X"204";
  constant HTVEC      : std_logic_vector(11 downto 0) := X"205";
  --Hypervisor Trap Handling
  constant HSCRATCH   : std_logic_vector(11 downto 0) := X"240";
  constant HEPC       : std_logic_vector(11 downto 0) := X"241";
  constant HCAUSE     : std_logic_vector(11 downto 0) := X"242";
  constant HTVAL      : std_logic_vector(11 downto 0) := X"243";
  constant HIP        : std_logic_vector(11 downto 0) := X"244";

  --Machine
  --Machine Information
  constant MVENDORID  : std_logic_vector(11 downto 0) := X"F11";
  constant MARCHID    : std_logic_vector(11 downto 0) := X"F12";
  constant MIMPID     : std_logic_vector(11 downto 0) := X"F13";
  constant MHARTID    : std_logic_vector(11 downto 0) := X"F14";
  --Machine Trap Setup
  constant MSTATUS    : std_logic_vector(11 downto 0) := X"300";
  constant MISA       : std_logic_vector(11 downto 0) := X"301";
  constant MEDELEG    : std_logic_vector(11 downto 0) := X"302";
  constant MIDELEG    : std_logic_vector(11 downto 0) := X"303";
  constant MIE        : std_logic_vector(11 downto 0) := X"304";
  constant MNMIVEC    : std_logic_vector(11 downto 0) := X"7C0";  --ROALOGIC NMI Vector
  constant MTVEC      : std_logic_vector(11 downto 0) := X"305";
  constant MCOUNTEREN : std_logic_vector(11 downto 0) := X"306";
  --Machine Trap Handling
  constant MSCRATCH   : std_logic_vector(11 downto 0) := X"340";
  constant MEPC       : std_logic_vector(11 downto 0) := X"341";
  constant MCAUSE     : std_logic_vector(11 downto 0) := X"342";
  constant MTVAL      : std_logic_vector(11 downto 0) := X"343";
  constant MIP        : std_logic_vector(11 downto 0) := X"344";
  --Machine Protection and Translation
  constant PMPCFG0    : std_logic_vector(11 downto 0) := X"3A0";
  constant PMPCFG1    : std_logic_vector(11 downto 0) := X"3A1";  --RV32 only
  constant PMPCFG2    : std_logic_vector(11 downto 0) := X"3A2";
  constant PMPCFG3    : std_logic_vector(11 downto 0) := X"3A3";  --RV32 only
  constant PMPADDR0   : std_logic_vector(11 downto 0) := X"3B0";
  constant PMPADDR1   : std_logic_vector(11 downto 0) := X"3B1";
  constant PMPADDR2   : std_logic_vector(11 downto 0) := X"3B2";
  constant PMPADDR3   : std_logic_vector(11 downto 0) := X"3B3";
  constant PMPADDR4   : std_logic_vector(11 downto 0) := X"3B4";
  constant PMPADDR5   : std_logic_vector(11 downto 0) := X"3B5";
  constant PMPADDR6   : std_logic_vector(11 downto 0) := X"3B6";
  constant PMPADDR7   : std_logic_vector(11 downto 0) := X"3B7";
  constant PMPADDR8   : std_logic_vector(11 downto 0) := X"3B8";
  constant PMPADDR9   : std_logic_vector(11 downto 0) := X"3B9";
  constant PMPADDR10  : std_logic_vector(11 downto 0) := X"3BA";
  constant PMPADDR11  : std_logic_vector(11 downto 0) := X"3BB";
  constant PMPADDR12  : std_logic_vector(11 downto 0) := X"3BC";
  constant PMPADDR13  : std_logic_vector(11 downto 0) := X"3BD";
  constant PMPADDR14  : std_logic_vector(11 downto 0) := X"3BE";
  constant PMPADDR15  : std_logic_vector(11 downto 0) := X"3BF";

  --Machine Counters/Timers
  constant MCYCLE        : std_logic_vector(11 downto 0) := X"B00";
  constant MINSTRET      : std_logic_vector(11 downto 0) := X"B02";
  constant MHPMCOUNTER3  : std_logic_vector(11 downto 0) := X"B03";  --until MHPMCOUNTER31='hB1F
  constant MCYCLEH       : std_logic_vector(11 downto 0) := X"B80";
  constant MINSTRETH     : std_logic_vector(11 downto 0) := X"B82";
  constant MHPMCOUNTER3H : std_logic_vector(11 downto 0) := X"B83";  --until MHPMCOUNTER31H='hB9F

  --Machine Counter Setup
  constant MHPEVENT3 : std_logic_vector(11 downto 0) := X"323";  --until MHPEVENT31 = 'h33f

  --Debug
  constant TSELECT  : std_logic_vector(11 downto 0) := X"7A0";
  constant TDATA1   : std_logic_vector(11 downto 0) := X"7A1";
  constant TDATA2   : std_logic_vector(11 downto 0) := X"7A2";
  constant TDATA3   : std_logic_vector(11 downto 0) := X"7A3";
  constant DCSR     : std_logic_vector(11 downto 0) := X"7B0";
  constant DPC      : std_logic_vector(11 downto 0) := X"7B1";
  constant DSCRATCH : std_logic_vector(11 downto 0) := X"7B2";

  --MXL mapping
  constant RV32I  : std_logic_vector(1 downto 0) := "01";
  constant RV32E  : std_logic_vector(1 downto 0) := "01";
  constant RV64I  : std_logic_vector(1 downto 0) := "10";
  constant RV128I : std_logic_vector(1 downto 0) := "11";

  --Privilege Levels
  constant PRV_M : std_logic_vector(1 downto 0) := "11";
  constant PRV_H : std_logic_vector(1 downto 0) := "10";
  constant PRV_S : std_logic_vector(1 downto 0) := "01";
  constant PRV_U : std_logic_vector(1 downto 0) := "00";

  --Virtualisation
  constant VM_MBARE : std_logic_vector(3 downto 0) := "0000";
  constant VM_SV32  : std_logic_vector(3 downto 0) := "0001";
  constant VM_SV39  : std_logic_vector(3 downto 0) := "1000";
  constant VM_SV48  : std_logic_vector(3 downto 0) := "1001";
  constant VM_SV57  : std_logic_vector(3 downto 0) := "1010";
  constant VM_SV64  : std_logic_vector(3 downto 0) := "1011";

  --MIE MIP
  constant MEI : integer := 11;
  constant HEI : integer := 10;
  constant SEI : integer := 9;
  constant UEI : integer := 8;
  constant MTI : integer := 7;
  constant HTI : integer := 6;
  constant STI : integer := 5;
  constant UTI : integer := 4;
  constant MSI : integer := 3;
  constant HSI : integer := 2;
  constant SSI : integer := 1;
  constant USI : integer := 0;

  --Performance Counters
  constant CY : integer := 0;
  constant TM : integer := 1;
  constant IR : integer := 2;

  --Exception Causes
  constant EXCEPTION_SIZE : integer := 16;

  constant CAUSE_MISALIGNED_INSTRUCTION   : integer := 0;
  constant CAUSE_INSTRUCTION_ACCESS_FAULT : integer := 1;
  constant CAUSE_ILLEGAL_INSTRUCTION      : integer := 2;
  constant CAUSE_BREAKPOINT               : integer := 3;
  constant CAUSE_MISALIGNED_LOAD          : integer := 4;
  constant CAUSE_LOAD_ACCESS_FAULT        : integer := 5;
  constant CAUSE_MISALIGNED_STORE         : integer := 6;
  constant CAUSE_STORE_ACCESS_FAULT       : integer := 7;
  constant CAUSE_UMODE_ECALL              : integer := 8;
  constant CAUSE_SMODE_ECALL              : integer := 9;
  constant CAUSE_HMODE_ECALL              : integer := 10;
  constant CAUSE_MMODE_ECALL              : integer := 11;
  constant CAUSE_INSTRUCTION_PAGE_FAULT   : integer := 12;
  constant CAUSE_LOAD_PAGE_FAULT          : integer := 13;
  constant CAUSE_STORE_PAGE_FAULT         : integer := 15;

  constant CAUSE_USINT : integer := 0;
  constant CAUSE_SSINT : integer := 1;
  constant CAUSE_HSINT : integer := 2;
  constant CAUSE_MSINT : integer := 3;
  constant CAUSE_UTINT : integer := 4;
  constant CAUSE_STINT : integer := 5;
  constant CAUSE_HTINT : integer := 6;
  constant CAUSE_MTINT : integer := 7;
  constant CAUSE_UEINT : integer := 8;
  constant CAUSE_SEINT : integer := 9;
  constant CAUSE_HEINT : integer := 10;
  constant CAUSE_MEINT : integer := 11;

  constant MEM_TYPE_EMPTY : std_logic_vector(3 downto 0) := X"0";
  constant MEM_TYPE_MAIN  : std_logic_vector(3 downto 0) := X"1";
  constant MEM_TYPE_IO    : std_logic_vector(3 downto 0) := X"2";
  constant MEM_TYPE_TCM   : std_logic_vector(3 downto 0) := X"3";

  constant AMO_TYPE_NONE       : std_logic_vector(3 downto 0) := X"0";
  constant AMO_TYPE_SWAP       : std_logic_vector(3 downto 0) := X"1";
  constant AMO_TYPE_LOGICAL    : std_logic_vector(3 downto 0) := X"2";
  constant AMO_TYPE_ARITHMETIC : std_logic_vector(3 downto 0) := X"3";

  --AHB3 Lite Package

  --HTRANS
  constant HTRANS_IDLE   : std_logic_vector(1 downto 0) := "00";
  constant HTRANS_BUSY   : std_logic_vector(1 downto 0) := "01";
  constant HTRANS_NONSEQ : std_logic_vector(1 downto 0) := "10";
  constant HTRANS_SEQ    : std_logic_vector(1 downto 0) := "11";

  --HSIZE
  constant HSIZE_B8    : std_logic_vector(2 downto 0) := "000";
  constant HSIZE_B16   : std_logic_vector(2 downto 0) := "001";
  constant HSIZE_B32   : std_logic_vector(2 downto 0) := "010";
  constant HSIZE_B64   : std_logic_vector(2 downto 0) := "011";
  constant HSIZE_B128  : std_logic_vector(2 downto 0) := "100";  --4-word line
  constant HSIZE_B256  : std_logic_vector(2 downto 0) := "101";  --8-word line
  constant HSIZE_B512  : std_logic_vector(2 downto 0) := "110";
  constant HSIZE_B1024 : std_logic_vector(2 downto 0) := "111";
  constant HSIZE_BYTE  : std_logic_vector(2 downto 0) := HSIZE_B8;
  constant HSIZE_HWORD : std_logic_vector(2 downto 0) := HSIZE_B16;
  constant HSIZE_WORD  : std_logic_vector(2 downto 0) := HSIZE_B32;
  constant HSIZE_DWORD : std_logic_vector(2 downto 0) := HSIZE_B64;

  --HBURST
  constant HBURST_SINGLE : std_logic_vector(2 downto 0) := "000";
  constant HBURST_INCR   : std_logic_vector(2 downto 0) := "001";
  constant HBURST_WRAP4  : std_logic_vector(2 downto 0) := "010";
  constant HBURST_INCR4  : std_logic_vector(2 downto 0) := "011";
  constant HBURST_WRAP8  : std_logic_vector(2 downto 0) := "100";
  constant HBURST_INCR8  : std_logic_vector(2 downto 0) := "101";
  constant HBURST_WRAP16 : std_logic_vector(2 downto 0) := "110";
  constant HBURST_INCR16 : std_logic_vector(2 downto 0) := "111";

  --HPROT
  constant HPROT_OPCODE         : std_logic_vector(3 downto 0) := "0000";
  constant HPROT_DATA           : std_logic_vector(3 downto 0) := "0001";
  constant HPROT_USER           : std_logic_vector(3 downto 0) := "0000";
  constant HPROT_PRIVILEGED     : std_logic_vector(3 downto 0) := "0010";
  constant HPROT_NON_BUFFERABLE : std_logic_vector(3 downto 0) := "0000";
  constant HPROT_BUFFERABLE     : std_logic_vector(3 downto 0) := "0100";
  constant HPROT_NON_CACHEABLE  : std_logic_vector(3 downto 0) := "0000";
  constant HPROT_CACHEABLE      : std_logic_vector(3 downto 0) := "1000";

  --HRESP
  constant HRESP_OKAY  : std_logic := '0';
  constant HRESP_ERROR : std_logic := '1';

  --////////////////////////////////////////////////////////////////
  --
  -- Types
  --
  type std_logic_matrix is array (natural range <>) of std_logic_vector;
  type std_logic_3array is array (natural range <>) of std_logic_matrix;
  type std_logic_4array is array (natural range <>) of std_logic_3array;
  type std_logic_5array is array (natural range <>) of std_logic_4array;
  type std_logic_6array is array (natural range <>) of std_logic_5array;
  type std_logic_7array is array (natural range <>) of std_logic_6array;
  type std_logic_8array is array (natural range <>) of std_logic_7array;
  type std_logic_9array is array (natural range <>) of std_logic_8array;

  type xy_std_logic        is array (natural range <>, natural range <>) of std_logic;
  type xy_std_logic_vector is array (natural range <>, natural range <>) of std_logic_vector;
  type xy_std_logic_matrix is array (natural range <>, natural range <>) of std_logic_matrix;
  type xy_std_logic_3array is array (natural range <>, natural range <>) of std_logic_3array;
  type xy_std_logic_4array is array (natural range <>, natural range <>) of std_logic_4array;
  type xy_std_logic_5array is array (natural range <>, natural range <>) of std_logic_5array;
  type xy_std_logic_6array is array (natural range <>, natural range <>) of std_logic_6array;
  type xy_std_logic_7array is array (natural range <>, natural range <>) of std_logic_7array;
  type xy_std_logic_8array is array (natural range <>, natural range <>) of std_logic_8array;
  type xy_std_logic_9array is array (natural range <>, natural range <>) of std_logic_9array;

  type xyz_std_logic        is array (natural range <>, natural range <>, natural range <>) of std_logic;
  type xyz_std_logic_vector is array (natural range <>, natural range <>, natural range <>) of std_logic_vector;
  type xyz_std_logic_matrix is array (natural range <>, natural range <>, natural range <>) of std_logic_matrix;
  type xyz_std_logic_3array is array (natural range <>, natural range <>, natural range <>) of std_logic_3array;
  type xyz_std_logic_4array is array (natural range <>, natural range <>, natural range <>) of std_logic_4array;
  type xyz_std_logic_5array is array (natural range <>, natural range <>, natural range <>) of std_logic_5array;
  type xyz_std_logic_6array is array (natural range <>, natural range <>, natural range <>) of std_logic_6array;
  type xyz_std_logic_7array is array (natural range <>, natural range <>, natural range <>) of std_logic_7array;
  type xyz_std_logic_8array is array (natural range <>, natural range <>, natural range <>) of std_logic_8array;
  type xyz_std_logic_9array is array (natural range <>, natural range <>, natural range <>) of std_logic_9array;

end mpsoc_mpram_ahb3_pkg;
