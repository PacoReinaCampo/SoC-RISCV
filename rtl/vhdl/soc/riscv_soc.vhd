-- Converted from riscv_soc.sv
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
--              System on Chip                                                //
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

use work.riscv_mpsoc_pkg.all;

entity riscv_soc is
  generic (
    XLEN : integer := 64;
    PLEN : integer := 64;

    PC_INIT : std_logic_vector(63 downto 0) := X"0000000080000000";

    HAS_USER  : std_logic := '1';
    HAS_SUPER : std_logic := '1';
    HAS_HYPER : std_logic := '1';
    HAS_BPU   : std_logic := '1';
    HAS_FPU   : std_logic := '1';
    HAS_MMU   : std_logic := '1';
    HAS_RVM   : std_logic := '1';
    HAS_RVA   : std_logic := '1';
    HAS_RVC   : std_logic := '1';

    IS_RV32E : std_logic := '1';

    MULT_LATENCY : std_logic := '1';

    BREAKPOINTS : integer := 8;         --Number of hardware breakpoints

    PMA_CNT : integer := 4;
    PMP_CNT : integer := 16;  --Number of Physical Memory Protection entries

    BP_GLOBAL_BITS : integer := 2;
    BP_LOCAL_BITS  : integer := 10;

    ICACHE_SIZE        : integer := 0;   --in KBytes
    ICACHE_BLOCK_SIZE  : integer := 32;  --in Bytes
    ICACHE_WAYS        : integer := 2;   --'n'-way set associative
    ICACHE_REPLACE_ALG : integer := 0;
    ITCM_SIZE          : integer := 0;

    DCACHE_SIZE        : integer := 0;   --in KBytes
    DCACHE_BLOCK_SIZE  : integer := 32;  --in Bytes
    DCACHE_WAYS        : integer := 2;   --'n'-way set associative
    DCACHE_REPLACE_ALG : integer := 0;
    DTCM_SIZE          : integer := 0;
    WRITEBUFFER_SIZE   : integer := 8;

    TECHNOLOGY : string := "GENERIC";

    MNMIVEC_DEFAULT : std_logic_vector(63 downto 0) := X"0000000000000004";
    MTVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"0000000000000040";
    HTVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"0000000000000080";
    STVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"00000000000000C0";
    UTVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"0000000000000100";

    JEDEC_BANK : integer := 10;

    JEDEC_MANUFACTURER_ID : std_logic_vector(7 downto 0) := X"6E";

    HARTID : integer := 0;

    PARCEL_SIZE : integer := 32;

    HADDR_SIZE : integer := 64;
    HDATA_SIZE : integer := 64;
    PADDR_SIZE : integer := 64;
    PDATA_SIZE : integer := 64;

    FLIT_WIDTH : integer := 34;

    SYNC_DEPTH : integer := 3;

    CORES_PER_SIMD : integer := 4;
    CORES_PER_MISD : integer := 4;

    CORES_PER_TILE : integer := 8;

    CHANNELS : integer := 7
    );

  port (
    --Common signals
    HRESETn : in std_logic;
    HCLK    : in std_logic;

    --PMA configuration
    pma_cfg_i : in M_PMA_CNT_13;
    pma_adr_i : in M_PMA_CNT_PLEN;

    --AHB instruction - Single Port
    sins_simd_HSEL      : out std_logic;
    sins_simd_HADDR     : out std_logic_vector(PLEN-1 downto 0);
    sins_simd_HWDATA    : out std_logic_vector(XLEN-1 downto 0);
    sins_simd_HRDATA    : in  std_logic_vector(XLEN-1 downto 0);
    sins_simd_HWRITE    : out std_logic;
    sins_simd_HSIZE     : out std_logic_vector(2 downto 0);
    sins_simd_HBURST    : out std_logic_vector(2 downto 0);
    sins_simd_HPROT     : out std_logic_vector(3 downto 0);
    sins_simd_HTRANS    : out std_logic_vector(1 downto 0);
    sins_simd_HMASTLOCK : out std_logic;
    sins_simd_HREADY    : in  std_logic;
    sins_simd_HRESP     : in  std_logic;

    --AHB data - Single Port
    sdat_misd_HSEL      : out std_logic;
    sdat_misd_HADDR     : out std_logic_vector(PLEN-1 downto 0);
    sdat_misd_HWDATA    : out std_logic_vector(XLEN-1 downto 0);
    sdat_misd_HRDATA    : in  std_logic_vector(XLEN-1 downto 0);
    sdat_misd_HWRITE    : out std_logic;
    sdat_misd_HSIZE     : out std_logic_vector(2 downto 0);
    sdat_misd_HBURST    : out std_logic_vector(2 downto 0);
    sdat_misd_HPROT     : out std_logic_vector(3 downto 0);
    sdat_misd_HTRANS    : out std_logic_vector(1 downto 0);
    sdat_misd_HMASTLOCK : out std_logic;
    sdat_misd_HREADY    : in  std_logic;
    sdat_misd_HRESP     : in  std_logic;

    --AHB instruction - Multi Port
    mins_misd_HSEL      : out std_logic_vector(CORES_PER_MISD-1 downto 0);
    mins_misd_HADDR     : out M_CORES_PER_MISD_PLEN;
    mins_misd_HWDATA    : out M_CORES_PER_MISD_XLEN;
    mins_misd_HRDATA    : in  M_CORES_PER_MISD_XLEN;
    mins_misd_HWRITE    : out std_logic_vector(CORES_PER_MISD-1 downto 0);
    mins_misd_HSIZE     : out M_CORES_PER_MISD_2;
    mins_misd_HBURST    : out M_CORES_PER_MISD_2;
    mins_misd_HPROT     : out M_CORES_PER_MISD_3;
    mins_misd_HTRANS    : out M_CORES_PER_MISD_1;
    mins_misd_HMASTLOCK : out std_logic_vector(CORES_PER_MISD-1 downto 0);
    mins_misd_HREADY    : in  std_logic_vector(CORES_PER_MISD-1 downto 0);
    mins_misd_HRESP     : in  std_logic_vector(CORES_PER_MISD-1 downto 0);

    --AHB data - Multi Port
    mdat_simd_HSEL      : out std_logic_vector(CORES_PER_SIMD-1 downto 0);
    mdat_simd_HADDR     : out M_CORES_PER_SIMD_PLEN;
    mdat_simd_HWDATA    : out M_CORES_PER_SIMD_XLEN;
    mdat_simd_HRDATA    : in  M_CORES_PER_SIMD_XLEN;
    mdat_simd_HWRITE    : out std_logic_vector(CORES_PER_SIMD-1 downto 0);
    mdat_simd_HSIZE     : out M_CORES_PER_SIMD_2;
    mdat_simd_HBURST    : out M_CORES_PER_SIMD_2;
    mdat_simd_HPROT     : out M_CORES_PER_SIMD_3;
    mdat_simd_HTRANS    : out M_CORES_PER_SIMD_1;
    mdat_simd_HMASTLOCK : out std_logic_vector(CORES_PER_SIMD-1 downto 0);
    mdat_simd_HREADY    : in  std_logic_vector(CORES_PER_SIMD-1 downto 0);
    mdat_simd_HRESP     : in  std_logic_vector(CORES_PER_SIMD-1 downto 0);

    --Interrupts Interface
    ext_misd_nmi  : in std_logic_vector(CORES_PER_MISD-1 downto 0);
    ext_misd_tint : in std_logic_vector(CORES_PER_MISD-1 downto 0);
    ext_misd_sint : in std_logic_vector(CORES_PER_MISD-1 downto 0);
    ext_misd_int  : in M_CORES_PER_MISD_3;

    ext_simd_nmi  : in std_logic_vector(CORES_PER_SIMD-1 downto 0);
    ext_simd_tint : in std_logic_vector(CORES_PER_SIMD-1 downto 0);
    ext_simd_sint : in std_logic_vector(CORES_PER_SIMD-1 downto 0);
    ext_simd_int  : in M_CORES_PER_SIMD_3;

    --Debug Interface
    dbg_misd_stall : in  std_logic_vector(CORES_PER_MISD-1 downto 0);
    dbg_misd_strb  : in  std_logic_vector(CORES_PER_MISD-1 downto 0);
    dbg_misd_we    : in  std_logic_vector(CORES_PER_MISD-1 downto 0);
    dbg_misd_addr  : in  M_CORES_PER_MISD_PLEN;
    dbg_misd_dati  : in  M_CORES_PER_MISD_XLEN;
    dbg_misd_dato  : out M_CORES_PER_MISD_XLEN;
    dbg_misd_ack   : out std_logic_vector(CORES_PER_MISD-1 downto 0);
    dbg_misd_bp    : out std_logic_vector(CORES_PER_MISD-1 downto 0);

    dbg_simd_stall : in  std_logic_vector(CORES_PER_SIMD-1 downto 0);
    dbg_simd_strb  : in  std_logic_vector(CORES_PER_SIMD-1 downto 0);
    dbg_simd_we    : in  std_logic_vector(CORES_PER_SIMD-1 downto 0);
    dbg_simd_addr  : in  M_CORES_PER_SIMD_PLEN;
    dbg_simd_dati  : in  M_CORES_PER_SIMD_XLEN;
    dbg_simd_dato  : out M_CORES_PER_SIMD_XLEN;
    dbg_simd_ack   : out std_logic_vector(CORES_PER_SIMD-1 downto 0);
    dbg_simd_bp    : out std_logic_vector(CORES_PER_SIMD-1 downto 0);

    --GPIO Interface
    gpio_misd_i  : in  M_CORES_PER_MISD_PDATA_SIZE;
    gpio_misd_o  : out M_CORES_PER_MISD_PDATA_SIZE;
    gpio_misd_oe : out M_CORES_PER_MISD_PDATA_SIZE;

    gpio_simd_i  : in  M_CORES_PER_SIMD_PDATA_SIZE;
    gpio_simd_o  : out M_CORES_PER_SIMD_PDATA_SIZE;
    gpio_simd_oe : out M_CORES_PER_SIMD_PDATA_SIZE;

    --NoC Interface
    noc_misd_in_flit   : in  M_CHANNELS_FLIT_WIDTH;
    noc_misd_in_last   : in  std_logic_vector(CHANNELS-1 downto 0);
    noc_misd_in_valid  : in  std_logic_vector(CHANNELS-1 downto 0);
    noc_misd_in_ready  : out std_logic_vector(CHANNELS-1 downto 0);
    noc_misd_out_flit  : out M_CHANNELS_FLIT_WIDTH;
    noc_misd_out_last  : out std_logic_vector(CHANNELS-1 downto 0);
    noc_misd_out_valid : out std_logic_vector(CHANNELS-1 downto 0);
    noc_misd_out_ready : in  std_logic_vector(CHANNELS-1 downto 0);

    noc_simd_in_flit   : in  M_CHANNELS_FLIT_WIDTH;
    noc_simd_in_last   : in  std_logic_vector(CHANNELS-1 downto 0);
    noc_simd_in_valid  : in  std_logic_vector(CHANNELS-1 downto 0);
    noc_simd_in_ready  : out std_logic_vector(CHANNELS-1 downto 0);
    noc_simd_out_flit  : out M_CHANNELS_FLIT_WIDTH;
    noc_simd_out_last  : out std_logic_vector(CHANNELS-1 downto 0);
    noc_simd_out_valid : out std_logic_vector(CHANNELS-1 downto 0);
    noc_simd_out_ready : in  std_logic_vector(CHANNELS-1 downto 0)
    );
