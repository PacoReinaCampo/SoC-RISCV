# ARCHITECTURE

| `Name` | `Value` |
| :----- | :------ |
| `XLEN` | `64`    |
| `PLEN` | `64`    |
| `FLEN` | `64`    |

| `Name`      | `Value`       | `Description`                            |
| :---------- | :------------ | :--------------------------------------- |
| `PC_INIT`   | `'h8000_0000` | `Start here after reset`                 |
| `BASE`      | `PC_INIT`     | `offset where to load program in memory` |
| `INIT_FILE` | `"test.hex"`  |                                          |

| `Name`          | `Value`   |
| :-------------- | :-------- |
| `MEM_LATENCY`   | `1`       |
| `HAS_USER`      | `1`       |
| `HAS_SUPER`     | `1`       |
| `HAS_HYPER`     | `1`       |
| `HAS_BPU`       | `1`       |
| `HAS_FPU`       | `1`       |
| `HAS_MMU`       | `1`       |
| `HAS_RVM`       | `1`       |
| `HAS_RVA`       | `1`       |
| `HAS_RVC`       | `1`       |
| `HAS_RVN`       | `1`       |
| `HAS_RVB`       | `1`       |
| `HAS_RVT`       | `1`       |
| `HAS_RVP`       | `1`       |
| `HAS_EXT`       | `1`       |

:Core Parameters

| `Name`       | `Value`   |
| :----------- | :-------- |
| `IS_RV32E`   | `1`       |

| `Name`           | `Value`   |
| :--------------- | :-------- |
| `MULT_LATENCY`   | `1`       |

| `Name`    | `Value`        | `Description`    |
| :-------- | :------------- | :--------------- |
| `HTIF`    | `0`            | `Host-interface` |
| `TOHOST`  | `32'h80001000` |                  |
| `UART_TX` | `32'h80001080` |                  |

| `Name`        | `Value` | `Description`                    |
| :------------ | :------ | :------------------------------- |
| `BREAKPOINTS` | `8`     | `Number of hardware breakpoints` |

| `Name`    | `Value` | `Description`                                  |
| :-------- | :------ | :--------------------------------------------- |
| `PMA_CNT` | ` 4`    |                                                |
| `PMP_CNT` | `16`    | `Number of Physical Memory Protection entries` |

| `Name`              | `Value` |
| :------------------ | :------ |
| `BP_GLOBAL_BITS`    | ` 2`    |
| `BP_LOCAL_BITS`     | `10`    |
| `BP_LOCAL_BITS_LSB` | ` 2`    |

| `Name`       | `Value`     |
| :----------- | :---------- |
| `TECHNOLOGY` | `"GENERIC"` |
| `AVOID_X`    | `0`         |

| `Name`            | `Value`           |
| :---------------- | :---------------- |
| `MNMIVEC_DEFAULT` | `PC_INIT - 'h004` |
| `MTVEC_DEFAULT`   | `PC_INIT - 'h040` |
| `HTVEC_DEFAULT`   | `PC_INIT - 'h080` |
| `STVEC_DEFAULT`   | `PC_INIT - 'h0C0` |
| `UTVEC_DEFAULT`   | `PC_INIT - 'h100` |

| `Name`                  | `Value` |
| :---------------------- | :------ |
| `JEDEC_BANK`            | `10`    |
| `JEDEC_MANUFACTURER_ID` | `'h6e`  |

| `Name`   | `Value` |
| :------- | :------ |
| `HARTID` | `0`     |

| `Name`        | `Value` |
| :------------ | :------ |
| `PARCEL_SIZE` | `32`    |

| `Name`       | `Value` |
| :----------- | :------ |
| `SYNC_DEPTH` | `3`     |

| `Name`         | `Value` |
| :------------- | :------ |
| `BUFFER_DEPTH` | `4`     |

| `Name`    | `Value` |
| :-------- | :------ |
| `RDPORTS` | `1`     |
| `WRPORTS` | `1`     |
| `AR_BITS` | `5`     |

:RF Access

| `Name`        | `Value` |
| :------------ | :------ |
| `PMPCFG_MASK` | `8'h9F` |

| `Name`         | `Value` |
| :------------- | :------ |
| `ARCHID`       | `12`    |
| `REVPRV_MAJOR` | `1`     |
| `REVPRV_MINOR` | `10`    |
| `REVUSR_MAJOR` | `2`     |
| `REVUSR_MINOR` | `2`     |

:Definitions Package

## MAIN

| `Component`       |
| :---------------- |
| `pu_riscv_core`   |

:Implementation - Main

### PU RISCV CORE

## FETCH

| `Component`   |
| :------------ |
| `pu_riscv_if` |

:Implementation - Fetch

### PU RISCV IF

## DECODE

| `Component`   |
| :------------ |
| `pu_riscv_id` |

:Implementation - Decode

### PU RISCV ID

## EXECUTE

| `Component`           |
| :-------------------- |
| `pu_riscv_execution`  |
| `pu_riscv_alu`        |
| `pu_riscv_lsu`        |
| `pu_riscv_bu`         |
| `pu_riscv_divider`    |
| `pu_riscv_multiplier` |

:Implementation - Execute

### PU RISCV EXECUTION
### PU RISCV ALU
### PU RISCV LSU
### PU RISCV BU
### PU RISCV MULTIPLIER
### PU RISCV DIVIDER

## MEMORY

| `Component`       |
| :---------------- |
| `pu_riscv_memory` |

:Implementation - Memory

### PU RISCV MEMORY

## CONTROL

| `Component`      |
| :--------------- |
| `pu_riscv_state` |
| `pu_riscv_bp`    |
| `pu_riscv_du`    |

:Implementation - Control

### PU RISCV STATE
### PU RISCV BP
### PU RISCV DU

## PERIPHERAL

| `Component`            |
| :--------------------- |
| `pu_riscv_dcache_core` |
| `pu_riscv_dmem_ctrl`   |
| `pu_riscv_icache_core` |
| `pu_riscv_imem_ctrl`   |

:Implementation - Cache

### PU RISCV DCACHE-CORE

| `Name`               | `Value` | `Description`             |
| :------------------- | :------ | :------------------------ |
| `ICACHE_SIZE`        | `64`    | `in KBytes`               |
| `ICACHE_BLOCK_SIZE`  | `64`    | `in Bytes`                |
| `ICACHE_WAYS`        | `2`     | `'n'-way set associative` |
| `ICACHE_REPLACE_ALG` | `0`     |                           |
| `ITCM_SIZE`          | `0`     |                           |

### PU RISCV DMEM-CTRL

| `Name`               | `Value` | `Description`             |
| :------------------- | :------ | :------------------------ |
| `DCACHE_SIZE`        | `64`    | `in KBytes`               |
| `DCACHE_BLOCK_SIZE`  | `64`    | `in Bytes`                |
| `DCACHE_WAYS`        | `2`     | `'n'-way set associative` |
| `DCACHE_REPLACE_ALG` | `0`     |                           |
| `DTCM_SIZE`          | `0`     |                           |
| `WRITEBUFFER_SIZE`   | `8`     |                           |

### PU RISCV ICACHE-CORE
### PU RISCV IMEM-CTRL
