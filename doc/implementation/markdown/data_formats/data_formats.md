# DATA FORMATS

## MAIN

### PU RISCV CORE

## FETCH

### PU RISCV IF

## DECODE

### PU RISCV ID

## EXECUTE

### PU RISCV EXECUTION
### PU RISCV ALU
### PU RISCV LSU
### PU RISCV BU
### PU RISCV MULTIPLIER
### PU RISCV DIVIDER

## MEMORY

| `Name`           | `Value` |
| :--------------- | :------ |
| `MEM_TYPE_EMPTY` | `2'h0`  |
| `MEM_TYPE_MAIN`  | `2'h1`  |
| `MEM_TYPE_IO`    | `2'h2`  |
| `MEM_TYPE_TCM`   | `2'h3`  |

| `Name`                | `Value` |
| :-------------------- | :------ |
| `AMO_TYPE_NONE`       | `2'h0`  |
| `AMO_TYPE_SWAP`       | `2'h1`  |
| `AMO_TYPE_LOGICAL`    | `2'h2`  |
| `AMO_TYPE_ARITHMETIC` | `2'h3`  |

### PU RISCV MEMORY

## CONTROL

### PU RISCV STATE
### PU RISCV BP
### PU RISCV DU

## PERIPHERAL

### PU RISCV DCACHE-CORE
### PU RISCV DMEM-CTRL
### PU RISCV ICACHE-CORE
### PU RISCV IMEM-CTRL