end riscv_soc;

architecture RTL of riscv_soc is
  component riscv_misd
    generic (
      XLEN : integer := 64;
      PLEN : integer := 64;

      PC_INIT : std_logic_vector(63 downto 0) := X"0000000080000000";

      HAS_USER  : std_logic := '1';
      HAS_SUPER : std_logic := '1';
      HAS_HYPER : std_logic := '1';
      HAS_BPU   : std_logic := '1';
      HAS_FPU   : std_logic := '1';
      HAS_MMU   : std_logic := '1';
      HAS_RVM   : std_logic := '1';
      HAS_RVA   : std_logic := '1';
      HAS_RVC   : std_logic := '1';

      IS_RV32E : std_logic := '1';

      MULT_LATENCY : std_logic := '1';

      BREAKPOINTS : integer := 8;       --Number of hardware breakpoints

      PMA_CNT : integer := 16;
      PMP_CNT : integer := 16;  --Number of Physical Memory Protection entries

      BP_GLOBAL_BITS : integer := 2;
      BP_LOCAL_BITS  : integer := 10;

      ICACHE_SIZE        : integer := 0;   --in KBytes
      ICACHE_BLOCK_SIZE  : integer := 32;  --in Bytes
      ICACHE_WAYS        : integer := 2;   --'n'-way set associative
      ICACHE_REPLACE_ALG : integer := 0;
      ITCM_SIZE          : integer := 0;

      DCACHE_SIZE        : integer := 0;   --in KBytes
      DCACHE_BLOCK_SIZE  : integer := 32;  --in Bytes
      DCACHE_WAYS        : integer := 2;   --'n'-way set associative
      DCACHE_REPLACE_ALG : integer := 0;
      DTCM_SIZE          : integer := 0;

      WRITEBUFFER_SIZE : integer := 8;

      TECHNOLOGY : string := "GENERIC";

      MNMIVEC_DEFAULT : std_logic_vector(63 downto 0) := X"0000000000000004";
      MTVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"0000000000000040";
      HTVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"0000000000000080";
      STVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"00000000000000C0";
      UTVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"0000000000000100";

      JEDEC_BANK : integer := 10;

      JEDEC_MANUFACTURER_ID : std_logic_vector(7 downto 0) := X"6E";

      HARTID : integer := 0;

      PARCEL_SIZE : integer := 32;

      HADDR_SIZE : integer := 64;
      HDATA_SIZE : integer := 64;
      PADDR_SIZE : integer := 64;
      PDATA_SIZE : integer := 64;

      FLIT_WIDTH : integer := 34;

      SYNC_DEPTH : integer := 3;

      CORES_PER_MISD : integer := 8;

      CHANNELS : integer := 2
      );
    port (
      --Common signals
      HRESETn : in std_logic;
      HCLK    : in std_logic;

      --PMA configuration
      pma_cfg_i : in M_PMA_CNT_13;
      pma_adr_i : in M_PMA_CNT_PLEN;

      --AHB instruction
      ins_HSEL      : out std_logic_vector(CORES_PER_MISD-1 downto 0);
      ins_HADDR     : out M_CORES_PER_MISD_PLEN;
      ins_HWDATA    : out M_CORES_PER_MISD_XLEN;
      ins_HRDATA    : in  M_CORES_PER_MISD_XLEN;
      ins_HWRITE    : out std_logic_vector(CORES_PER_MISD-1 downto 0);
      ins_HSIZE     : out M_CORES_PER_MISD_2;
      ins_HBURST    : out M_CORES_PER_MISD_2;
      ins_HPROT     : out M_CORES_PER_MISD_3;
      ins_HTRANS    : out M_CORES_PER_MISD_1;
      ins_HMASTLOCK : out std_logic_vector(CORES_PER_MISD-1 downto 0);
      ins_HREADY    : in  std_logic_vector(CORES_PER_MISD-1 downto 0);
      ins_HRESP     : in  std_logic_vector(CORES_PER_MISD-1 downto 0);

      --AHB data
      dat_HSEL      : out std_logic;
      dat_HADDR     : out std_logic_vector(PLEN-1 downto 0);
      dat_HWDATA    : out std_logic_vector(XLEN-1 downto 0);
      dat_HRDATA    : in  std_logic_vector(XLEN-1 downto 0);
      dat_HWRITE    : out std_logic;
      dat_HSIZE     : out std_logic_vector(2 downto 0);
      dat_HBURST    : out std_logic_vector(2 downto 0);
      dat_HPROT     : out std_logic_vector(3 downto 0);
      dat_HTRANS    : out std_logic_vector(1 downto 0);
      dat_HMASTLOCK : out std_logic;
      dat_HREADY    : in  std_logic;
      dat_HRESP     : in  std_logic;

      --Interrupts Interface
      ext_nmi  : in std_logic_vector(CORES_PER_MISD-1 downto 0);
      ext_tint : in std_logic_vector(CORES_PER_MISD-1 downto 0);
      ext_sint : in std_logic_vector(CORES_PER_MISD-1 downto 0);
      ext_int  : in M_CORES_PER_MISD_3;

      --Debug Interface
      dbg_stall : in  std_logic_vector(CORES_PER_MISD-1 downto 0);
      dbg_strb  : in  std_logic_vector(CORES_PER_MISD-1 downto 0);
      dbg_we    : in  std_logic_vector(CORES_PER_MISD-1 downto 0);
      dbg_addr  : in  M_CORES_PER_MISD_PLEN;
      dbg_dati  : in  M_CORES_PER_MISD_XLEN;
      dbg_dato  : out M_CORES_PER_MISD_XLEN;
      dbg_ack   : out std_logic_vector(CORES_PER_MISD-1 downto 0);
      dbg_bp    : out std_logic_vector(CORES_PER_MISD-1 downto 0);

      --GPIO Interface
      gpio_i  : in  M_CORES_PER_MISD_PDATA_SIZE;
      gpio_o  : out M_CORES_PER_MISD_PDATA_SIZE;
      gpio_oe : out M_CORES_PER_MISD_PDATA_SIZE;

      --NoC Interface
      noc_in_flit  : in  M_CHANNELS_FLIT_WIDTH;
      noc_in_last  : in  std_logic_vector(CHANNELS-1 downto 0);
      noc_in_valid : in  std_logic_vector(CHANNELS-1 downto 0);
      noc_in_ready : out std_logic_vector(CHANNELS-1 downto 0);

      noc_out_flit  : out M_CHANNELS_FLIT_WIDTH;
      noc_out_last  : out std_logic_vector(CHANNELS-1 downto 0);
      noc_out_valid : out std_logic_vector(CHANNELS-1 downto 0);
      noc_out_ready : in  std_logic_vector(CHANNELS-1 downto 0)
      );
  end component;

  component riscv_simd
    generic (
      XLEN : integer := 64;
      PLEN : integer := 64;

      PC_INIT : std_logic_vector(63 downto 0) := X"0000000080000000";

      HAS_USER  : std_logic := '1';
      HAS_SUPER : std_logic := '1';
      HAS_HYPER : std_logic := '1';
      HAS_BPU   : std_logic := '1';
      HAS_FPU   : std_logic := '1';
      HAS_MMU   : std_logic := '1';
      HAS_RVM   : std_logic := '1';
      HAS_RVA   : std_logic := '1';
      HAS_RVC   : std_logic := '1';

      IS_RV32E : std_logic := '1';

      MULT_LATENCY : std_logic := '1';

      BREAKPOINTS : integer := 8;       --Number of hardware breakpoints

      PMA_CNT : integer := 16;
      PMP_CNT : integer := 16;  --Number of Physical Memory Protection entries

      BP_GLOBAL_BITS : integer := 2;
      BP_LOCAL_BITS  : integer := 10;

      ICACHE_SIZE        : integer := 0;   --in KBytes
      ICACHE_BLOCK_SIZE  : integer := 32;  --in Bytes
      ICACHE_WAYS        : integer := 2;   --'n'-way set associative
      ICACHE_REPLACE_ALG : integer := 0;
      ITCM_SIZE          : integer := 0;

      DCACHE_SIZE        : integer := 0;   --in KBytes
      DCACHE_BLOCK_SIZE  : integer := 32;  --in Bytes
      DCACHE_WAYS        : integer := 2;   --'n'-way set associative
      DCACHE_REPLACE_ALG : integer := 0;
      DTCM_SIZE          : integer := 0;

      WRITEBUFFER_SIZE : integer := 8;

      TECHNOLOGY : string := "GENERIC";

      MNMIVEC_DEFAULT : std_logic_vector(63 downto 0) := X"0000000000000004";
      MTVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"0000000000000040";
      HTVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"0000000000000080";
      STVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"00000000000000C0";
      UTVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"0000000000000100";

      JEDEC_BANK : integer := 10;

      JEDEC_MANUFACTURER_ID : std_logic_vector(7 downto 0) := X"6E";

      HARTID : integer := 0;

      PARCEL_SIZE : integer := 32;

      HADDR_SIZE : integer := 64;
      HDATA_SIZE : integer := 64;
      PADDR_SIZE : integer := 64;
      PDATA_SIZE : integer := 64;

      FLIT_WIDTH : integer := 34;

      SYNC_DEPTH : integer := 3;

      CORES_PER_SIMD : integer := 8;

      CHANNELS : integer := 2
      );
    port (
      --Common signals
      HRESETn : in std_logic;
      HCLK    : in std_logic;

      --PMA configuration
      pma_cfg_i : in M_PMA_CNT_13;
      pma_adr_i : in M_PMA_CNT_PLEN;

      --AHB instruction
      ins_HSEL      : out std_logic;
      ins_HADDR     : out std_logic_vector(PLEN-1 downto 0);
      ins_HWDATA    : out std_logic_vector(XLEN-1 downto 0);
      ins_HRDATA    : in  std_logic_vector(XLEN-1 downto 0);
      ins_HWRITE    : out std_logic;
      ins_HSIZE     : out std_logic_vector(2 downto 0);
      ins_HBURST    : out std_logic_vector(2 downto 0);
      ins_HPROT     : out std_logic_vector(3 downto 0);
      ins_HTRANS    : out std_logic_vector(1 downto 0);
      ins_HMASTLOCK : out std_logic;
      ins_HREADY    : in  std_logic;
      ins_HRESP     : in  std_logic;

      --AHB data
      dat_HSEL      : out std_logic_vector(CORES_PER_SIMD-1 downto 0);
      dat_HADDR     : out M_CORES_PER_SIMD_PLEN;
      dat_HWDATA    : out M_CORES_PER_SIMD_XLEN;
      dat_HRDATA    : in  M_CORES_PER_SIMD_XLEN;
      dat_HWRITE    : out std_logic_vector(CORES_PER_SIMD-1 downto 0);
      dat_HSIZE     : out M_CORES_PER_SIMD_2;
      dat_HBURST    : out M_CORES_PER_SIMD_2;
      dat_HPROT     : out M_CORES_PER_SIMD_3;
      dat_HTRANS    : out M_CORES_PER_SIMD_1;
      dat_HMASTLOCK : out std_logic_vector(CORES_PER_SIMD-1 downto 0);
      dat_HREADY    : in  std_logic_vector(CORES_PER_SIMD-1 downto 0);
      dat_HRESP     : in  std_logic_vector(CORES_PER_SIMD-1 downto 0);

      --Interrupts Interface
      ext_nmi  : in std_logic_vector(CORES_PER_SIMD-1 downto 0);
      ext_tint : in std_logic_vector(CORES_PER_SIMD-1 downto 0);
      ext_sint : in std_logic_vector(CORES_PER_SIMD-1 downto 0);
      ext_int  : in M_CORES_PER_SIMD_3;

      --Debug Interface
      dbg_stall : in  std_logic_vector(CORES_PER_SIMD-1 downto 0);
      dbg_strb  : in  std_logic_vector(CORES_PER_SIMD-1 downto 0);
      dbg_we    : in  std_logic_vector(CORES_PER_SIMD-1 downto 0);
      dbg_addr  : in  M_CORES_PER_SIMD_PLEN;
      dbg_dati  : in  M_CORES_PER_SIMD_XLEN;
      dbg_dato  : out M_CORES_PER_SIMD_XLEN;
      dbg_ack   : out std_logic_vector(CORES_PER_SIMD-1 downto 0);
      dbg_bp    : out std_logic_vector(CORES_PER_SIMD-1 downto 0);

      --GPIO Interface
      gpio_i  : in  M_CORES_PER_SIMD_PDATA_SIZE;
      gpio_o  : out M_CORES_PER_SIMD_PDATA_SIZE;
      gpio_oe : out M_CORES_PER_SIMD_PDATA_SIZE;

      --NoC Interface
      noc_in_flit  : in  M_CHANNELS_FLIT_WIDTH;
      noc_in_last  : in  std_logic_vector(CHANNELS-1 downto 0);
      noc_in_valid : in  std_logic_vector(CHANNELS-1 downto 0);
      noc_in_ready : out std_logic_vector(CHANNELS-1 downto 0);

      noc_out_flit  : out M_CHANNELS_FLIT_WIDTH;
      noc_out_last  : out std_logic_vector(CHANNELS-1 downto 0);
      noc_out_valid : out std_logic_vector(CHANNELS-1 downto 0);
      noc_out_ready : in  std_logic_vector(CHANNELS-1 downto 0)
      );
  end component;

