## TRAPS

Format of a line in the table:

`<csr number> <csr access> <csr name> "<csr description>" <version>`

`<access> is one of urw, uro, srw, sro, hrw, hro, mrw, mro`

`<version> is [introduced]-[deprecated]`

| number   | access | name              | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x000`  | `urw`  | `ustatus`         | `User status register`                            | `1.9-`           |
| `0x004`  | `urw`  | `uie`             | `User interrupt-enable register`                  | `1.9-`           |
| `0x005`  | `urw`  | `utvec`           | `User trap handler base address`                  | `1.9-`           |

:User Trap Setup

The configuration and setup details for traps and exceptions at the user level in the RISC-V architecture.

| number   | access | name              | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x040`  | `urw`  | `uscratch`        | `Scratch handler for user trap handlers`          | `1.9-`           |
| `0x041`  | `urw`  | `uepc`            | `User exception program counter`                  | `1.9-`           |
| `0x042`  | `urw`  | `ucause`          | `User trap cause`                                 | `1.9-`           |
| `0x043`  | `urw`  | `ubadaddr`        | `User bad address`                                | `1.7-1.9.1`      |
| `0x043`  | `urw`  | `utval`           | `User bad address or instruction`                 | `1.10-`          |
| `0x044`  | `urw`  | `uip`             | `User interrupt pending`                          | `1.9-`           |

:User Trap Handling

Details in this table cover how traps and exceptions are handled specifically within the user privilege level of the RISC-V ISA.

| number   | access | name              | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x100`  | `srw`  | `sstatus`         | `Supervisor status register`                      | `1.7-`           |
| `0x102`  | `srw`  | `sedeleg`         | `Supervisor exception delegation register`        | `1.9-`           |
| `0x103`  | `srw`  | `sideleg`         | `Supervisor interrupt delegation register`        | `1.9-`           |
| `0x104`  | `src`  | `sie`             | `Supervisor interrupt-enable register`            | `1.7-`           |
| `0x105`  | `srw`  | `stvec`           | `Supervisor trap handler base address`            | `1.7-`           |
| `0x106`  | `swr`  | `scounteren`      | `Supervisor counter enable`                       | `1.10-`          |

:Supervisor Trap Setup

Configuration specifics for traps and exceptions at the supervisor privilege level are detailed in this part of the RISC-V ISA documentation.

| number   | access | name              | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x140`  | `srw`  | `sscratch`        | `Scratch register for supervisor trap handlers`   | `1.7-`           |
| `0x141`  | `srw`  | `sepc`            | `Supervisor exception program counter`            | `1.7-`           |
| `0x142`  | `srw`  | `scause`          | `Supervisor trap cause`                           | `1.7-`           |
| `0x143`  | `srw`  | `sbadaddr`        | `Supervisor bad address`                          | `1.7-1.9.1`      |
| `0x143`  | `srw`  | `stval`           | `Supervisor bad address or instruction`           | `1.10-`          |
| `0x144`  | `srw`  | `sip`             | `Supervisor interrupt pending`                    | `1.7-`           |

:Supervisor Trap Handling

The procedures and mechanisms for handling traps and exceptions at the supervisor privilege level are documented comprehensively.

| number   | access | name              | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x200`  | `hrw`  | `hstatus`         | `Hypervisor status register`                      | `1.7-1.9.1`      |
| `0x202`  | `mrw`  | `hedeleg`         | `Hypervisor exception delegation register`        | `1.9-1.9.1`      |
| `0x203`  | `mrw`  | `hideleg`         | `Hypervisor interrupt delegation register`        | `1.9-1.9.1`      |
| `0x204`  | `mrw`  | `hie`             | `Hypervisor interrupt-enable register`            | `1.7-1.9.1`      |
| `0x205`  | `hrw`  | `htvec`           | `Hypervisor trap handler base address`            | `1.7-1.9.1`      |

:Hypervisor Trap Setup

Configuration details for traps and exceptions in the context of hypervisor mode are detailed in this part of the RISC-V ISA documentation.

| number   | access | name              | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x240`  | `hrw`  | `hscratch`        | `Scratch register for hypervisor trap handlers`   | `1.7-1.9.1`      |
| `0x241`  | `hrw`  | `hepc`            | `Hypervisor exception program counter`            | `1.7-1.9.1`      |
| `0x242`  | `hrw`  | `hcause`          | `Hypervisor trap cause`                           | `1.7-1.9.1`      |
| `0x243`  | `hrw`  | `hbadaddr`        | `Hypervisor bad address`                          | `1.7-1.9.1`      |
| `0x244`  | `hrw`  | `hip`             | `Hypervisor interrupt pending`                    | `1.7-1.9.1`      |

