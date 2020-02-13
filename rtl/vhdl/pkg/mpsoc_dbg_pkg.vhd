-- Converted from rtl/verilog/pkg/mpsoc_dbg_pkg.sv
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
--              Degub Interface                                               //
--              AMBA3 AHB-Lite Bus Interface                                  //
--              WishBone Bus Interface                                        //
--                                                                            //
--//////////////////////////////////////////////////////////////////////////////

-- Copyright (c) 2018-2019 by the author(s)
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

package mpsoc_dbg_pkg is

  constant DBG_TOP_DATAREG_LEN : integer := 64;

  -- How many modules can be supported by the module id length
  constant DBG_TOP_MAX_MODULES : integer := 4;

  -- Length of the MODULE ID register
  constant DBG_TOP_MODULE_ID_LENGTH : integer := integer(log2(real(DBG_TOP_MAX_MODULES)));

  -- Chains
  constant DBG_TOP_BUSIF_DEBUG_MODULE  : integer := 0;
  constant DBG_TOP_CPU_DEBUG_MODULE    : integer := 1;
  constant DBG_TOP_JSP_DEBUG_MODULE    : integer := 2;
  constant DBG_TOP_RESERVED_DBG_MODULE : integer := 3;

  -- Size of data-shift-register
  -- 01bit cmd
  -- 04bit operation
  -- 04bit core/thread select
  -- 32bit address
  -- 16bit count
  -- Should we put this in a packed struct?!
  constant DBG_OR1K_DATAREG_LEN : integer := 64;

  -- Size of the register-select register
  constant DBG_OR1K_REGSELECT_LEN : integer := 2;

  -- Register index definitions for module-internal registers
  -- Index 0 is the Status register, used for stall and reset
  constant DBG_OR1K_INTREG_STATUS : std_logic_vector(DBG_OR1K_REGSELECT_LEN-1 downto 0) := (others => '0');

  -- Valid commands/opcodes for the or1k debug module
  -- 0000        NOP
  -- 0001 - 0010 Reserved
  -- 0011        Write burst, 32-bit access
  -- 0100 - 0110 Reserved
  -- 0111        Read burst, 32-bit access
  -- 1000        Reserved
  -- 1001        Internal register select/write
  -- 1010 - 1100 Reserved
  -- 1101        Internal register select
  -- 1110 - 1111 Reserved
  constant DBG_OR1K_CMD_BWRITE32 : std_logic_vector(3 downto 0) := X"3";
  constant DBG_OR1K_CMD_BREAD32  : std_logic_vector(3 downto 0) := X"7";
  constant DBG_OR1K_CMD_IREG_WR  : std_logic_vector(3 downto 0) := X"9";
  constant DBG_OR1K_CMD_IREG_SEL : std_logic_vector(3 downto 0) := X"d";

  constant DBG_JSP_DATAREG_LEN : integer := 64;

  -- AMBA3 AHB-Lite Interface
  -- The AHB3 debug module requires 53 bits
  constant DBG_AHB_DATAREG_LEN : integer := 64;

  -- These relate to the number of internal registers, and how
  -- many bits are required in the Reg. Select register
  constant DBG_AHB_REGSELECT_SIZE : std_logic := '1';
  constant DBG_AHB_NUM_INTREG     : std_logic := '1';

  -- Register index definitions for module-internal registers
  -- The AHB module has just 1, the error register
  constant DBG_AHB_INTREG_ERROR : std_logic := '0';

  -- Valid commands/opcodes for the AHB debug module (same as Wishbone)
  -- 0000  NOP
  -- 0001  Write burst, 8-bit access
  -- 0010  Write burst, 16-bit access
  -- 0011  Write burst, 32-bit access
  -- 0100  Write burst, 64-bit access
  -- 0101  Read burst, 8-bit access
  -- 0110  Read burst, 16-bit access
  -- 0111  Read burst, 32-bit access
  -- 1000  Read burst, 64-bit access
  -- 1001  Internal register select/write
  -- 1010 - 1100 Reserved
  -- 1101  Internal register select
  -- 1110 - 1111 Reserved
  constant DBG_AHB_CMD_BWRITE8  : std_logic_vector(3 downto 0) := X"1";
  constant DBG_AHB_CMD_BWRITE16 : std_logic_vector(3 downto 0) := X"2";
  constant DBG_AHB_CMD_BWRITE32 : std_logic_vector(3 downto 0) := X"3";
  constant DBG_AHB_CMD_BWRITE64 : std_logic_vector(3 downto 0) := X"4";
  constant DBG_AHB_CMD_BREAD8   : std_logic_vector(3 downto 0) := X"5";
  constant DBG_AHB_CMD_BREAD16  : std_logic_vector(3 downto 0) := X"6";
  constant DBG_AHB_CMD_BREAD32  : std_logic_vector(3 downto 0) := X"7";
  constant DBG_AHB_CMD_BREAD64  : std_logic_vector(3 downto 0) := X"8";
  constant DBG_AHB_CMD_IREG_WR  : std_logic_vector(3 downto 0) := X"9";
  constant DBG_AHB_CMD_IREG_SEL : std_logic_vector(3 downto 0) := X"d";

