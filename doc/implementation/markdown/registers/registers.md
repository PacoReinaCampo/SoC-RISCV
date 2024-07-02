# State Unit

## Per Supervisor Spec Draft 1.10

| `Name`  | `Value` |
| :------ | :------ |
| `OFF`   | `2'd0`  |
| `TOR`   | `2'd1`  |
| `NA4`   | `2'd2`  |
| `NAPOT` | `2'd3`  |
: PMP-CFG Register

## CSR Mapping

### User

| `Name`    | `Value` |
| :-------- | :------ |
| `USTATUS` | `'h000` |
| `UIE`     | `'h004` |
| `UTVEC`   | `'h005` |
: User Trap Setup

| `Name`     | `Value` |
| :--------- | :------ |
| `USCRATCH` | `'h040` |
| `UEPC`     | `'h041` |
| `UCAUSE`   | `'h042` |
| `UBADADDR` | `'h043` |
| `UTVAL`    | `'h043` |
| `UIP`      | `'h044` |
: User Trap Handling

| `Name`   | `Value` |
| :------- | :------ |
| `FFLAGS` | `'h001` |
| `FRM`    | `'h002` |
| `FCSR`   | `'h003` |
: User Floating-Point CSRs

| `Name`         | `Value` | `Observation`              |
| :------------- | :------ | :------------------------- |
| `CYCLE`        | `'hC00` |                            |
| `TIMEX`        | `'hC01` |                            |
| `INSTRET`      | `'hC02` |                            |
| `HPMCOUNTER3`  | `'hC03` | `until HPMCOUNTER31='hC1F` |
| `CYCLEH`       | `'hC80` |                            |
| `TIMEH`        | `'hC81` |                            |
| `INSTRETH`     | `'hC82` |                            |
| `HPMCOUNTER3H` | `'hC83` | `until HPMCONTER31='hC9F`  |
: User Counters/Timers

### Supervisor

| `Name`       | `Value` |
| :----------- | :------ |
| `SSTATUS`    | `'h100` |
| `SEDELEG`    | `'h102` |
| `SIDELEG`    | `'h103` |
| `SIE`        | `'h104` |
| `STVEC`      | `'h105` |
| `SCOUNTEREN` | `'h106` |
: Supervisor Trap Setup

| `Name`     | `Value` |
| :--------- | :------ |
| `SSCRATCH` | `'h140` |
| `SEPC`     | `'h141` |
| `SCAUSE`   | `'h142` |
| `STVAL`    | `'h143` |
| `SIP`      | `'h144` |
: Supervisor Trap Handling

| `Name` | `Value` |
| :----- | :------ |
| `SATP` | `'h180` |
: Supervisor Protection and Translation

### Hypervisor

| `Name`    | `Value` |
| :-------- | :------ |
| `HSTATUS` | `'h200` |
| `HEDELEG` | `'h202` |
| `HIDELEG` | `'h203` |
| `HIE`     | `'h204` |
| `HTVEC`   | `'h205` |
: Hypervisor trap setup

| `Name`     | `Value` |
| :--------- | :------ |
| `HSCRATCH` | `'h240` |
| `HEPC`     | `'h241` |
| `HCAUSE`   | `'h242` |
| `HTVAL`    | `'h243` |
| `HIP`      | `'h244` |
: Hypervisor Trap Handling

### Machine

| `Name`      | `Value` |
| :---------- | :------ |
| `MVENDORID` | `'hF11` |
| `MARCHID`   | `'hF12` |
| `MIMPID`    | `'hF13` |
| `MHARTID`   | `'hF14` |
: Machine Information

| `Name`       | `Value` | `Observation` |
| :----------- | :------ | :------------ |
| `MSTATUS`    | `'h300` |               |
| `MISA`       | `'h301` |               |
| `MEDELEG`    | `'h302` |               |
| `MIDELEG`    | `'h303` |               |
| `MIE`        | `'h304` |               |
| `MNMIVEC`    | `'h7C0` | `NMI Vector`  |
| `MTVEC`      | `'h305` |               |
| `MCOUNTEREN` | `'h306` |               |
: Machine Trap Setup

| `Name`     | `Value` |
| :--------- | :------ |
| `MSCRATCH` | `'h340` |
| `MEPC`     | `'h341` |
| `MCAUSE`   | `'h342` |
| `MTVAL`    | `'h343` |
| `MIP`      | `'h344` |
: Machine Trap Handling

| `Name`    | `Value` | `Observation` |
| :-------- | :------ | :------------ |
| `PMPCFG0` | `'h3A0` |               |
| `PMPCFG1` | `'h3A1` | `RV32 only`   |
| `PMPCFG2` | `'h3A2` |               |
| `PMPCFG3` | `'h3A3` | `RV32 only`   |

