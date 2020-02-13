-- Converted from riscv_simd.sv
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
--              Multiple Instruction Single Data                              //
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
use ieee.math_real.all;

use work.riscv_mpsoc_pkg.all;
use work.mpsoc_msi_pkg.all;

entity riscv_simd is
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

    BREAKPOINTS : integer := 8;  --Number of hardware breakpoints

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
end riscv_simd;

architecture RTL of riscv_simd is
  component riscv_pu
    generic (
      XLEN : integer := 64;
      PLEN : integer := 64;

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

      PMA_CNT : integer := 4;
      PMP_CNT : integer := 16;  --Number of Physical Memory Protection entries

      BP_GLOBAL_BITS    : integer := 2;
      BP_LOCAL_BITS     : integer := 10;
      BP_LOCAL_BITS_LSB : integer := 2;

      ICACHE_SIZE        : integer := 64;  --in KBytes
      ICACHE_BLOCK_SIZE  : integer := 64;  --in Bytes
      ICACHE_WAYS        : integer := 2;   --'n'-way set associative
      ICACHE_REPLACE_ALG : integer := 0;
      ITCM_SIZE          : integer := 0;

      DCACHE_SIZE        : integer := 64;  --in KBytes
      DCACHE_BLOCK_SIZE  : integer := 64;  --in Bytes
      DCACHE_WAYS        : integer := 2;   --'n'-way set associative
      DCACHE_REPLACE_ALG : integer := 0;
      DTCM_SIZE          : integer := 0;

      WRITEBUFFER_SIZE : integer := 8;

      TECHNOLOGY : string := "GENERIC";

      PC_INIT : std_logic_vector(63 downto 0) := X"0000000080000000";

      MNMIVEC_DEFAULT : std_logic_vector(63 downto 0) := X"0000000000000004";
      MTVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"0000000000000040";
      HTVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"0000000000000080";
      STVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"00000000000000C0";
      UTVEC_DEFAULT   : std_logic_vector(63 downto 0) := X"0000000000000100";

      JEDEC_BANK : integer := 10;

      JEDEC_MANUFACTURER_ID : std_logic_vector(7 downto 0) := X"6E";

      HARTID : integer := 0;

      PARCEL_SIZE : integer := 64
    );
    port (
      --AHB interfaces
      HRESETn : in std_logic;
      HCLK    : in std_logic;

      pma_cfg_i : M_PMA_CNT_13;
      pma_adr_i : M_PMA_CNT_PLEN;

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

      --Interrupts
      ext_nmi  : in std_logic;
      ext_tint : in std_logic;
      ext_sint : in std_logic;
      ext_int  : in std_logic_vector(3 downto 0);

      --Debug Interface
      dbg_stall : in  std_logic;
      dbg_strb  : in  std_logic;
      dbg_we    : in  std_logic;
      dbg_addr  : in  std_logic_vector(PLEN-1 downto 0);
      dbg_dati  : in  std_logic_vector(XLEN-1 downto 0);
      dbg_dato  : out std_logic_vector(XLEN-1 downto 0);
      dbg_ack   : out std_logic;
      dbg_bp    : out std_logic
    );
  end component;

  component mpsoc_msi_interface
    generic (
      PLEN    : integer := 64;
      XLEN    : integer := 64;
      MASTERS : integer := 3;
      SLAVES  : integer := 8
    );
    port (
      --Common signals
      HRESETn : in std_logic;
      HCLK    : in std_logic;

      --Master Ports; AHB masters connect to these
      -- thus these are actually AHB Slave Interfaces
      mst_priority : in M_MASTERS_2;

      mst_HSEL      : in  std_logic_vector(MASTERS-1 downto 0);
      mst_HADDR     : in  M_MASTERS_PLEN;
      mst_HWDATA    : in  M_MASTERS_XLEN;
      mst_HRDATA    : out M_MASTERS_XLEN;
      mst_HWRITE    : in  std_logic_vector(MASTERS-1 downto 0);
      mst_HSIZE     : in  M_MASTERS_2;
      mst_HBURST    : in  M_MASTERS_2;
      mst_HPROT     : in  M_MASTERS_3;
      mst_HTRANS    : in  M_MASTERS_1;
      mst_HMASTLOCK : in  std_logic_vector(MASTERS-1 downto 0);
      mst_HREADYOUT : out std_logic_vector(MASTERS-1 downto 0);
      mst_HREADY    : in  std_logic_vector(MASTERS-1 downto 0);
      mst_HRESP     : out std_logic_vector(MASTERS-1 downto 0);

      --Slave Ports; AHB Slaves connect to these
      --  thus these are actually AHB Master Interfaces
      slv_addr_mask : in M_SLAVES_PLEN;
      slv_addr_base : in M_SLAVES_PLEN;

      slv_HSEL      : out std_logic_vector(SLAVES-1 downto 0);
      slv_HADDR     : out M_SLAVES_PLEN;
      slv_HWDATA    : out M_SLAVES_XLEN;
      slv_HRDATA    : in  M_SLAVES_XLEN;
      slv_HWRITE    : out std_logic_vector(SLAVES-1 downto 0);
      slv_HSIZE     : out M_SLAVES_2;
      slv_HBURST    : out M_SLAVES_2;
      slv_HPROT     : out M_SLAVES_3;
      slv_HTRANS    : out M_SLAVES_1;
      slv_HMASTLOCK : out std_logic_vector(SLAVES-1 downto 0);
      slv_HREADYOUT : out std_logic_vector(SLAVES-1 downto 0);  --HREADYOUT to slave-decoder; generates HREADY to all connected slaves
      slv_HREADY    : in  std_logic_vector(SLAVES-1 downto 0);  --combinatorial HREADY from all connected slaves
      slv_HRESP     : in  std_logic_vector(SLAVES-1 downto 0)
    );
  end component;

  component mpsoc_dma_ahb3_top
    generic (
      ADDR_WIDTH             : integer := 32;
      DATA_WIDTH             : integer := 32;
      TABLE_ENTRIES          : integer := 4;
      TABLE_ENTRIES_PTRWIDTH : integer := integer(log2(real(4)));
      TILEID                 : integer := 0;
      NOC_PACKET_SIZE        : integer := 16;
      GENERATE_INTERRUPT     : integer := 1
    );
    port (
      clk : in std_logic;
      rst : in std_logic;

      noc_in_req_flit  : in  std_logic_vector(FLIT_WIDTH-1 downto 0);
      noc_in_req_valid : in  std_logic;
      noc_in_req_ready : out std_logic;

      noc_in_res_flit  : in  std_logic_vector(FLIT_WIDTH-1 downto 0);
      noc_in_res_valid : in  std_logic;
      noc_in_res_ready : out std_logic;

      noc_out_req_flit  : out std_logic_vector(FLIT_WIDTH-1 downto 0);
      noc_out_req_valid : out std_logic;
      noc_out_req_ready : in  std_logic;

      noc_out_res_flit  : out std_logic_vector(FLIT_WIDTH-1 downto 0);
      noc_out_res_valid : out std_logic;
      noc_out_res_ready : in  std_logic;

      ahb3_if_haddr     : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      ahb3_if_hrdata    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      ahb3_if_hmastlock : in  std_logic;
      ahb3_if_hsel      : in  std_logic;
      ahb3_if_hwrite    : in  std_logic;
      ahb3_if_hwdata    : out std_logic_vector(DATA_WIDTH-1 downto 0);
      ahb3_if_hready    : out std_logic;
      ahb3_if_hresp     : out std_logic;

      ahb3_haddr     : out std_logic_vector(ADDR_WIDTH-1 downto 0);
      ahb3_hwdata    : out std_logic_vector(DATA_WIDTH-1 downto 0);
      ahb3_hmastlock : out std_logic;
      ahb3_hsel      : out std_logic;
      ahb3_hprot     : out std_logic_vector(3 downto 0);
      ahb3_hwrite    : out std_logic;
      ahb3_hsize     : out std_logic_vector(2 downto 0);
      ahb3_hburst    : out std_logic_vector(2 downto 0);
      ahb3_htrans    : out std_logic_vector(1 downto 0);
      ahb3_hrdata    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      ahb3_hready    : in  std_logic;

      irq : out std_logic_vector(TABLE_ENTRIES-1 downto 0)
    );
  end component;

  component mpsoc_noc_buffer
    generic (
      FLIT_WIDTH : integer := 34;
      DEPTH      : integer := 16;
      FULLPACKET : integer := 0
    );
    port (
      -- the width of the index
      clk : in std_logic;
      rst : in std_logic;

      --FIFO input side
      in_flit  : in  std_logic_vector(FLIT_WIDTH-1 downto 0);
      in_last  : in  std_logic;
      in_valid : in  std_logic;
      in_ready : out std_logic;

      --FIFO output side
      out_flit  : out std_logic_vector(FLIT_WIDTH-1 downto 0);
      out_last  : out std_logic;
      out_valid : out std_logic;
      out_ready : in  std_logic;

      packet_size : out std_logic_vector(integer(log2(real(DEPTH))) downto 0)
    );
  end component;

  component mpsoc_noc_mux
    generic (
      FLIT_WIDTH : integer := 34;
      CHANNELS   : integer := 7
    );
    port (
      clk : in std_logic;
      rst : in std_logic;

      in_flit  : in  M_CHANNELS_FLIT_WIDTH;
      in_last  : in  std_logic_vector(CHANNELS-1 downto 0);
      in_valid : in  std_logic_vector(CHANNELS-1 downto 0);
      in_ready : out std_logic_vector(CHANNELS-1 downto 0);

      out_flit  : out std_logic_vector(FLIT_WIDTH-1 downto 0);
      out_last  : out std_logic;
      out_valid : out std_logic;
      out_ready : in  std_logic
    );
  end component;

  component mpsoc_noc_demux
    generic (
      FLIT_WIDTH : integer := 34;
      CHANNELS   : integer := 7;

      MAPPING : std_logic_vector(63 downto 0) := (others => 'X')
    );
    port (
      clk : in std_logic;
      rst : in std_logic;

      in_flit  : in  std_logic_vector(FLIT_WIDTH-1 downto 0);
      in_last  : in  std_logic;
      in_valid : in  std_logic;
      in_ready : out std_logic;

      out_flit  : out M_CHANNELS_FLIT_WIDTH;
      out_last  : out std_logic_vector(CHANNELS-1 downto 0);
      out_valid : out std_logic_vector(CHANNELS-1 downto 0);
      out_ready : in  std_logic_vector(CHANNELS-1 downto 0)
    );
  end component;

  component mpsoc_peripheral_bridge
    generic (
      HADDR_SIZE : integer := 32;
      HDATA_SIZE : integer := 32;
      PADDR_SIZE : integer := 10;
      PDATA_SIZE : integer := 8;
      SYNC_DEPTH : integer := 3
    );
    port (
      --AHB Slave Interface
      HRESETn   : in  std_logic;
      HCLK      : in  std_logic;
      HSEL      : in  std_logic;
      HADDR     : in  std_logic_vector(HADDR_SIZE-1 downto 0);
      HWDATA    : in  std_logic_vector(HDATA_SIZE-1 downto 0);
      HRDATA    : out std_logic_vector(HDATA_SIZE-1 downto 0);
      HWRITE    : in  std_logic;
      HSIZE     : in  std_logic_vector(2 downto 0);
      HBURST    : in  std_logic_vector(2 downto 0);
      HPROT     : in  std_logic_vector(3 downto 0);
      HTRANS    : in  std_logic_vector(1 downto 0);
      HMASTLOCK : in  std_logic;
      HREADYOUT : out std_logic;
      HREADY    : in  std_logic;
      HRESP     : out std_logic;

      --APB Master Interface
      PRESETn : in  std_logic;
      PCLK    : in  std_logic;
      PSEL    : out std_logic;
      PENABLE : out std_logic;
      PPROT   : out std_logic_vector(2 downto 0);
      PWRITE  : out std_logic;
      PSTRB   : out std_logic;
      PADDR   : out std_logic_vector(PADDR_SIZE-1 downto 0);
      PWDATA  : out std_logic_vector(PDATA_SIZE-1 downto 0);
      PRDATA  : in  std_logic_vector(PDATA_SIZE-1 downto 0);
      PREADY  : in  std_logic;
      PSLVERR : in  std_logic
    );
  end component;

  component mpsoc_gpio
    generic (
      PADDR_SIZE : integer := 64;
      PDATA_SIZE : integer := 64
    );
    port (
      PRESETn : in std_logic;
      PCLK    : in std_logic;

      PSEL    : in  std_logic;
      PENABLE : in  std_logic;
      PWRITE  : in  std_logic;
      PSTRB   : in  std_logic;
      PADDR   : in  std_logic_vector(63 downto 0);
      PWDATA  : in  std_logic_vector(PDATA_SIZE-1 downto 0);
      PRDATA  : out std_logic_vector(PDATA_SIZE-1 downto 0);
      PREADY  : out std_logic;
      PSLVERR : out std_logic;

      gpio_i  : in  std_logic_vector(PDATA_SIZE-1 downto 0);
      gpio_o  : out std_logic_vector(PDATA_SIZE-1 downto 0);
      gpio_oe : out std_logic_vector(PDATA_SIZE-1 downto 0)
    );
  end component;

  component mpsoc_spram
    generic (
      MEM_SIZE          : integer := 0;  --Memory in Bytes
      MEM_DEPTH         : integer := 256;  --Memory depth
      PLEN              : integer := 64;
      XLEN              : integer := 64;
      TECHNOLOGY        : string  := "GENERIC";
      REGISTERED_OUTPUT : string  := "NO"
    );
    port (
      HRESETn : in std_logic;
      HCLK    : in std_logic;

      --AHB Slave Interfaces (receive data from AHB Masters)
      --AHB Masters connect to these ports
      HSEL      : in  std_logic;
      HADDR     : in  std_logic_vector(PLEN-1 downto 0);
      HWDATA    : in  std_logic_vector(XLEN-1 downto 0);
      HRDATA    : out std_logic_vector(XLEN-1 downto 0);
      HWRITE    : in  std_logic;
      HSIZE     : in  std_logic_vector(2 downto 0);
      HBURST    : in  std_logic_vector(2 downto 0);
      HPROT     : in  std_logic_vector(3 downto 0);
      HTRANS    : in  std_logic_vector(1 downto 0);
      HMASTLOCK : in  std_logic;
      HREADYOUT : out std_logic;
      HREADY    : in  std_logic;
      HRESP     : out std_logic
    );
  end component;

  component mpsoc_simd_mpram
    generic (
      MEM_SIZE          : integer := 0;  --Memory in Bytes
      MEM_DEPTH         : integer := 256;  --Memory depth
      PLEN              : integer := 64;
      XLEN              : integer := 64;
      TECHNOLOGY        : string  := "GENERIC";
      REGISTERED_OUTPUT : string  := "NO"
    );
    port (
      HRESETn : in std_logic;
      HCLK    : in std_logic;

      --AHB Slave Interfaces (receive data from AHB Masters)
      --AHB Masters connect to these ports
      HSEL      : in  std_logic_vector(CORES_PER_SIMD-1 downto 0);
      HADDR     : in  M_CORES_PER_SIMD_PLEN;
      HWDATA    : in  M_CORES_PER_SIMD_XLEN;
      HRDATA    : out M_CORES_PER_SIMD_XLEN;
      HWRITE    : in  std_logic_vector(CORES_PER_SIMD-1 downto 0);
      HSIZE     : in  M_CORES_PER_SIMD_2;
      HBURST    : in  M_CORES_PER_SIMD_2;
      HPROT     : in  M_CORES_PER_SIMD_3;
      HTRANS    : in  M_CORES_PER_SIMD_1;
      HMASTLOCK : in  std_logic_vector(CORES_PER_SIMD-1 downto 0);
      HREADYOUT : out std_logic_vector(CORES_PER_SIMD-1 downto 0);
      HREADY    : in  std_logic_vector(CORES_PER_SIMD-1 downto 0);
      HRESP     : out std_logic_vector(CORES_PER_SIMD-1 downto 0)
    );
  end component;

  --////////////////////////////////////////////////////////////////
  --
  -- Constants
  --
  constant MASTERS : integer := 5;
  constant SLAVES  : integer := 5;

  constant ADDR_WIDTH : integer := 32;
  constant DATA_WIDTH : integer := 32;

  constant TABLE_ENTRIES          : integer := 4;
  constant TABLE_ENTRIES_PTRWIDTH : integer := integer(log2(real(4)));
  constant TILEID                 : integer := 0;
  constant NOC_PACKET_SIZE        : integer := 16;
  constant GENERATE_INTERRUPT     : integer := 1;

  constant SIMD_BITS : integer := integer(log2(real(CORES_PER_SIMD)));

  constant MAPPING : std_logic_vector(XLEN-1 downto 0) := (others => 'X');

  --////////////////////////////////////////////////////////////////
  --
  -- Functions
  --
  function to_stdlogic (
    input : boolean
  ) return std_logic is
  begin
    if input then
      return('1');
    else
      return('0');
    end if;
  end function to_stdlogic;

  function reduce_or (
    reduce_or_in : std_logic_vector
  ) return std_logic is
    variable reduce_or_out : std_logic := '0';
  begin
    for i in reduce_or_in'range loop
      reduce_or_out := reduce_or_out or reduce_or_in(i);
    end loop;
    return reduce_or_out;
  end reduce_or;

  function onehot2int (
    onehot : std_logic_vector(CORES_PER_SIMD-1 downto 0)
  ) return integer is
    variable onehot2int_return : integer := -1;

    variable onehot_return : std_logic_vector(CORES_PER_SIMD-1 downto 0) := onehot;
  begin
    while (reduce_or(onehot) = '1') loop
      onehot2int_return := onehot2int_return + 1;
      onehot_return     := std_logic_vector(unsigned(onehot_return) srl 1);
    end loop;
    return onehot2int_return;
  end onehot2int;  --onehot2int

  function highest_requested_priority (
    hsel : std_logic_vector(CORES_PER_SIMD-1 downto 0)
  ) return std_logic_vector is
    variable priorities                        : M_CORES_PER_SIMD_2;
    variable highest_requested_priority_return : std_logic_vector (2 downto 0);
  begin
    highest_requested_priority_return := (others => '0');
    for n in 0 to CORES_PER_SIMD - 1 loop
      if (hsel(n) = '1' and unsigned(priorities(n)) > unsigned(highest_requested_priority_return)) then
        highest_requested_priority_return := priorities(n);
      end if;
    end loop;
    return highest_requested_priority_return;
  end highest_requested_priority;  --highest_requested_priority

  function requesters (
    hsel            : std_logic_vector(CORES_PER_SIMD-1 downto 0);
    priority_select : std_logic_vector(2 downto 0)

  ) return std_logic_vector is
    variable priorities        : M_CORES_PER_SIMD_2;
    variable requesters_return : std_logic_vector (CORES_PER_SIMD-1 downto 0);
  begin
    for n in 0 to CORES_PER_SIMD - 1 loop
      requesters_return(n) := to_stdlogic(priorities(n) = priority_select) and hsel(n);
    end loop;
    return requesters_return;
  end requesters;  --requesters

  function nxt_simd_master (
    pending_simd_masters : std_logic_vector(CORES_PER_SIMD-1 downto 0);  --pending masters for the requesed priority level
    last_simd_master     : std_logic_vector(CORES_PER_SIMD-1 downto 0);  --last granted master for the priority level
    current_simd_master  : std_logic_vector(CORES_PER_SIMD-1 downto 0)  --current granted master (indpendent of priority level)
  ) return std_logic_vector is
    variable offset                 : integer;
    variable sr                     : std_logic_vector(CORES_PER_SIMD*2-1 downto 0);
    variable nxt_simd_master_return : std_logic_vector (CORES_PER_SIMD-1 downto 0);
  begin
    --default value, don't switch if not needed
    nxt_simd_master_return := current_simd_master;

    --implement round-robin
    offset := onehot2int(last_simd_master)+1;

    sr := (pending_simd_masters & pending_simd_masters);
    for n in 0 to CORES_PER_SIMD - 1 loop
      if (sr(n+offset) = '1') then
        return std_logic_vector(to_unsigned(2**((n+offset) mod CORES_PER_SIMD), CORES_PER_SIMD));
      end if;
    end loop;
    return nxt_simd_master_return;
  end nxt_simd_master;

  --//////////////////////////////////////////////////////////////
  --
  -- Variables
  --

  -- DMA
  signal noc_ahb3_in_req_flit  : M_CORES_PER_SIMD_FLIT_WIDTH;
  signal noc_ahb3_in_req_valid : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal noc_ahb3_in_req_ready : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  signal noc_ahb3_in_res_flit  : M_CORES_PER_SIMD_FLIT_WIDTH;
  signal noc_ahb3_in_res_valid : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal noc_ahb3_in_res_ready : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  signal noc_ahb3_out_req_flit  : M_CORES_PER_SIMD_FLIT_WIDTH;
  signal noc_ahb3_out_req_valid : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal noc_ahb3_out_req_ready : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  signal noc_ahb3_out_res_flit  : M_CORES_PER_SIMD_FLIT_WIDTH;
  signal noc_ahb3_out_res_valid : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal noc_ahb3_out_res_ready : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  signal ahb3_if_hsel      : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal ahb3_if_haddr     : M_CORES_PER_SIMD_ADDR_WIDTH;
  signal ahb3_if_hrdata    : M_CORES_PER_SIMD_DATA_WIDTH;
  signal ahb3_if_hwdata    : M_CORES_PER_SIMD_DATA_WIDTH;
  signal ahb3_if_hwrite    : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal ahb3_if_hmastlock : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal ahb3_if_hready    : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal ahb3_if_hresp     : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  signal ahb3_hsel      : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal ahb3_haddr     : M_CORES_PER_SIMD_ADDR_WIDTH;
  signal ahb3_hwdata    : M_CORES_PER_SIMD_DATA_WIDTH;
  signal ahb3_hrdata    : M_CORES_PER_SIMD_DATA_WIDTH;
  signal ahb3_hwrite    : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal ahb3_hsize     : M_CORES_PER_SIMD_2;
  signal ahb3_hburst    : M_CORES_PER_SIMD_2;
  signal ahb3_hprot     : M_CORES_PER_SIMD_3;
  signal ahb3_htrans    : M_CORES_PER_SIMD_1;
  signal ahb3_hmastlock : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal ahb3_hready    : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  signal irq_ahb3 : M_CORES_PER_SIMD_TABLE_ENTRIES;

  signal mux_flit  : M_CORES_PER_SIMD_FLIT_WIDTH;
  signal mux_last  : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mux_valid : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mux_ready : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  signal demux_flit  : M_CORES_PER_SIMD_FLIT_WIDTH;
  signal demux_last  : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal demux_valid : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal demux_ready : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  -- Connections DMA
  signal noc_ahb3_in_flit  : M_CORES_PER_SIMD_CHANNELS_FLIT_WIDTH;
  signal noc_ahb3_in_valid : M_CORES_PER_SIMD_CHANNELS;
  signal noc_ahb3_in_ready : M_CORES_PER_SIMD_CHANNELS;

  signal noc_ahb3_out_flit  : M_CORES_PER_SIMD_CHANNELS_FLIT_WIDTH;
  signal noc_ahb3_out_valid : M_CORES_PER_SIMD_CHANNELS;
  signal noc_ahb3_out_ready : M_CORES_PER_SIMD_CHANNELS;

  -- Connections SIMD
  signal noc_input_flit  : M_CORES_PER_SIMD_FLIT_WIDTH;
  signal noc_input_last  : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal noc_input_valid : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal noc_input_ready : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  signal noc_output_flit  : M_CORES_PER_SIMD_FLIT_WIDTH;
  signal noc_output_last  : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal noc_output_valid : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal noc_output_ready : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  -- Connections LNKs
  signal linked0_flit  : std_logic_vector(FLIT_WIDTH-1 downto 0);
  signal linked0_last  : std_logic;
  signal linked0_valid : std_logic;
  signal linked0_ready : std_logic;

  signal linked1_flit  : std_logic_vector(FLIT_WIDTH-1 downto 0);
  signal linked1_last  : std_logic;
  signal linked1_valid : std_logic;
  signal linked1_ready : std_logic;

  -- MSI
  signal mst_HSEL      : M_CORES_PER_SIMD_MASTERS;
  signal mst_HADDR     : M_CORES_PER_SIMD_MASTERS_PLEN;
  signal mst_HWDATA    : M_CORES_PER_SIMD_MASTERS_XLEN;
  signal mst_HRDATA    : M_CORES_PER_SIMD_MASTERS_XLEN;
  signal mst_HWRITE    : M_CORES_PER_SIMD_MASTERS;
  signal mst_HSIZE     : M_CORES_PER_SIMD_MASTERS_2;
  signal mst_HBURST    : M_CORES_PER_SIMD_MASTERS_2;
  signal mst_HPROT     : M_CORES_PER_SIMD_MASTERS_3;
  signal mst_HTRANS    : M_CORES_PER_SIMD_MASTERS_1;
  signal mst_HMASTLOCK : M_CORES_PER_SIMD_MASTERS;
  signal mst_HREADY    : M_CORES_PER_SIMD_MASTERS;
  signal mst_HREADYOUT : M_CORES_PER_SIMD_MASTERS;
  signal mst_HRESP     : M_CORES_PER_SIMD_MASTERS;

  signal slv_HSEL      : M_CORES_PER_SIMD_SLAVES;
  signal slv_HADDR     : M_CORES_PER_SIMD_SLAVES_PLEN;
  signal slv_HWDATA    : M_CORES_PER_SIMD_SLAVES_XLEN;
  signal slv_HRDATA    : M_CORES_PER_SIMD_SLAVES_XLEN;
  signal slv_HWRITE    : M_CORES_PER_SIMD_SLAVES;
  signal slv_HSIZE     : M_CORES_PER_SIMD_SLAVES_2;
  signal slv_HBURST    : M_CORES_PER_SIMD_SLAVES_2;
  signal slv_HPROT     : M_CORES_PER_SIMD_SLAVES_3;
  signal slv_HTRANS    : M_CORES_PER_SIMD_SLAVES_1;
  signal slv_HMASTLOCK : M_CORES_PER_SIMD_SLAVES;
  signal slv_HREADY    : M_CORES_PER_SIMD_SLAVES;
  signal slv_HRESP     : M_CORES_PER_SIMD_SLAVES;

  -- GPIO
  signal mst_gpio_HSEL      : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mst_gpio_HADDR     : M_CORES_PER_SIMD_PLEN;
  signal mst_gpio_HWDATA    : M_CORES_PER_SIMD_XLEN;
  signal mst_gpio_HRDATA    : M_CORES_PER_SIMD_XLEN;
  signal mst_gpio_HWRITE    : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mst_gpio_HSIZE     : M_CORES_PER_SIMD_2;
  signal mst_gpio_HBURST    : M_CORES_PER_SIMD_2;
  signal mst_gpio_HPROT     : M_CORES_PER_SIMD_3;
  signal mst_gpio_HTRANS    : M_CORES_PER_SIMD_1;
  signal mst_gpio_HMASTLOCK : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mst_gpio_HREADY    : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mst_gpio_HREADYOUT : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mst_gpio_HRESP     : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  signal gpio_PSEL    : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal gpio_PENABLE : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal gpio_PWRITE  : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal gpio_PSTRB   : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal gpio_PADDR   : M_CORES_PER_SIMD_PADDR_SIZE;
  signal gpio_PWDATA  : M_CORES_PER_SIMD_PADDR_SIZE;
  signal gpio_PRDATA  : M_CORES_PER_SIMD_PADDR_SIZE;
  signal gpio_PREADY  : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal gpio_PSLVERR : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  -- RAM
  signal mst_sram_HSEL      : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mst_sram_HADDR     : M_CORES_PER_SIMD_PLEN;
  signal mst_sram_HWDATA    : M_CORES_PER_SIMD_XLEN;
  signal mst_sram_HRDATA    : M_CORES_PER_SIMD_XLEN;
  signal mst_sram_HWRITE    : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mst_sram_HSIZE     : M_CORES_PER_SIMD_2;
  signal mst_sram_HBURST    : M_CORES_PER_SIMD_2;
  signal mst_sram_HPROT     : M_CORES_PER_SIMD_3;
  signal mst_sram_HTRANS    : M_CORES_PER_SIMD_1;
  signal mst_sram_HMASTLOCK : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mst_sram_HREADY    : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mst_sram_HREADYOUT : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mst_sram_HRESP     : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  signal mst_mram_HSEL      : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mst_mram_HADDR     : M_CORES_PER_SIMD_PLEN;
  signal mst_mram_HWDATA    : M_CORES_PER_SIMD_XLEN;
  signal mst_mram_HRDATA    : M_CORES_PER_SIMD_XLEN;
  signal mst_mram_HWRITE    : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mst_mram_HSIZE     : M_CORES_PER_SIMD_2;
  signal mst_mram_HBURST    : M_CORES_PER_SIMD_2;
  signal mst_mram_HPROT     : M_CORES_PER_SIMD_3;
  signal mst_mram_HTRANS    : M_CORES_PER_SIMD_1;
  signal mst_mram_HMASTLOCK : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mst_mram_HREADY    : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mst_mram_HREADYOUT : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal mst_mram_HRESP     : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  -- PU
  signal bus_ins_HSEL      : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal bus_ins_HADDR     : M_CORES_PER_SIMD_PLEN;
  signal bus_ins_HWDATA    : M_CORES_PER_SIMD_XLEN;
  signal bus_ins_HRDATA    : M_CORES_PER_SIMD_XLEN;
  signal bus_ins_HWRITE    : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal bus_ins_HSIZE     : M_CORES_PER_SIMD_2;
  signal bus_ins_HBURST    : M_CORES_PER_SIMD_2;
  signal bus_ins_HPROT     : M_CORES_PER_SIMD_3;
  signal bus_ins_HTRANS    : M_CORES_PER_SIMD_1;
  signal bus_ins_HMASTLOCK : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal bus_ins_HREADY    : std_logic_vector(CORES_PER_SIMD-1 downto 0);
  signal bus_ins_HRESP     : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  signal requested_priority_lvl : std_logic_vector(2 downto 0);  --requested priority level
  signal priority_simd_masters  : std_logic_vector(CORES_PER_SIMD-1 downto 0);  --all masters at this priority level

  signal pending_simd_master       : std_logic_vector(CORES_PER_SIMD-1 downto 0);  --next master waiting to be served
  signal last_granted_simd_master  : std_logic_vector(CORES_PER_SIMD-1 downto 0);  --for requested priority level
  signal last_granted_simd_masters : M_3_CORES_PER_SIMD;  --per priority level, for round-robin

  signal granted_simd_master_idx     : std_logic_vector(SIMD_BITS-1 downto 0);  --granted master as index
  signal granted_simd_master_idx_dly : std_logic_vector(SIMD_BITS-1 downto 0);  --deleayed granted master index (for HWDATA)

  signal granted_simd_master : std_logic_vector(CORES_PER_SIMD-1 downto 0);

  --//////////////////////////////////////////////////////////////
  --
  -- Module Body
  --