--AHB definitions
  constant HTRANS_IDLE   : std_logic_vector(1 downto 0) := "00";
  constant HTRANS_BUSY   : std_logic_vector(1 downto 0) := "01";
  constant HTRANS_NONSEQ : std_logic_vector(1 downto 0) := "10";
  constant HTRANS_SEQ    : std_logic_vector(1 downto 0) := "11";

  constant HBURST_SINGLE : std_logic_vector(2 downto 0) := "000";
  constant HBURST_INCR   : std_logic_vector(2 downto 0) := "001";
  constant HBURST_WRAP4  : std_logic_vector(2 downto 0) := "010";
  constant HBURST_INCR4  : std_logic_vector(2 downto 0) := "011";
  constant HBURST_WRAP8  : std_logic_vector(2 downto 0) := "100";
  constant HBURST_INCR8  : std_logic_vector(2 downto 0) := "101";
  constant HBURST_WRAP16 : std_logic_vector(2 downto 0) := "110";
  constant HBURST_INCR16 : std_logic_vector(2 downto 0) := "111";

  constant HSIZE8    : std_logic_vector(2 downto 0) := "000";
  constant HSIZE16   : std_logic_vector(2 downto 0) := "001";
  constant HSIZE32   : std_logic_vector(2 downto 0) := "010";
  constant HSIZE64   : std_logic_vector(2 downto 0) := "011";
  constant HSIZE128  : std_logic_vector(2 downto 0) := "100";
  constant HSIZE256  : std_logic_vector(2 downto 0) := "101";
  constant HSIZE512  : std_logic_vector(2 downto 0) := "110";
  constant HSIZE1024 : std_logic_vector(2 downto 0) := "111";

  constant HSIZE_BYTE   : std_logic_vector(2 downto 0) := "000";
  constant HSIZE_HWORD  : std_logic_vector(2 downto 0) := "001";
  constant HSIZE_WORD   : std_logic_vector(2 downto 0) := "010";
  constant HSIZE_DWORD  : std_logic_vector(2 downto 0) := "011";
  constant HSIZE_4WLINE : std_logic_vector(2 downto 0) := "100";
  constant HSIZE_8WLINE : std_logic_vector(2 downto 0) := "101";

  constant HPROT_OPCODE         : std_logic_vector(3 downto 0) := "0000";
  constant HPROT_DATA           : std_logic_vector(3 downto 0) := "0001";
  constant HPROT_USER           : std_logic_vector(3 downto 0) := "0000";
  constant HPROT_PRIVILEGED     : std_logic_vector(3 downto 0) := "0010";
  constant HPROT_NON_BUFFERABLE : std_logic_vector(3 downto 0) := "0000";
  constant HPROT_BUFFERABLE     : std_logic_vector(3 downto 0) := "0100";
  constant HPROT_NON_CACHEABLE  : std_logic_vector(3 downto 0) := "0000";
  constant HPROT_CACHEABLE      : std_logic_vector(3 downto 0) := "1000";

  constant HRESP_OKAY : std_logic := '0';
  constant HRESP_ERR  : std_logic := '1';

  -- Wishbone Interface
  -- The Wishbone debug module requires 53 bits
  constant DBG_WB_DATAREG_LEN : integer := 64;

  -- These relate to the number of internal registers, and how
  -- many bits are required in the Reg. Select register
  constant DBG_WB_REGSELECT_SIZE : std_logic := '1';
  constant DBG_WB_NUM_INTREG     : std_logic := '1';

  -- Register index definitions for module-internal registers
  -- The WB module has just 1, the error register
  constant DBG_WB_INTREG_ERROR : std_logic := '0';

  -- Valid commands/opcodes for the wishbone debug module
  -- 0000  NOP
  -- 0001  Write burst, 8-bit access
  -- 0010  Write burst, 16-bit access
  -- 0011  Write burst, 32-bit access
  -- 0100  Write burst, 64-bit access
  -- 0101  Read burst, 8-bit access
  -- 0110  Read burst, 16-bit access
  -- 0111  Read burst, 32-bit access
  -- 1000  Read burst, 64-bit access
  -- 1001  Internal register select/write
  -- 1010 - 1100 Reserved
  -- 1101  Internal register select
  -- 1110 - 1111 Reserved
  constant DBG_WB_CMD_BWRITE8  : std_logic_vector(3 downto 0) := X"1";
  constant DBG_WB_CMD_BWRITE16 : std_logic_vector(3 downto 0) := X"2";
  constant DBG_WB_CMD_BWRITE32 : std_logic_vector(3 downto 0) := X"3";
  constant DBG_WB_CMD_BWRITE64 : std_logic_vector(3 downto 0) := X"4";
  constant DBG_WB_CMD_BREAD8   : std_logic_vector(3 downto 0) := X"5";
  constant DBG_WB_CMD_BREAD16  : std_logic_vector(3 downto 0) := X"6";
  constant DBG_WB_CMD_BREAD32  : std_logic_vector(3 downto 0) := X"7";
  constant DBG_WB_CMD_BREAD64  : std_logic_vector(3 downto 0) := X"8";
  constant DBG_WB_CMD_IREG_WR  : std_logic_vector(3 downto 0) := X"9";
  constant DBG_WB_CMD_IREG_SEL : std_logic_vector(3 downto 0) := X"d";

  constant X : integer := 2;
  constant Y : integer := 2;
  constant Z : integer := 2;

  constant CORES_PER_TILE : integer := 4;

  constant ADDR_WIDTH : integer := 32;
  constant DATA_WIDTH : integer := 32;

  constant CPU_ADDR_WIDTH : integer := 32;
  constant CPU_DATA_WIDTH : integer := 32;

  constant DATAREG_LEN : integer := 64;

  type M_CORES_PER_TILE_CPU_ADDR_WIDTH is array (CORES_PER_TILE-1 downto 0) of std_logic_vector(CPU_ADDR_WIDTH-1 downto 0);
  type M_CORES_PER_TILE_CPU_DATA_WIDTH is array (CORES_PER_TILE-1 downto 0) of std_logic_vector(CPU_DATA_WIDTH-1 downto 0);

  type M_CORES_PER_TILE_ADDR_WIDTH is array (CORES_PER_TILE-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
  type M_CORES_PER_TILE_DATA_WIDTH is array (CORES_PER_TILE-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);

  type M_XYZ_CORES_PER_TILE is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of std_logic_vector(CORES_PER_TILE-1 downto 0);

  type M_XYZ_CORES_PER_TILE_CPU_ADDR_WIDTH is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of M_CORES_PER_TILE_CPU_ADDR_WIDTH;
  type M_XYZ_CORES_PER_TILE_CPU_DATA_WIDTH is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of M_CORES_PER_TILE_CPU_DATA_WIDTH;

  type M_XYZ_CORES_PER_TILE_ADDR_WIDTH is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of M_CORES_PER_TILE_ADDR_WIDTH;
  type M_XYZ_CORES_PER_TILE_DATA_WIDTH is array (X-1 downto 0, Y-1 downto 0, Z-1 downto 0) of M_CORES_PER_TILE_DATA_WIDTH;

end mpsoc_dbg_pkg;
