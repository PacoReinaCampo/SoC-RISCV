-- Converted from pkg/mpsoc_msi_pkg.sv
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

-- Copyright (c) 2019-2020 by the author(s)
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

package mpsoc_msi_pkg is

  --////////////////////////////////////////////////////////////////
  --
  -- Constants MSI
  --

  constant CORES_PER_MISD : integer := 4;
  constant CORES_PER_SIMD : integer := 4;

  constant PLEN : integer := 64;
  constant XLEN : integer := 64;

  constant MASTERS : integer := 5;
  constant SLAVES  : integer := 5;

  --////////////////////////////////////////////////////////////////
  --
  -- Types MSI
  --

  type M_MASTERS_PLEN is array (MASTERS-1 downto 0) of std_logic_vector(PLEN-1 downto 0);
  type M_MASTERS_XLEN is array (MASTERS-1 downto 0) of std_logic_vector(XLEN-1 downto 0);
  type M_MASTERS_3 is array (MASTERS-1 downto 0) of std_logic_vector(3 downto 0);
  type M_MASTERS_2 is array (MASTERS-1 downto 0) of std_logic_vector(2 downto 0);
  type M_MASTERS_1 is array (MASTERS-1 downto 0) of std_logic_vector(1 downto 0);

  type M_2_MASTERS is array (2 downto 0) of std_logic_vector(MASTERS-1 downto 0);

  type M_SLAVES_PLEN is array (SLAVES-1 downto 0) of std_logic_vector(PLEN-1 downto 0);
  type M_SLAVES_XLEN is array (SLAVES-1 downto 0) of std_logic_vector(XLEN-1 downto 0);
  type M_SLAVES_3 is array (SLAVES-1 downto 0) of std_logic_vector(3 downto 0);
  type M_SLAVES_2 is array (SLAVES-1 downto 0) of std_logic_vector(2 downto 0);
  type M_SLAVES_1 is array (SLAVES-1 downto 0) of std_logic_vector(1 downto 0);

  type M_MASTERS_SLAVES is array (MASTERS-1 downto 0) of std_logic_vector(SLAVES-1 downto 0);

  type M_MASTERS_SLAVES_XLEN is array (MASTERS-1 downto 0) of M_SLAVES_XLEN;

  type M_SLAVES_MASTERS is array (SLAVES-1 downto 0) of std_logic_vector(MASTERS-1 downto 0);

  type M_SLAVES_MASTERS_PLEN is array (SLAVES-1 downto 0) of M_MASTERS_PLEN;
  type M_SLAVES_MASTERS_XLEN is array (SLAVES-1 downto 0) of M_MASTERS_XLEN;
  type M_SLAVES_MASTERS_3 is array (SLAVES-1 downto 0) of M_MASTERS_3;
  type M_SLAVES_MASTERS_2 is array (SLAVES-1 downto 0) of M_MASTERS_2;
  type M_SLAVES_MASTERS_1 is array (SLAVES-1 downto 0) of M_MASTERS_1;

  type M_CORES_PER_MISD_MASTERS_PLEN is array (CORES_PER_MISD-1 downto 0) of M_MASTERS_PLEN;
  type M_CORES_PER_MISD_MASTERS_XLEN is array (CORES_PER_MISD-1 downto 0) of M_MASTERS_XLEN;
  type M_CORES_PER_MISD_MASTERS_3 is array (CORES_PER_MISD-1 downto 0) of M_MASTERS_3;
  type M_CORES_PER_MISD_MASTERS_2 is array (CORES_PER_MISD-1 downto 0) of M_MASTERS_2;
  type M_CORES_PER_MISD_MASTERS_1 is array (CORES_PER_MISD-1 downto 0) of M_MASTERS_1;
  type M_CORES_PER_MISD_MASTERS is array (CORES_PER_MISD-1 downto 0) of std_logic_vector(MASTERS-1 downto 0);

  type M_CORES_PER_MISD_SLAVES_PLEN is array (CORES_PER_MISD-1 downto 0) of M_SLAVES_PLEN;
  type M_CORES_PER_MISD_SLAVES_XLEN is array (CORES_PER_MISD-1 downto 0) of M_SLAVES_XLEN;
  type M_CORES_PER_MISD_SLAVES_3 is array (CORES_PER_MISD-1 downto 0) of M_SLAVES_3;
  type M_CORES_PER_MISD_SLAVES_2 is array (CORES_PER_MISD-1 downto 0) of M_SLAVES_2;
  type M_CORES_PER_MISD_SLAVES_1 is array (CORES_PER_MISD-1 downto 0) of M_SLAVES_1;
  type M_CORES_PER_MISD_SLAVES is array (CORES_PER_MISD-1 downto 0) of std_logic_vector(SLAVES-1 downto 0);

  type M_CORES_PER_SIMD_MASTERS_PLEN is array (CORES_PER_SIMD-1 downto 0) of M_MASTERS_PLEN;
  type M_CORES_PER_SIMD_MASTERS_XLEN is array (CORES_PER_SIMD-1 downto 0) of M_MASTERS_XLEN;
  type M_CORES_PER_SIMD_MASTERS_3 is array (CORES_PER_SIMD-1 downto 0) of M_MASTERS_3;
  type M_CORES_PER_SIMD_MASTERS_2 is array (CORES_PER_SIMD-1 downto 0) of M_MASTERS_2;
  type M_CORES_PER_SIMD_MASTERS_1 is array (CORES_PER_SIMD-1 downto 0) of M_MASTERS_1;
  type M_CORES_PER_SIMD_MASTERS is array (CORES_PER_SIMD-1 downto 0) of std_logic_vector(MASTERS-1 downto 0);

  type M_CORES_PER_SIMD_SLAVES_PLEN is array (CORES_PER_SIMD-1 downto 0) of M_SLAVES_PLEN;
  type M_CORES_PER_SIMD_SLAVES_XLEN is array (CORES_PER_SIMD-1 downto 0) of M_SLAVES_XLEN;
  type M_CORES_PER_SIMD_SLAVES_3 is array (CORES_PER_SIMD-1 downto 0) of M_SLAVES_3;
  type M_CORES_PER_SIMD_SLAVES_2 is array (CORES_PER_SIMD-1 downto 0) of M_SLAVES_2;
  type M_CORES_PER_SIMD_SLAVES_1 is array (CORES_PER_SIMD-1 downto 0) of M_SLAVES_1;
  type M_CORES_PER_SIMD_SLAVES is array (CORES_PER_SIMD-1 downto 0) of std_logic_vector(SLAVES-1 downto 0);

end mpsoc_msi_pkg;