--Instantiate RISC-V PU
begin
  generating_0 : for t in 0 to CORES_PER_SIMD - 1 generate
    --Instantiate RISC-V PU
    pu : riscv_pu
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

        PARCEL_SIZE => PARCEL_SIZE
      )
      port map (
        --Common signals
        HRESETn => HRESETn,
        HCLK    => HCLK,

        --PMA configuration
        pma_cfg_i => pma_cfg_i,
        pma_adr_i => pma_adr_i,

        --AHB instruction
        ins_HSEL      => bus_ins_HSEL(t),
        ins_HADDR     => bus_ins_HADDR(t),
        ins_HWDATA    => bus_ins_HWDATA(t),
        ins_HRDATA    => bus_ins_HRDATA(t),
        ins_HWRITE    => bus_ins_HWRITE(t),
        ins_HSIZE     => bus_ins_HSIZE(t),
        ins_HBURST    => bus_ins_HBURST(t),
        ins_HPROT     => bus_ins_HPROT(t),
        ins_HTRANS    => bus_ins_HTRANS(t),
        ins_HMASTLOCK => bus_ins_HMASTLOCK(t),
        ins_HREADY    => bus_ins_HREADY(t),
        ins_HRESP     => bus_ins_HRESP(t),

        --AHB data
        dat_HSEL      => dat_HSEL(t),
        dat_HADDR     => dat_HADDR(t),
        dat_HWDATA    => dat_HWDATA(t),
        dat_HRDATA    => dat_HRDATA(t),
        dat_HWRITE    => dat_HWRITE(t),
        dat_HSIZE     => dat_HSIZE(t),
        dat_HBURST    => dat_HBURST(t),
        dat_HPROT     => dat_HPROT(t),
        dat_HTRANS    => dat_HTRANS(t),
        dat_HMASTLOCK => dat_HMASTLOCK(t),
        dat_HREADY    => dat_HREADY(t),
        dat_HRESP     => dat_HRESP(t),

        --Interrupts Interface
        ext_nmi  => ext_nmi(t),
        ext_tint => ext_tint(t),
        ext_sint => ext_sint(t),
        ext_int  => ext_int(t),

        --Debug Interface
        dbg_stall => dbg_stall(t),
        dbg_strb  => dbg_strb(t),
        dbg_we    => dbg_we(t),
        dbg_addr  => dbg_addr(t),
        dbg_dati  => dbg_dati(t),
        dbg_dato  => dbg_dato(t),
        dbg_ack   => dbg_ack(t),
        dbg_bp    => dbg_bp(t)
      );

    peripheral_interface : mpsoc_msi_interface
      generic map (
        PLEN    => PLEN,
        XLEN    => XLEN,
        MASTERS => MASTERS,
        SLAVES  => SLAVES
      )
      port map (
        --Common signals
        HRESETn => HRESETn,
        HCLK    => HCLK,

        --Master Ports; AHB masters connect to these
        --thus these are actually AHB Slave Interfaces
        mst_priority => (others => (others => '0')),

        mst_HSEL      => mst_HSEL(t),
        mst_HADDR     => mst_HADDR(t),
        mst_HWDATA    => mst_HWDATA(t),
        mst_HRDATA    => mst_HRDATA(t),
        mst_HWRITE    => mst_HWRITE(t),
        mst_HSIZE     => mst_HSIZE(t),
        mst_HBURST    => mst_HBURST(t),
        mst_HPROT     => mst_HPROT(t),
        mst_HTRANS    => mst_HTRANS(t),
        mst_HMASTLOCK => mst_HMASTLOCK(t),
        mst_HREADYOUT => mst_HREADYOUT(t),
        mst_HREADY    => mst_HREADY(t),
        mst_HRESP     => mst_HRESP(t),

        --Slave Ports; AHB Slaves connect to these
        --thus these are actually AHB Master Interfaces
        slv_addr_mask => (others => (others => '0')),
        slv_addr_base => (others => (others => '0')),

        slv_HSEL      => slv_HSEL(t),
        slv_HADDR     => slv_HADDR(t),
        slv_HWDATA    => slv_HWDATA(t),
        slv_HRDATA    => slv_HRDATA(t),
        slv_HWRITE    => slv_HWRITE(t),
        slv_HSIZE     => slv_HSIZE(t),
        slv_HBURST    => slv_HBURST(t),
        slv_HPROT     => slv_HPROT(t),
        slv_HTRANS    => slv_HTRANS(t),
        slv_HMASTLOCK => slv_HMASTLOCK(t),
        slv_HREADYOUT => open,
        slv_HREADY    => slv_HREADY(t),
        slv_HRESP     => slv_HRESP(t)
      );

    --Instantiate RISC-V DMA
    ahb3_top : mpsoc_dma_ahb3_top
      generic map (
        ADDR_WIDTH => 64,
        DATA_WIDTH => 64,

        TABLE_ENTRIES          => TABLE_ENTRIES,
        TABLE_ENTRIES_PTRWIDTH => TABLE_ENTRIES_PTRWIDTH,
        TILEID                 => TILEID,
        NOC_PACKET_SIZE        => NOC_PACKET_SIZE,
        GENERATE_INTERRUPT     => GENERATE_INTERRUPT
      )
      port map (
        clk => HCLK,
        rst => HRESETn,

        noc_in_req_flit  => noc_ahb3_in_req_flit(t),
        noc_in_req_valid => noc_ahb3_in_req_valid(t),
        noc_in_req_ready => noc_ahb3_in_req_ready(t),

        noc_in_res_flit  => noc_ahb3_in_res_flit(t),
        noc_in_res_valid => noc_ahb3_in_res_valid(t),
        noc_in_res_ready => noc_ahb3_in_res_ready(t),

        noc_out_req_flit  => noc_ahb3_out_req_flit(t),
        noc_out_req_valid => noc_ahb3_out_req_valid(t),
        noc_out_req_ready => noc_ahb3_out_req_ready(t),

        noc_out_res_flit  => noc_ahb3_out_res_flit(t),
        noc_out_res_valid => noc_ahb3_out_res_valid(t),
        noc_out_res_ready => noc_ahb3_out_res_ready(t),

        ahb3_if_haddr     => ahb3_if_haddr(t),
        ahb3_if_hrdata    => ahb3_if_hrdata(t),
        ahb3_if_hmastlock => ahb3_if_hmastlock(t),
        ahb3_if_hsel      => ahb3_if_hsel(t),
        ahb3_if_hwrite    => ahb3_if_hwrite(t),
        ahb3_if_hwdata    => ahb3_if_hwdata(t),
        ahb3_if_hready    => ahb3_if_hready(t),
        ahb3_if_hresp     => ahb3_if_hresp(t),

        ahb3_haddr     => ahb3_haddr(t),
        ahb3_hwdata    => ahb3_hwdata(t),
        ahb3_hmastlock => ahb3_hmastlock(t),
        ahb3_hsel      => ahb3_hsel(t),
        ahb3_hprot     => ahb3_hprot(t),
        ahb3_hwrite    => ahb3_hwrite(t),
        ahb3_hsize     => ahb3_hsize(t),
        ahb3_hburst    => ahb3_hburst(t),
        ahb3_htrans    => ahb3_htrans(t),
        ahb3_hrdata    => ahb3_hrdata(t),
        ahb3_hready    => ahb3_hready(t),

        irq => irq_ahb3(t)
      );

    mux_noc_buffer : mpsoc_noc_buffer
      generic map (
        FLIT_WIDTH => FLIT_WIDTH,
        DEPTH      => 16,
        FULLPACKET => 0
      )
      port map (
        clk => HRESETn,
        rst => HCLK,

        in_flit  => mux_flit(t),
        in_last  => mux_last(t),
        in_valid => mux_valid(t),
        in_ready => mux_ready(t),

        out_flit  => noc_output_flit(t),
        out_last  => noc_output_last(t),
        out_valid => noc_output_valid(t),
        out_ready => noc_output_ready(t),

        packet_size => open
      );

    demux_noc_buffer : mpsoc_noc_buffer
      generic map (
        FLIT_WIDTH => FLIT_WIDTH,
        DEPTH      => 16,
        FULLPACKET => 0
      )
      port map (
        clk => HRESETn,
        rst => HCLK,

        in_flit  => noc_input_flit(t),
        in_last  => noc_input_last(t),
        in_valid => noc_input_valid(t),
        in_ready => noc_input_ready(t),

        out_flit  => demux_flit(t),
        out_last  => demux_last(t),
        out_valid => demux_valid(t),
        out_ready => demux_ready(t),

        packet_size => open
      );

    --noc_mux : mpsoc_noc_mux
      --generic map (
        --FLIT_WIDTH => FLIT_WIDTH,
        --CHANNELS   => CHANNELS
      --)
      --port map (
        --clk => HRESETn,
        --rst => HCLK,

        --in_flit  => noc_ahb3_out_flit(t),
        --in_last  => (others => '1'),
        --in_valid => noc_ahb3_out_valid(t),
        --in_ready => noc_ahb3_out_ready(t),

        --out_flit  => mux_flit(t),
        --out_last  => mux_last(t),
        --out_valid => mux_valid(t),
        --out_ready => mux_ready(t)
      --);

    --noc_demux : mpsoc_noc_demux
      --generic map (
        --FLIT_WIDTH => FLIT_WIDTH,
        --CHANNELS   => CHANNELS,
        --MAPPING    => MAPPING
      --)
      --port map (
        --clk => HRESETn,
        --rst => HCLK,

        --in_flit  => demux_flit(t),
        --in_last  => demux_last(t),
        --in_valid => demux_valid(t),
        --in_ready => demux_ready(t),

        --out_flit  => noc_ahb3_in_flit(t),
        --out_last  => open,
        --out_valid => noc_ahb3_in_valid(t),
        --out_ready => noc_ahb3_in_ready(t)
      --);

    noc_ahb3_in_req_flit(t)  <= noc_ahb3_in_flit(t)(0);
    noc_ahb3_in_req_valid(t) <= noc_ahb3_in_valid(t)(0);

    noc_ahb3_in_ready(t)(0) <= noc_ahb3_in_req_ready(t);


    noc_ahb3_in_res_flit(t)  <= noc_ahb3_in_flit(t)(1);
    noc_ahb3_in_res_valid(t) <= noc_ahb3_in_valid(t)(1);

    noc_ahb3_in_ready(t)(1) <= noc_ahb3_in_res_ready(t);


    noc_ahb3_out_flit(t)(0)  <= noc_ahb3_out_req_flit(t);
    noc_ahb3_out_valid(t)(0) <= noc_ahb3_out_req_valid(t);

    noc_ahb3_out_req_ready(t) <= noc_ahb3_out_ready(t)(0);


    noc_ahb3_out_flit(t)(1)  <= noc_ahb3_out_res_flit(t);
    noc_ahb3_out_valid(t)(1) <= noc_ahb3_out_res_valid(t);

    noc_ahb3_out_res_ready(t) <= noc_ahb3_out_ready(t)(1);

    --Instantiate RISC-V GPIO
    gpio_bridge : mpsoc_peripheral_bridge
      generic map (
        HADDR_SIZE => PLEN,
        HDATA_SIZE => XLEN,
        PADDR_SIZE => PLEN,
        PDATA_SIZE => XLEN,

        SYNC_DEPTH => SYNC_DEPTH
      )
      port map (
        --AHB Slave Interface
        HRESETn => HRESETn,
        HCLK    => HCLK,

        HSEL      => mst_gpio_HSEL(t),
        HADDR     => mst_gpio_HADDR(t),
        HWDATA    => mst_gpio_HWDATA(t),
        HRDATA    => mst_gpio_HRDATA(t),
        HWRITE    => mst_gpio_HWRITE(t),
        HSIZE     => mst_gpio_HSIZE(t),
        HBURST    => mst_gpio_HBURST(t),
        HPROT     => mst_gpio_HPROT(t),
        HTRANS    => mst_gpio_HTRANS(t),
        HMASTLOCK => mst_gpio_HMASTLOCK(t),
        HREADYOUT => mst_gpio_HREADYOUT(t),
        HREADY    => mst_gpio_HREADY(t),
        HRESP     => mst_gpio_HRESP(t),

        --APB Master Interface
        PRESETn => HRESETn,
        PCLK    => HCLK,

        PSEL    => gpio_PSEL(t),
        PENABLE => gpio_PENABLE(t),
        PPROT   => open,
        PWRITE  => gpio_PWRITE(t),
        PSTRB   => gpio_PSTRB(t),
        PADDR   => gpio_PADDR(t),
        PWDATA  => gpio_PWDATA(t),
        PRDATA  => gpio_PRDATA(t),
        PREADY  => gpio_PREADY(t),
        PSLVERR => gpio_PSLVERR(t)
      );

    gpio : mpsoc_gpio
      generic map (
        PADDR_SIZE => PLEN,
        PDATA_SIZE => XLEN
      )
      port map (
        PRESETn => HRESETn,
        PCLK    => HCLK,

        PSEL    => gpio_PSEL(t),
        PENABLE => gpio_PENABLE(t),
        PWRITE  => gpio_PWRITE(t),
        PSTRB   => gpio_PSTRB(t),
        PADDR   => gpio_PADDR(t),
        PWDATA  => gpio_PWDATA(t),
        PRDATA  => gpio_PRDATA(t),
        PREADY  => gpio_PREADY(t),
        PSLVERR => gpio_PSLVERR(t),

        gpio_i  => gpio_i(t),
        gpio_o  => gpio_o(t),
        gpio_oe => gpio_oe(t)
      );

    spram : mpsoc_spram
      generic map (
        MEM_SIZE          => 0,
        MEM_DEPTH         => 256,
        PLEN              => PLEN,
        XLEN              => XLEN,
        TECHNOLOGY        => TECHNOLOGY,
        REGISTERED_OUTPUT => "NO"
      )
      port map (
        --AHB Slave Interface
        HRESETn => HRESETn,
        HCLK    => HCLK,

        HSEL      => mst_sram_HSEL(t),
        HADDR     => mst_sram_HADDR(t),
        HWDATA    => mst_sram_HWDATA(t),
        HRDATA    => mst_sram_HRDATA(t),
        HWRITE    => mst_sram_HWRITE(t),
        HSIZE     => mst_sram_HSIZE(t),
        HBURST    => mst_sram_HBURST(t),
        HPROT     => mst_sram_HPROT(t),
        HTRANS    => mst_sram_HTRANS(t),
        HMASTLOCK => mst_sram_HMASTLOCK(t),
        HREADYOUT => mst_sram_HREADYOUT(t),
        HREADY    => mst_sram_HREADY(t),
        HRESP     => mst_sram_HRESP(t)
      );

    -- MST Connections
    mst_HSEL(t)(0)      <= bus_ins_HSEL(t);
    mst_HADDR(t)(0)     <= bus_ins_HADDR(t);
    mst_HWDATA(t)(0)    <= bus_ins_HWDATA(t);
    mst_HWRITE(t)(0)    <= bus_ins_HWRITE(t);
    mst_HSIZE(t)(0)     <= bus_ins_HSIZE(t);
    mst_HBURST(t)(0)    <= bus_ins_HBURST(t);
    mst_HPROT(t)(0)     <= bus_ins_HPROT(t);
    mst_HTRANS(t)(0)    <= bus_ins_HTRANS(t);
    mst_HMASTLOCK(t)(0) <= bus_ins_HMASTLOCK(t);
    mst_HREADY(t)(0)    <= bus_ins_HREADY(t);

    mst_HREADYOUT(t)(0) <= '0';

    bus_ins_HRDATA(t) <= mst_HRDATA(t)(0);
    bus_ins_HRESP(t)  <= mst_HRESP(t)(0);

    mst_HSEL(t)(1)      <= ahb3_if_hsel(t);
    mst_HADDR(t)(1)     <= ahb3_if_haddr(t);
    mst_HWDATA(t)(1)    <= ahb3_if_hwdata(t);
    mst_HWRITE(t)(1)    <= ahb3_if_hwrite(t);
    mst_HSIZE(t)(1)     <= "000";
    mst_HBURST(t)(1)    <= "000";
    mst_HPROT(t)(1)     <= "0000";
    mst_HTRANS(t)(1)    <= "00";
    mst_HMASTLOCK(t)(1) <= ahb3_if_hmastlock(t);
    mst_HREADY(t)(1)    <= ahb3_if_hready(t);

    mst_HREADYOUT(t)(1) <= '0';

    ahb3_if_hrdata(t) <= mst_HRDATA(t)(1);
    --assign ahb3_if_hresp  [t] = mst_HRESP  [t][1];

    mst_HSEL(t)(2)      <= mst_gpio_HSEL(t);
    mst_HADDR(t)(2)     <= mst_gpio_HADDR(t);
    mst_HWDATA(t)(2)    <= mst_gpio_HWDATA(t);
    mst_HWRITE(t)(2)    <= mst_gpio_HWRITE(t);
    mst_HSIZE(t)(2)     <= mst_gpio_HSIZE(t);
    mst_HBURST(t)(2)    <= mst_gpio_HBURST(t);
    mst_HPROT(t)(2)     <= mst_gpio_HPROT(t);
    mst_HTRANS(t)(2)    <= mst_gpio_HTRANS(t);
    mst_HMASTLOCK(t)(2) <= mst_gpio_HMASTLOCK(t);
    mst_HREADY(t)(2)    <= mst_gpio_HREADY(t);

    mst_gpio_HRDATA(t)    <= mst_HRDATA(t)(2);
    mst_gpio_HREADYOUT(t) <= mst_HREADYOUT(t)(2);
    mst_gpio_HRESP(t)     <= mst_HRESP(t)(2);

    mst_HSEL(t)(3)      <= mst_sram_HSEL(t);
    mst_HADDR(t)(3)     <= mst_sram_HADDR(t);
    mst_HWDATA(t)(3)    <= mst_sram_HWDATA(t);
    mst_HWRITE(t)(3)    <= mst_sram_HWRITE(t);
    mst_HSIZE(t)(3)     <= mst_sram_HSIZE(t);
    mst_HBURST(t)(3)    <= mst_sram_HBURST(t);
    mst_HPROT(t)(3)     <= mst_sram_HPROT(t);
    mst_HTRANS(t)(3)    <= mst_sram_HTRANS(t);
    mst_HMASTLOCK(t)(3) <= mst_sram_HMASTLOCK(t);
    mst_HREADY(t)(3)    <= mst_sram_HREADY(t);

    mst_sram_HRDATA(t)    <= mst_HRDATA(t)(3);
    mst_sram_HREADYOUT(t) <= mst_HREADYOUT(t)(3);
    mst_sram_HRESP(t)     <= mst_HRESP(t)(3);

    mst_HSEL(t)(4)      <= mst_mram_HSEL(t);
    mst_HADDR(t)(4)     <= mst_mram_HADDR(t);
    mst_HWDATA(t)(4)    <= mst_mram_HWDATA(t);
    mst_HWRITE(t)(4)    <= mst_mram_HWRITE(t);
    mst_HSIZE(t)(4)     <= mst_mram_HSIZE(t);
    mst_HBURST(t)(4)    <= mst_mram_HBURST(t);
    mst_HPROT(t)(4)     <= mst_mram_HPROT(t);
    mst_HTRANS(t)(4)    <= mst_mram_HTRANS(t);
    mst_HMASTLOCK(t)(4) <= mst_mram_HMASTLOCK(t);
    mst_HREADY(t)(4)    <= mst_mram_HREADY(t);

    mst_mram_HRDATA(t)    <= mst_HRDATA(t)(4);
    mst_mram_HREADYOUT(t) <= mst_HREADYOUT(t)(4);
    mst_mram_HRESP(t)     <= mst_HRESP(t)(4);

    -- SLV Connections
    slv_HSEL(t)(0)      <= ahb3_hsel(t);
    slv_HADDR(t)(0)     <= ahb3_haddr(t);
    slv_HWDATA(t)(0)    <= ahb3_hwdata(t);
    slv_HWRITE(t)(0)    <= ahb3_hwrite(t);
    slv_HSIZE(t)(0)     <= ahb3_hsize(t);
    slv_HBURST(t)(0)    <= ahb3_hburst(t);
    slv_HPROT(t)(0)     <= ahb3_hprot(t);
    slv_HTRANS(t)(0)    <= ahb3_htrans(t);
    slv_HMASTLOCK(t)(0) <= ahb3_hmastlock(t);
    slv_HREADY(t)(0)    <= ahb3_hready(t);

    slv_HRDATA(t)(0) <= ahb3_hrdata(t);
    slv_HRESP(t)(0)  <= '0';
  end generate;

  --get highest priority from selected masters
  requested_priority_lvl <= highest_requested_priority(bus_ins_HSEL);

  --get pending masters for the highest priority requested
  priority_simd_masters <= requesters(bus_ins_HSEL, requested_priority_lvl);

  --get last granted master for the priority requested
  last_granted_simd_master <= last_granted_simd_masters(to_integer(unsigned(requested_priority_lvl)));

  --get next master to serve
  pending_simd_master <= nxt_simd_master(priority_simd_masters, last_granted_simd_master, granted_simd_master);

  --select new master
  processing_0 : process (HCLK, HRESETn)
  begin
    if (HRESETn = '0') then
      granted_simd_master <= X"1";
    elsif (rising_edge(HCLK)) then
      if (bus_ins_HSEL(to_integer(unsigned(granted_simd_master_idx))) = '0') then
        granted_simd_master <= pending_simd_master;
      end if;
    end if;
  end process;

  --store current master (for this priority level)
  processing_1 : process (HCLK, HRESETn)
  begin
    if (HRESETn = '0') then
      last_granted_simd_masters(to_integer(unsigned(requested_priority_lvl))) <= X"1";
    elsif (rising_edge(HCLK)) then
      if (bus_ins_HSEL(to_integer(unsigned(granted_simd_master_idx))) = '0') then
        last_granted_simd_masters(to_integer(unsigned(requested_priority_lvl))) <= pending_simd_master;
      end if;
    end if;
  end process;

  --get signals from current requester
  processing_2 : process (HCLK, HRESETn)
  begin
    if (HRESETn = '0') then
      granted_simd_master_idx <= X"0";
    elsif (rising_edge(HCLK)) then
      if (bus_ins_HSEL(to_integer(unsigned(granted_simd_master_idx))) = '0') then
        granted_simd_master_idx <= std_logic_vector(to_unsigned(onehot2int(pending_simd_master), SIMD_BITS));
      end if;
    end if;
  end process;

  processing_3 : process (HCLK)
  begin
    if (rising_edge(HCLK)) then
      if (bus_ins_HSEL(to_integer(unsigned(granted_simd_master_idx))) = '1') then
        granted_simd_master_idx_dly <= granted_simd_master_idx;
      end if;
    end if;
  end process;

  ins_HSEL      <= bus_ins_HSEL(to_integer(unsigned(granted_simd_master_idx)));
  ins_HADDR     <= bus_ins_HADDR(to_integer(unsigned(granted_simd_master_idx)));
  ins_HWDATA    <= bus_ins_HWDATA(to_integer(unsigned(granted_simd_master_idx_dly)));
  ins_HWRITE    <= bus_ins_HWRITE(to_integer(unsigned(granted_simd_master_idx)));
  ins_HSIZE     <= bus_ins_HSIZE(to_integer(unsigned(granted_simd_master_idx)));
  ins_HBURST    <= bus_ins_HBURST(to_integer(unsigned(granted_simd_master_idx)));
  ins_HPROT     <= bus_ins_HPROT(to_integer(unsigned(granted_simd_master_idx)));
  ins_HTRANS    <= bus_ins_HTRANS(to_integer(unsigned(granted_simd_master_idx)));
  ins_HMASTLOCK <= bus_ins_HMASTLOCK(to_integer(unsigned(granted_simd_master_idx)));

  generating_1 : for t in 0 to CORES_PER_SIMD - 1 generate
    bus_ins_HRDATA(t) <= ins_HRDATA;
    bus_ins_HREADY(t) <= ins_HREADY;
    bus_ins_HRESP(t)  <= ins_HRESP;
  end generate;

  --Instantiate RISC-V RAM
  --simd_mpram : mpsoc_simd_mpram
    --generic map (
      --MEM_SIZE          => 0,
      --MEM_DEPTH         => 256,
      --PLEN              => PLEN,
      --XLEN              => XLEN,
      --TECHNOLOGY        => TECHNOLOGY,
      --REGISTERED_OUTPUT => "NO"
    --)
    --port map (
      ----AHB Slave Interface
      --HRESETn => HRESETn,
      --HCLK    => HCLK,

      --HSEL      => mst_mram_HSEL,
      --HADDR     => mst_mram_HADDR,
      --HWDATA    => mst_mram_HWDATA,
      --HRDATA    => mst_mram_HRDATA,
      --HWRITE    => mst_mram_HWRITE,
      --HSIZE     => mst_mram_HSIZE,
      --HBURST    => mst_mram_HBURST,
      --HPROT     => mst_mram_HPROT,
      --HTRANS    => mst_mram_HTRANS,
      --HMASTLOCK => mst_mram_HMASTLOCK,
      --HREADYOUT => mst_mram_HREADYOUT,
      --HREADY    => mst_mram_HREADY,
      --HRESP     => mst_mram_HRESP
    --);

  --Instantiate LNKs
  --noc_mux_lnk1 : mpsoc_noc_mux
    --generic map (
      --FLIT_WIDTH => FLIT_WIDTH,
      --CHANNELS   => CORES_PER_SIMD
    --)
    --port map (
      --clk => HRESETn,
      --rst => HCLK,

      --in_flit  => (others => (others => '1')),  --noc_output_flit
      --in_last  => (others => '1'),              --noc_output_last
      --in_valid => (others => '1'),              --noc_output_valid
      --in_ready => open,                         --noc_output_ready

      --out_flit  => linked1_flit,
      --out_last  => linked1_last,
      --out_valid => linked1_valid,
      --out_ready => linked1_ready
    --);

  --noc_demux_lnk0 : mpsoc_noc_demux
    --generic map (
      --FLIT_WIDTH => FLIT_WIDTH,
      --CHANNELS   => CORES_PER_SIMD,
      --MAPPING    => MAPPING
    --)
    --port map (
      --clk => HRESETn,
      --rst => HCLK,

      --in_flit  => linked0_flit,
      --in_last  => linked0_last,
      --in_valid => linked0_valid,
      --in_ready => linked0_ready,

      --out_flit  => open,            --noc_input_flit
      --out_last  => open,            --noc_input_last
      --out_valid => open,            --noc_input_valid
      --out_ready => (others => '1')  --noc_input_ready
    --);

  --noc_mux_lnk0 : mpsoc_noc_mux
    --generic map (
      --FLIT_WIDTH => FLIT_WIDTH,
      --CHANNELS   => CHANNELS
    --)
    --port map (
      --clk => HRESETn,
      --rst => HCLK,

      --in_flit  => noc_in_flit,
      --in_last  => noc_in_last,
      --in_valid => noc_in_valid,
      --in_ready => noc_in_ready,

      --out_flit  => linked0_flit,
      --out_last  => linked0_last,
      --out_valid => linked0_valid,
      --out_ready => linked0_ready
    --);

  --noc_demux_lnk1 : mpsoc_noc_demux
    --generic map (
      --FLIT_WIDTH => FLIT_WIDTH,
      --CHANNELS   => CHANNELS,
      --MAPPING    => MAPPING
    --)
    --port map (
      --clk => HRESETn,
      --rst => HCLK,

      --in_flit  => linked1_flit,
      --in_last  => linked1_last,
      --in_valid => linked1_valid,
      --in_ready => linked1_ready,

      --out_flit  => noc_out_flit,
      --out_last  => noc_out_last,
      --out_valid => noc_out_valid,
      --out_ready => noc_out_ready
    --);
end RTL;
