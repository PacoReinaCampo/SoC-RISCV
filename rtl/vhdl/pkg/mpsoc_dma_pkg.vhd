-- Converted from rtl/verilog/pkg/mpsoc_dma_pkg.sv
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
--              Direct Access Memory Interface                                //
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

package mpsoc_dma_pkg is

  constant FLIT_TYPE_PAYLOAD : std_logic_vector(1 downto 0) := "00";
  constant FLIT_TYPE_HEADER  : std_logic_vector(1 downto 0) := "01";
  constant FLIT_TYPE_LAST    : std_logic_vector(1 downto 0) := "10";
  constant FLIT_TYPE_SINGLE  : std_logic_vector(1 downto 0) := "11";

  -- Convenience definitions for mesh
  constant SELECT_NONE  : std_logic_vector(4 downto 0) := "00000";
  constant SELECT_NORTH : std_logic_vector(4 downto 0) := "00001";
  constant SELECT_EAST  : std_logic_vector(4 downto 0) := "00010";
  constant SELECT_SOUTH : std_logic_vector(4 downto 0) := "00100";
  constant SELECT_WEST  : std_logic_vector(4 downto 0) := "01000";
  constant SELECT_LOCAL : std_logic_vector(4 downto 0) := "10000";

  constant NORTH : integer := 0;
  constant EAST  : integer := 1;
  constant SOUTH : integer := 2;
  constant WEST  : integer := 3;
  constant LOCAL : integer := 4;

  constant FLIT_WIDTH : integer := 34;

  -- Type of flit
  -- The coding is chosen, so that
  -- type[0] signals that this is the first flit of a packet
  -- type[1] signals that this is the last flit of a packet

  constant FLIT_TYPE_MSB   : integer := FLIT_WIDTH-1;
  constant FLIT_TYPE_WIDTH : integer := 2;
  constant FLIT_TYPE_LSB   : integer := FLIT_TYPE_MSB-FLIT_TYPE_WIDTH+1;

  -- This is the flit content size
  constant FLIT_CONTENT_WIDTH : integer := 32;
  constant FLIT_CONTENT_MSB   : integer := 31;
  constant FLIT_CONTENT_LSB   : integer := 0;

  -- The following fields are only valid for header flits
  constant FLIT_DEST_WIDTH : integer := 5;
  -- destination address field of header flit
  constant FLIT_DEST_MSB   : integer := FLIT_CONTENT_MSB;
  constant FLIT_DEST_LSB   : integer := FLIT_DEST_MSB-FLIT_DEST_WIDTH+1;

  -- packet type field  of header flit
  constant PACKET_CLASS_MSB   : integer := FLIT_DEST_LSB-1;
  constant PACKET_CLASS_WIDTH : integer := 3;
  constant PACKET_CLASS_LSB   : integer := PACKET_CLASS_MSB-PACKET_CLASS_WIDTH+1;

  constant PACKET_CLASS_DMA : std_logic_vector(2 downto 0) := "010";

  -- source address field  of header flit
  constant SOURCE_MSB   : integer := 23;
  constant SOURCE_WIDTH : integer := 5;
  constant SOURCE_LSB   : integer := 19;

  -- packet id field  of header flit
  constant PACKET_ID_MSB   : integer := 18;
  constant PACKET_ID_WIDTH : integer := 4;
  constant PACKET_ID_LSB   : integer := 15;

  constant PACKET_TYPE_MSB   : integer := 14;
  constant PACKET_TYPE_WIDTH : integer := 2;
  constant PACKET_TYPE_LSB   : integer := 13;

  constant PACKET_TYPE_L2R_REQ  : std_logic_vector(1 downto 0) := "00";
  constant PACKET_TYPE_R2L_REQ  : std_logic_vector(1 downto 0) := "01";
  constant PACKET_TYPE_L2R_RESP : std_logic_vector(1 downto 0) := "10";
  constant PACKET_TYPE_R2L_RESP : std_logic_vector(1 downto 0) := "11";

  constant PACKET_REQ_LAST  : integer := 12;
  constant PACKET_RESP_LAST : integer := 12;

  constant SIZE_MSB   : integer := 31;
  constant SIZE_WIDTH : integer := 32;
  constant SIZE_LSB   : integer := 0;

  constant DMA_REQUEST_WIDTH : integer := 103;

  constant DMA_REQFIELD_LADDR_WIDTH : integer := 32;
  constant DMA_REQFIELD_SIZE_WIDTH  : integer := 32;
  constant DMA_REQFIELD_RTILE_WIDTH : integer := 5;
  constant DMA_REQFIELD_RADDR_WIDTH : integer := 32;

  constant DMA_REQFIELD_LADDR_MSB : integer := 102;
  constant DMA_REQFIELD_LADDR_LSB : integer := 70;
  constant DMA_REQFIELD_SIZE_MSB  : integer := 69;
  constant DMA_REQFIELD_SIZE_LSB  : integer := 38;
  constant DMA_REQFIELD_RTILE_MSB : integer := 37;
  constant DMA_REQFIELD_RTILE_LSB : integer := 33;
  constant DMA_REQFIELD_RADDR_MSB : integer := 32;
  constant DMA_REQFIELD_RADDR_LSB : integer := 1;
  constant DMA_REQFIELD_DIR       : integer := 0;

  constant DMA_REQUEST_INVALID : std_logic := '0';
  constant DMA_REQUEST_VALID   : std_logic := '1';

  constant DMA_REQUEST_L2R : std_logic := '0';
  constant DMA_REQUEST_R2L : std_logic := '1';

  constant DMA_REQMASK_WIDTH : integer := 5;
  constant DMA_REQMASK_LADDR : integer := 0;
  constant DMA_REQMASK_SIZE  : integer := 1;
  constant DMA_REQMASK_RTILE : integer := 2;
  constant DMA_REQMASK_RADDR : integer := 3;
  constant DMA_REQMASK_DIR   : integer := 4;

  constant DMA_RESPFIELD_SIZE_WIDTH : integer := 14;

end mpsoc_dma_pkg;
