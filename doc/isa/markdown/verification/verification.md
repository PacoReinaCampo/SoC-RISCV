# VERIFICATION OF INSTRUCTIONS

This directory contains MetaData for the RISC-V Instruction Set Architecture

| File                           | Description                             |
|--------------------------------|:----------------------------------------|
| `test`                         | `Test for Verification`                 |

:Verification Directory

The verification directory serves as a comprehensive reference for verifying the correctness and compliance of implementations with the RISC-V ISA specifications, detailing test cases, validation methods, and compliance criteria.

| `Architecture 32 bit`    | `PU`           | `SoC`           | `MPSoC`          |
|--------------------------|:---------------|:----------------|:-----------------|
| `Base ISA`               | `rv32-p-i`     | `rv32-pv-i`     | `rv32-pvt-i`     |
| `Standard ISA`           | `rv32-p-imac`  | `rv32-pv-imac`  | `rv32-pvt-imac`  |

:Architecture 32 bit

This table summarizes the key architectural features and specifications specific to the 32-bit implementation of the RISC-V ISA, including addressing modes, register sizes, and instruction formats tailored for 32-bit processors.

| `Architecture 64 bit`    | `PU`           | `SoC`           | `MPSoC`          |
|--------------------------|:---------------|:----------------|:-----------------|
| `Base ISA`               | `rv64-p-i`     | `rv64-pv-i`     | `rv64-pvt-i`     |
| `Standard ISA`           | `rv64-p-imac`  | `rv64-pv-imac`  | `rv64-pvt-imac`  |

:Architecture 64 bit

The table outlines the architectural enhancements and specifications unique to the 64-bit implementation of the RISC-V ISA, such as extended addressing capabilities, larger register files, and support for wider data paths.

| `Architecture 128 bit`   | `PU`            | `SoC`            | `MPSoC`           |
|--------------------------|:----------------|:-----------------|:------------------|
| `Base ISA`               | `rv128-p-i`     | `rv128-pv-i`     | `rv128-pvt-i`     |
| `Standard ISA`           | `rv128-p-imac`  | `rv128-pv-imac`  | `rv128-pvt-imac`  |

:Architecture 128 bit

This table describes the architectural considerations and extensions necessary for implementing the RISC-V ISA on processors with 128-bit address spaces, accommodating larger memory capacities and addressing requirements.