begin
  --//////////////////////////////////////////////////////////////
  --
  -- Module Body
  --

  --Instantiate RISC-V MISD
  generating_0 : if (CORES_PER_MISD > 0) generate
    misd_soc : riscv_misd
      generic map (
        XLEN => XLEN,
        PLEN => PLEN,

        PC_INIT => PC_INIT,

        HAS_USER  => HAS_USER,
        HAS_SUPER => HAS_SUPER,
        HAS_HYPER => HAS_HYPER,
        HAS_BPU   => HAS_BPU,
        HAS_FPU   => HAS_FPU,
        HAS_MMU   => HAS_MMU,
        HAS_RVM   => HAS_RVM,
        HAS_RVA   => HAS_RVA,
        HAS_RVC   => HAS_RVC,

        IS_RV32E => IS_RV32E,

        MULT_LATENCY => MULT_LATENCY,

        BREAKPOINTS => BREAKPOINTS,

        PMA_CNT => PMA_CNT,
        PMP_CNT => PMP_CNT,

        BP_GLOBAL_BITS => BP_GLOBAL_BITS,
        BP_LOCAL_BITS  => BP_LOCAL_BITS,

        ICACHE_SIZE        => ICACHE_SIZE,
        ICACHE_BLOCK_SIZE  => ICACHE_BLOCK_SIZE,
        ICACHE_WAYS        => ICACHE_WAYS,
        ICACHE_REPLACE_ALG => ICACHE_REPLACE_ALG,
        ITCM_SIZE          => ITCM_SIZE,

        DCACHE_SIZE        => DCACHE_SIZE,
        DCACHE_BLOCK_SIZE  => DCACHE_BLOCK_SIZE,
        DCACHE_WAYS        => DCACHE_WAYS,
        DCACHE_REPLACE_ALG => DCACHE_REPLACE_ALG,
        DTCM_SIZE          => DTCM_SIZE,

        WRITEBUFFER_SIZE => WRITEBUFFER_SIZE,

        TECHNOLOGY => TECHNOLOGY,

        MNMIVEC_DEFAULT => MNMIVEC_DEFAULT,
        MTVEC_DEFAULT   => MTVEC_DEFAULT,
        HTVEC_DEFAULT   => HTVEC_DEFAULT,
        STVEC_DEFAULT   => STVEC_DEFAULT,
        UTVEC_DEFAULT   => UTVEC_DEFAULT,

        JEDEC_BANK => JEDEC_BANK,

        JEDEC_MANUFACTURER_ID => JEDEC_MANUFACTURER_ID,

        HARTID => HARTID,

        HADDR_SIZE => HADDR_SIZE,
        HDATA_SIZE => HDATA_SIZE,
        PADDR_SIZE => PADDR_SIZE,
        PDATA_SIZE => PDATA_SIZE,

        SYNC_DEPTH => SYNC_DEPTH,

        CORES_PER_MISD => CORES_PER_MISD,

        CHANNELS => CHANNELS
        )
      port map (
        --Common signals
        HRESETn => HRESETn,
        HCLK    => HCLK,

        --PMA configuration
        pma_cfg_i => pma_cfg_i,
        pma_adr_i => pma_adr_i,

        --AHB Instruction
        ins_HSEL      => mins_misd_HSEL,
        ins_HADDR     => mins_misd_HADDR,
        ins_HWDATA    => mins_misd_HWDATA,
        ins_HRDATA    => mins_misd_HRDATA,
        ins_HWRITE    => mins_misd_HWRITE,
        ins_HSIZE     => mins_misd_HSIZE,
        ins_HBURST    => mins_misd_HBURST,
        ins_HPROT     => mins_misd_HPROT,
        ins_HTRANS    => mins_misd_HTRANS,
        ins_HMASTLOCK => mins_misd_HMASTLOCK,
        ins_HREADY    => mins_misd_HREADY,
        ins_HRESP     => mins_misd_HRESP,

        --AHB Data
        dat_HSEL      => sdat_misd_HSEL,
        dat_HADDR     => sdat_misd_HADDR,
        dat_HWDATA    => sdat_misd_HWDATA,
        dat_HRDATA    => sdat_misd_HRDATA,
        dat_HWRITE    => sdat_misd_HWRITE,
        dat_HSIZE     => sdat_misd_HSIZE,
        dat_HBURST    => sdat_misd_HBURST,
        dat_HPROT     => sdat_misd_HPROT,
        dat_HTRANS    => sdat_misd_HTRANS,
        dat_HMASTLOCK => sdat_misd_HMASTLOCK,
        dat_HREADY    => sdat_misd_HREADY,
        dat_HRESP     => sdat_misd_HRESP,

        --Interrupts Interface
        ext_nmi  => ext_misd_nmi,
        ext_tint => ext_misd_tint,
        ext_sint => ext_misd_sint,
        ext_int  => ext_misd_int,

        --Debug Interface
        dbg_stall => dbg_misd_stall,
        dbg_strb  => dbg_misd_strb,
        dbg_we    => dbg_misd_we,
        dbg_addr  => dbg_misd_addr,
        dbg_dati  => dbg_misd_dati,
        dbg_dato  => dbg_misd_dato,
        dbg_ack   => dbg_misd_ack,
        dbg_bp    => dbg_misd_bp,

        --GPIO Interface
        gpio_i  => gpio_misd_i,
        gpio_o  => gpio_misd_o,
        gpio_oe => gpio_misd_oe,

        --NoC Interface
        noc_in_flit   => noc_misd_in_flit,
        noc_in_last   => noc_misd_in_last,
        noc_in_valid  => noc_misd_in_valid,
        noc_in_ready  => noc_misd_in_ready,
        noc_out_flit  => noc_misd_out_flit,
        noc_out_last  => noc_misd_out_last,
        noc_out_valid => noc_misd_out_valid,
        noc_out_ready => noc_misd_out_ready
        );
  end generate;

  --Instantiate RISC-V SIMD
  generating_1 : if (CORES_PER_SIMD > 0) generate
    simd_soc : riscv_simd
      generic map (
        XLEN => XLEN,
        PLEN => PLEN,

        PC_INIT => PC_INIT,

        HAS_USER  => HAS_USER,
        HAS_SUPER => HAS_SUPER,
        HAS_HYPER => HAS_HYPER,
        HAS_BPU   => HAS_BPU,
        HAS_FPU   => HAS_FPU,
        HAS_MMU   => HAS_MMU,
        HAS_RVM   => HAS_RVM,
        HAS_RVA   => HAS_RVA,
        HAS_RVC   => HAS_RVC,

        IS_RV32E => IS_RV32E,

        MULT_LATENCY => MULT_LATENCY,

        BREAKPOINTS => BREAKPOINTS,

        PMA_CNT => PMA_CNT,
        PMP_CNT => PMP_CNT,

        BP_GLOBAL_BITS => BP_GLOBAL_BITS,
        BP_LOCAL_BITS  => BP_LOCAL_BITS,

        ICACHE_SIZE        => ICACHE_SIZE,
        ICACHE_BLOCK_SIZE  => ICACHE_BLOCK_SIZE,
        ICACHE_WAYS        => ICACHE_WAYS,
        ICACHE_REPLACE_ALG => ICACHE_REPLACE_ALG,
        ITCM_SIZE          => ITCM_SIZE,

        DCACHE_SIZE        => DCACHE_SIZE,
        DCACHE_BLOCK_SIZE  => DCACHE_BLOCK_SIZE,
        DCACHE_WAYS        => DCACHE_WAYS,
        DCACHE_REPLACE_ALG => DCACHE_REPLACE_ALG,
        DTCM_SIZE          => DTCM_SIZE,

        WRITEBUFFER_SIZE => WRITEBUFFER_SIZE,

        TECHNOLOGY => TECHNOLOGY,

        MNMIVEC_DEFAULT => MNMIVEC_DEFAULT,
        MTVEC_DEFAULT   => MTVEC_DEFAULT,
        HTVEC_DEFAULT   => HTVEC_DEFAULT,
        STVEC_DEFAULT   => STVEC_DEFAULT,
        UTVEC_DEFAULT   => UTVEC_DEFAULT,

        JEDEC_BANK => JEDEC_BANK,

        JEDEC_MANUFACTURER_ID => JEDEC_MANUFACTURER_ID,

        HARTID => HARTID,

        HADDR_SIZE => HADDR_SIZE,
        HDATA_SIZE => HDATA_SIZE,
        PADDR_SIZE => PADDR_SIZE,
        PDATA_SIZE => PDATA_SIZE,

        SYNC_DEPTH => SYNC_DEPTH,

        CORES_PER_SIMD => CORES_PER_SIMD,

        CHANNELS => CHANNELS
        )
      port map (
        --Common signals
        HRESETn => HRESETn,
        HCLK    => HCLK,

        --PMA configuration
        pma_cfg_i => pma_cfg_i,
        pma_adr_i => pma_adr_i,

        --AHB Instruction
        ins_HSEL      => sins_simd_HSEL,
        ins_HADDR     => sins_simd_HADDR,
        ins_HWDATA    => sins_simd_HWDATA,
        ins_HRDATA    => sins_simd_HRDATA,
        ins_HWRITE    => sins_simd_HWRITE,
        ins_HSIZE     => sins_simd_HSIZE,
        ins_HBURST    => sins_simd_HBURST,
        ins_HPROT     => sins_simd_HPROT,
        ins_HTRANS    => sins_simd_HTRANS,
        ins_HMASTLOCK => sins_simd_HMASTLOCK,
        ins_HREADY    => sins_simd_HREADY,
        ins_HRESP     => sins_simd_HRESP,

        --AHB Data
        dat_HSEL      => mdat_simd_HSEL,
        dat_HADDR     => mdat_simd_HADDR,
        dat_HWDATA    => mdat_simd_HWDATA,
        dat_HRDATA    => mdat_simd_HRDATA,
        dat_HWRITE    => mdat_simd_HWRITE,
        dat_HSIZE     => mdat_simd_HSIZE,
        dat_HBURST    => mdat_simd_HBURST,
        dat_HPROT     => mdat_simd_HPROT,
        dat_HTRANS    => mdat_simd_HTRANS,
        dat_HMASTLOCK => mdat_simd_HMASTLOCK,
        dat_HREADY    => mdat_simd_HREADY,
        dat_HRESP     => mdat_simd_HRESP,

        --Interrupts Interface
        ext_nmi  => ext_simd_nmi,
        ext_tint => ext_simd_tint,
        ext_sint => ext_simd_sint,
        ext_int  => ext_simd_int,

        --Debug Interface
        dbg_stall => dbg_simd_stall,
        dbg_strb  => dbg_simd_strb,
        dbg_we    => dbg_simd_we,
        dbg_addr  => dbg_simd_addr,
        dbg_dati  => dbg_simd_dati,
        dbg_dato  => dbg_simd_dato,
        dbg_ack   => dbg_simd_ack,
        dbg_bp    => dbg_simd_bp,

        --GPIO Interface
        gpio_i  => gpio_simd_i,
        gpio_o  => gpio_simd_o,
        gpio_oe => gpio_simd_oe,

        --NoC Interface
        noc_in_flit   => noc_simd_in_flit,
        noc_in_last   => noc_simd_in_last,
        noc_in_valid  => noc_simd_in_valid,
        noc_in_ready  => noc_simd_in_ready,
        noc_out_flit  => noc_simd_out_flit,
        noc_out_last  => noc_simd_out_last,
        noc_out_valid => noc_simd_out_valid,
        noc_out_ready => noc_simd_out_ready
        );
  end generate;
end RTL;