:Hypervisor Trap Handling

The procedures and methods for handling traps and exceptions in hypervisor mode are outlined and explained in this section.

| number   | access | name              | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x300`  | `mrw`  | `mstatus`         | `Machine status register`                         | `1.7-`           |
| `0x301`  | `mrw`  | `misa`            | `ISA and extensions supported`                    | `1.7-`           |
| `0x302`  | `mrw`  | `medeleg`         | `Machine exception delegation register`           | `1.9-`           |
| `0x303`  | `mrw`  | `mideleg`         | `Machine interrupt delegation register`           | `1.9-`           |
| `0x304`  | `mrw`  | `mie`             | `Machine interrupt-enable register`               | `1.7-`           |
| `0x305`  | `mrw`  | `mtvec`           | `Machine trap-handler base address`               | `1.7-`           |
| `0x306`  | `mrw`  | `mcounteren`      | `Machine counter enable`                          | `1.10-`          |

:Machine Trap Setup

Configuration specifics for setting up traps and exceptions at the machine privilege level are detailed in this part of the RISC-V ISA documentation.

| number   | access | name              | description                                       | version          |
|----------|:-------|:------------------|:--------------------------------------------------|:-----------------|
| `0x340`  | `mrw`  | `mscratch`        | `Scratch register for machine trap handlers`      | `1.7-`           |
| `0x341`  | `mrw`  | `mepc`            | `Machine exception program counter`               | `1.7-`           |
| `0x342`  | `mrw`  | `mcause`          | `Machine trap cause`                              | `1.7-`           |
| `0x343`  | `mrw`  | `mbadaddr`        | `Machine bad address`                             | `1.7-1.9.1`      |
| `0x343`  | `mrw`  | `mtval`           | `Machine bad address or instruction`              | `1.10-`          |
| `0x344`  | `mrw`  | `mip`             | `Machine interrupt pending`                       | `1.7-`           |
| `0x3A0`  | `mrw`  | `pmpcfg0`         | `Physical memory protection configuration`        | `1.10-`          |
| `0x3A1`  | `mrw`  | `pmpcfg1`         | `Physical memory protection configuration (RV32)` | `1.10-`          |
| `0x3A2`  | `mrw`  | `pmpcfg2`         | `Physical memory protection configuration`        | `1.10-`          |
| `0x3A3`  | `mrw`  | `pmpcfg3`         | `Physical memory protection configuration (RV32)` | `1.10-`          |
| `0x3B0`  | `mrw`  | `pmpaddr0`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B1`  | `mrw`  | `pmpaddr1`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B2`  | `mrw`  | `pmpaddr2`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B3`  | `mrw`  | `pmpaddr3`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B4`  | `mrw`  | `pmpaddr4`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B5`  | `mrw`  | `pmpaddr5`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B6`  | `mrw`  | `pmpaddr6`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B7`  | `mrw`  | `pmpaddr7`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B8`  | `mrw`  | `pmpaddr8`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3B9`  | `mrw`  | `pmpaddr9`        | `Physical memory protection address register`     | `1.10-`          |
| `0x3BA`  | `mrw`  | `pmpaddr10`       | `Physical memory protection address register`     | `1.10-`          |
| `0x3BB`  | `mrw`  | `pmpaddr11`       | `Physical memory protection address register`     | `1.10-`          |
| `0x3BC`  | `mrw`  | `pmpaddr12`       | `Physical memory protection address register`     | `1.10-`          |
| `0x3BE`  | `mrw`  | `pmpaddr13`       | `Physical memory protection address register`     | `1.10-`          |
| `0x3BD`  | `mrw`  | `pmpaddr14`       | `Physical memory protection address register`     | `1.10-`          |
| `0x3BF`  | `mrw`  | `pmpaddr15`       | `Physical memory protection address register`     | `1.10-`          |

:Machine Trap Handling

This section covers the handling mechanisms and procedures for traps and exceptions at the machine privilege level of the RISC-V ISA.