| `Name`      | `Value` |
| :---------- | :------ |
| `PMPADDR0`  | `'h3B0` |
| `PMPADDR1`  | `'h3B1` |
| `PMPADDR2`  | `'h3B2` |
| `PMPADDR3`  | `'h3B3` |
| `PMPADDR4`  | `'h3B4` |
| `PMPADDR5`  | `'h3B5` |
| `PMPADDR6`  | `'h3B6` |
| `PMPADDR7`  | `'h3B7` |
| `PMPADDR8`  | `'h3B8` |
| `PMPADDR9`  | `'h3B9` |
| `PMPADDR10` | `'h3BA` |
| `PMPADDR11` | `'h3BB` |
| `PMPADDR12` | `'h3BC` |
| `PMPADDR13` | `'h3BD` |
| `PMPADDR14` | `'h3BE` |
| `PMPADDR15` | `'h3BF` |
: Machine Protection and Translation

| `Name`          | `Value` | `Observation`                |
| :-------------- | :------ | :--------------------------- |
| `MCYCLE`        | `'hB00` |                              |
| `MINSTRET`      | `'hB02` |                              |
| `MHPMCOUNTER3`  | `'hB03` | `until MHPMCOUNTER31='hB1F`  |
| `MCYCLEH`       | `'hB80` |                              |
| `MINSTRETH`     | `'hB82` |                              |
| `MHPMCOUNTER3H` | `'hB83` | `until MHPMCOUNTER31H='hB9F` |
: Machine Counters/Timers

| `Name`      | `Value` | `Observation`            |
| :---------- | :------ | :----------------------- |
| `MHPEVENT3` | `'h323` | `until MHPEVENT31 'h33f` |
: Machine Counter Setup

| `Name`     | `Value` |
| :--------- | :------ |
| `TSELECT`  | `'h7A0` |
| `TDATA1`   | `'h7A1` |
| `TDATA2`   | `'h7A2` |
| `TDATA3`   | `'h7A3` |
| `DCSR`     | `'h7B0` |
| `DPC`      | `'h7B1` |
| `DSCRATCH` | `'h7B2` |
: Debug

| `Name`   | `Value` |
| :------- | :------ |
| `RV32I`  | `2'b01` |
| `RV32E`  | `2'b01` |
| `RV64I`  | `2'b10` |
| `RV128I` | `2'b11` |
: MXL mapping

| `Name`  | `Value` |
| :------ | :------ |
| `PRV_M` | `2'b11` |
| `PRV_H` | `2'b10` |
| `PRV_S` | `2'b01` |
| `PRV_U` | `2'b00` |
: Privilege Levels

| `Name`     | `Value` |
| :--------- | :------ |
| `VM_MBARE` | `4'd0`  |
| `VM_SV32`  | `4'd1`  |
| `VM_SV39`  | `4'd8`  |
| `VM_SV48`  | `4'd9`  |
| `VM_SV57`  | `4'd10` |
| `VM_SV64`  | `4'd11` |
: Virtualisation

| `Name` | `Value` |
| :----- | :------ |
| `MEI`  | `11`    |
| `HEI`  | `10`    |
| `SEI`  | `9`     |
| `UEI`  | `8`     |
| `MTI`  | `7`     |
| `HTI`  | `6`     |
| `STI`  | `5`     |
| `UTI`  | `4`     |
| `MSI`  | `3`     |
| `HSI`  | `2`     |
| `SSI`  | `1`     |
| `USI`  | `0`     |
: MIE MIP

| `Name` | `Value` |
| :----- | :------ |
| `CY`   | `0`     |
| `TM`   | `1`     |
| `IR`   | `2`     |
: Performance Counters

| `Name`           | `Value` |
| :--------------- | :------ |
| `EXCEPTION_SIZE` | `16`    |

| `Name`                           | `Value` |
| :------------------------------- | :------ |
| `CAUSE_MISALIGNED_INSTRUCTION`   | `0`     |
| `CAUSE_INSTRUCTION_ACCESS_FAULT` | `1`     |
| `CAUSE_ILLEGAL_INSTRUCTION`      | `2`     |
| `CAUSE_BREAKPOINT`               | `3`     |
| `CAUSE_MISALIGNED_LOAD`          | `4`     |
| `CAUSE_LOAD_ACCESS_FAULT`        | `5`     |
| `CAUSE_MISALIGNED_STORE`         | `6`     |
| `CAUSE_STORE_ACCESS_FAULT`       | `7`     |
| `CAUSE_UMODE_ECALL`              | `8`     |
| `CAUSE_SMODE_ECALL`              | `9`     |
| `CAUSE_HMODE_ECALL`              | `10`    |
| `CAUSE_MMODE_ECALL`              | `11`    |
| `CAUSE_INSTRUCTION_PAGE_FAULT`   | `12`    |
| `CAUSE_LOAD_PAGE_FAULT`          | `13`    |
| `CAUSE_STORE_PAGE_FAULT`         | `15`    |
: Exception Causes

| `Name`        | `Value` |
| :------------ | :------ |
| `CAUSE_USINT` | `0`     |
| `CAUSE_SSINT` | `1`     |
| `CAUSE_HSINT` | `2`     |
| `CAUSE_MSINT` | `3`     |
| `CAUSE_UTINT` | `4`     |
| `CAUSE_STINT` | `5`     |
| `CAUSE_HTINT` | `6`     |
| `CAUSE_MTINT` | `7`     |
| `CAUSE_UEINT` | `8`     |
| `CAUSE_SEINT` | `9`     |
| `CAUSE_HEINT` | `10`    |
| `CAUSE_MEINT` | `11`    |
