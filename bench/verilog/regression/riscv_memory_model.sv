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
//              Memory Model                                                  //
//              AMBA3 AHB-Lite Bus Interface                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/* Copyright (c) 2019-2020 by the author(s)
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

`include "riscv_mpsoc_pkg.sv"

module riscv_memory_model #(
  parameter XLEN = 64,
  parameter PLEN = 64,

  parameter BASE = 'h0,

  parameter MEM_LATENCY = 1,

  parameter LATENCY = 1,
  parameter BURST   = 8,

  parameter INIT_FILE = "test.hex",

  parameter CORES_PER_TILE = 16
)
  (
    input                                             HCLK,
    input                                             HRESETn,

    input      [1:0][CORES_PER_TILE-1:0][        1:0] HTRANS,
    output     [1:0][CORES_PER_TILE-1:0]              HREADY,
    output     [1:0][CORES_PER_TILE-1:0]              HRESP,

    input      [1:0][CORES_PER_TILE-1:0][PLEN   -1:0] HADDR,
    input      [1:0][CORES_PER_TILE-1:0]              HWRITE,
    input      [1:0][CORES_PER_TILE-1:0][        2:0] HSIZE,
    input      [1:0][CORES_PER_TILE-1:0][        2:0] HBURST,
    input      [1:0][CORES_PER_TILE-1:0][XLEN   -1:0] HWDATA,
    output reg [1:0][CORES_PER_TILE-1:0][XLEN   -1:0] HRDATA
  );

  ////////////////////////////////////////////////////////////////
  //
  // Constants
  //
  localparam RADRCNT_MSB = $clog2(BURST) + $clog2(XLEN/8) - 1;

  ////////////////////////////////////////////////////////////////
  //
  // Typedefs
  //
  typedef bit  [     7:0] octet;
  typedef bit  [XLEN-1:0] data_type;
  typedef logic[PLEN-1:0] addr_type;

  ////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  integer m,n;
  genvar  u,p;

  data_type mem_array[addr_type];

  logic [1:0][CORES_PER_TILE-1:0][PLEN         -1:0] iaddr,
                                                     raddr,
                                                     waddr;
  logic [1:0][CORES_PER_TILE-1:0][RADRCNT_MSB    :0] radrcnt;

  logic [1:0][CORES_PER_TILE-1:0]                    wreq;
  logic [1:0][CORES_PER_TILE-1:0][XLEN/8       -1:0] dbe;

  logic [1:0][CORES_PER_TILE-1:0][MEM_LATENCY    :1] ack_latency;


  logic [1:0][CORES_PER_TILE-1:0][              1:0] dHTRANS;
  logic [1:0][CORES_PER_TILE-1:0]                    dHWRITE;
  logic [1:0][CORES_PER_TILE-1:0][              2:0] dHSIZE;
  logic [1:0][CORES_PER_TILE-1:0][              2:0] dHBURST;

  ////////////////////////////////////////////////////////////////
  //
  // Tasks
  //

  //Read Intel HEX
  task automatic read_ihex;
    input string file;

    integer m;
    integer fd,
            cnt,
            eof;

    reg   [ 31:0] tmp;

    octet         byte_cnt;
    octet [  1:0] address;
    octet         record_type;
    octet [255:0] data;
    octet         checksum, crc;

    addr_type     base_addr=BASE;

    /*
     * 1: start code
     * 2: byte count  (2 hex digits)
     * 3: address     (4 hex digits)
     * 4: record type (2 hex digits)
     *    00: data
     *    01: end of file
     *    02: extended segment address
     *    03: start segment address
     *    04: extended linear address (16lsbs of 32bit address)
     *    05: start linear address
     * 5: data
     * 6: checksum    (2 hex digits)
     */

    fd = $fopen(file, "r"); //open file
    if (fd < 32'h8000_0000) begin
      $display ("ERROR  : Skip reading file %s. Reason file not found", file);
      $finish();
      return ;
    end

    eof = 0;
    while (eof == 0) begin
      if ($fscanf(fd, ":%2h%4h%2h", byte_cnt, address, record_type) != 3)
        $display ("ERROR  : Read error while processing %s", file);

      //initial CRC value
      crc = byte_cnt + address[1] + address[0] + record_type;

      for (m=0; m<byte_cnt; m++) begin
        if ($fscanf(fd, "%2h", data[m]) != 1)
          $display ("ERROR  : Read error while processing %s", file);

        //update CRC
        crc = crc + data[m];
      end

      if ($fscanf(fd, "%2h", checksum) != 1)
        $display ("ERROR  : Read error while processing %s", file);

      if (checksum + crc)
        $display ("ERROR  : CRC error while processing %s", file);

      case (record_type)
        8'h00  : begin
          for (m=0; m<byte_cnt; m++) begin
            //mem_array[ base_addr + address + (m & ~(XLEN/8 -1)) ][ (m%(XLEN/8))*8+:8 ] = data[m];
            mem_array[ (base_addr + address + m) & ~(XLEN/8 -1) ][ ((base_addr + address + m) % (XLEN/8))*8+:8 ] = data[m];
            //$display ("write %2h to %8h (base_addr=%8h, address=%4h, m=%2h)", data[m], base_addr+address+ (m & ~(XLEN/8 -1)), base_addr, address, m);
            //$display ("(%8h)=%8h",base_addr+address+4*(m/4), mem_array[ base_addr+address+4*(m/4) ]);
          end
        end
        8'h01  : eof = 1;
        8'h02  : base_addr = {data[0],data[1]} << 4;
        8'h03  : $display("INFO   : Ignored record type %0d while processing %s", record_type, file);
        8'h04  : base_addr = {data[0], data[1]} << 16;
        8'h05  : base_addr = {data[0], data[1], data[2], data[3]};
        default: $display("ERROR  : Unknown record type while processing %s", file);
      endcase
    end

    $fclose (fd); //close file
  endtask

  //Read HEX generated by RISC-V elf2hex
  task automatic read_elf2hex;
    input string file;

    integer fd,
            m,
            line=0;

    reg [127:0] data;
    addr_type   base_addr = BASE;

    fd = $fopen(file, "r"); //open file
    if (fd < 32'h8000_0000) begin
      $display ("ERROR  : Skip reading file %s. File not found", file);
      $finish();
      return ;
    end
    else
      $display ("INFO   : Reading %s", file);

    //Read data from file
    while ( !$feof(fd) ) begin
      line=line+1;
      if ($fscanf(fd, "%32h", data) != 1)
        $display("ERROR  : Read error while processing %s (line %0d)", file, line);

      for (m=0; m< 128/XLEN; m++) begin
        //$display("[%8h]:%8h",base_addr,data[m*XLEN +: XLEN]);
        mem_array[ base_addr ] = data[m*XLEN +: XLEN];
        base_addr = base_addr + (XLEN/8);
      end
    end

    //close file
    $fclose(fd);
  endtask

  //Dump memory
  task dump;
    foreach (mem_array[m])
      $display("[%8h]:%8h", m,mem_array[m]);
  endtask

  ////////////////////////////////////////////////////////////////
  //
  // Module body
  //

  generate
    for (u=0; u < 2; u++) begin
      for (p=0; p < CORES_PER_TILE; p++) begin

        //Generate ACK

        if (MEM_LATENCY > 0) begin
          always @(posedge HCLK,negedge HRESETn) begin
            if      (!HRESETn             )             ack_latency[u][p] <= {MEM_LATENCY{1'b1}};
            else if (HREADY[u][p]) begin
              if      ( HTRANS[u][p] == `HTRANS_IDLE  ) ack_latency[u][p] <= {MEM_LATENCY{1'b1}};
              else if ( HTRANS[u][p] == `HTRANS_NONSEQ) ack_latency[u][p] <= 'h0;
            end
            else                                        ack_latency[u][p] <= {ack_latency[u][p],1'b1};
          end

          assign HREADY[u][p] = ack_latency[u][p][MEM_LATENCY];
        end
        else
          assign HREADY[u][p] = 1'b1;

        assign HRESP[u][p] = `HRESP_OKAY;

        //Write Section

        //delay control signals
        always @(posedge HCLK)
          if (HREADY[u][p]) begin
            dHTRANS[u][p] <= HTRANS[u][p];
            dHWRITE[u][p] <= HWRITE[u][p];
            dHSIZE [u][p] <= HSIZE [u][p];
            dHBURST[u][p] <= HBURST[u][p];
          end

        always @(posedge HCLK)
          if (HREADY[u][p] && HTRANS[u][p] != `HTRANS_BUSY) begin
            waddr[u][p] <= HADDR[u][p] & ( {XLEN{1'b1}} << $clog2(XLEN/8) );

            case (HSIZE[u][p])
              `HSIZE_BYTE : dbe[u][p] <= 1'h1  << HADDR[u][p][$clog2(XLEN/8)-1:0];
              `HSIZE_HWORD: dbe[u][p] <= 2'h3  << HADDR[u][p][$clog2(XLEN/8)-1:0];
              `HSIZE_WORD : dbe[u][p] <= 4'hf  << HADDR[u][p][$clog2(XLEN/8)-1:0];
              `HSIZE_DWORD: dbe[u][p] <= 8'hff << HADDR[u][p][$clog2(XLEN/8)-1:0];
            endcase
          end

        always @(posedge HCLK)
          if (HREADY[u][p]) wreq[u][p] <= (HTRANS[u][p] != `HTRANS_IDLE & HTRANS[u][p] != `HTRANS_BUSY) & HWRITE[u][p];

        always @(posedge HCLK)
          if (HREADY[u][p] && wreq[u][p])
            for (m=0; m<XLEN/8; m++)
              if (dbe[u][p][m]) mem_array[waddr[u][p]][m*8+:8] = HWDATA[u][p][m*8+:8];

        //Read Section
        assign iaddr[u][p] = HADDR[u][p] & ( {XLEN{1'b1}} << $clog2(XLEN/8) );

        always @(posedge HCLK)
          if (HREADY[u][p] && (HTRANS[u][p] != `HTRANS_IDLE) && (HTRANS[u][p] != `HTRANS_BUSY) && !HWRITE[u][p])
            if (iaddr[u][p] == waddr[u][p] && wreq[u][p]) begin
              for (n=0; n<XLEN/8; n++) begin
                if (dbe[u][p]) HRDATA[u][p][n*8+:8] <= HWDATA[u][p][n*8+:8];
                else           HRDATA[u][p][n*8+:8] <= mem_array[ iaddr[u][p] ][n*8+:8];
              end
            end
        else begin
          HRDATA[u][p] <= mem_array[ iaddr[u][p] ];
        end
      end
    end
  endgenerate
endmodule
