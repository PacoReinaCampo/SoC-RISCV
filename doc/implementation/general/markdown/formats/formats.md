# FORMATS

```sv
// Instruction Format R
typedef struct packed {
  funct7_t funct7;
  rsd_t    rs2;
  rsd_t    rs1;
  funct3_t funct3;
  rsd_t    rd;
  opcode_t opcode;
  isize_t  size;
} instruction_formatR_t;

// Instruction Format I
typedef struct packed {
  logic [11:0] imm;
  rsd_t        rs1;
  funct3_t     funct3;
  rsd_t        rsd;
  opcode_t     opcode;
  isize_t      size;
} instruction_formatI_t;

// Instruction Format S
typedef struct packed {
  logic [11:5] imm11_5;
  rsd_t        rs2;
  rsd_t        rs1;
  funct3_t     funct3;
  logic [ 4:0] imm4_0;
  opcode_t     opcode;
  isize_t      size;
} instruction_formatS_t;

// Instruction Format SB
typedef struct packed {
  logic        imm12;
  logic [10:5] imm10_5;
  rsd_t        rs2;
  rsd_t        rs1;
  funct3_t     funct3;
  logic [ 4:1] imm4_1;
  logic        imm11;
  opcode_t     opcode;
  isize_t      size;
} instruction_formatSB_t;

// Instruction Format U
typedef struct packed {
  logic [31:12] imm;
  rsd_t         rd;
  opcode_t      opcode;
  isize_t       size;
} instruction_formatU_t;

// Intruction Format UJ for JAL
typedef struct packed {
  logic         imm20;
  logic [10: 1] imm10_1;
  logic         imm11;
  logic [19:12] imm19_12;
  rsd_t         rd;
  opcode_t      opcode;
  isize_t       size;
} instruction_formatUJ_t;
```

```sv
// Instruction Format CR - Register
typedef struct packed {
  funct4_t      funct4;
  rsd_t         rd;
  rsd_t         rs2;
  isize_t       size;
} instruction_formatCR_t;

// Instruction Format CI - Immediate
typedef struct packed {
  funct3_t      funct3;
  logic         pos12;
  rsd_t         rd;
  logic [ 6: 2] pos6_2;
  isize_t       size;
} instruction_formatCI_t;

// Instruction Format CIB
typedef struct packed {
  funct3_t      funct3;
  logic         imm5;
  funct2_t      funct2;
  rsdp_t        rd;
  logic [ 4: 0] imm4_0;
  isize_t       size;
} instruction_formatCIB_t;

// Instruction Format CSS - Stack Relative Store
typedef struct packed {
  funct3_t      funct3;
  logic [12: 7] pos12_7;
  rsd_t         rs2;
  isize_t       size;
} instruction_formatCSS_t;

// Instruction Format CIW - Wide Immediate
typedef struct packed {
  funct3_t      funct3;
  logic [ 5: 4] imm5_4;
  logic [ 9: 6] imm9_6;
  logic         imm2;
  logic         imm3;
  rsdp_t        rd;
  isize_t       size;
} instruction_formatCIW_t;

// Instruction Format CL - Load
typedef struct packed {
  funct3_t      funct3;
  logic [12:10] pos12_10;
  rsdp_t        rs1;
  logic [ 6: 5] pos6_5;
  rsdp_t        rd;
  isize_t       size;
} instruction_formatCL_t;

// Instruction Format CS - Store
typedef struct packed {
  funct3_t      funct3;
  logic [12:10] pos12_10;
  rsdp_t        rs1;
  logic [ 6: 5] pos6_5;
  rsdp_t        rs2;
  isize_t       size;
} instruction_formatCS_t;

// Instruction Format CA - Arithmetic
typedef struct packed {
  funct6_t      funct6;
  rsdp_t        rs1_d;
  funct2_t      funct2;
  rsdp_t        rs2;
  isize_t       size;
} instruction_formatCA_t;

// Instruction Format CB - Branch
typedef struct packed {
  funct3_t      funct3;
  logic         imm8;
  logic [ 4: 3] imm4_3;
  rsdp_t        rs1;
  logic [ 7: 6] imm7_6;
  logic [ 2: 1] imm2_1;
  logic         imm5;
  isize_t       size;
} instruction_formatCB_t;

// Instruction Format CJ - Jump
typedef struct packed {
  funct3_t      funct3;
  logic         imm11;
  logic         imm4;
  logic [ 9: 8] imm9_8;
  logic         imm10;
  logic         imm6;
  logic         imm7;
  logic [ 3: 1] imm3_1;
  logic         imm5;
  isize_t       size;
} instruction_formatCJ_t;
```

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
