# DESIGN OF INSTRUCTIONS

The RISC-V ISA features a streamlined design for its instructions, aiming to balance simplicity, efficiency, and extensibility across a wide range of computing devices. Instructions are structured to be fixed-width (32 or 64 bits) and are categorized into different types and extensions to accommodate diverse application needs.

This directory contains MetaData for the RISC-V Instruction Set Architecture

| File                           | Description                             |
|--------------------------------|:----------------------------------------|
| `extensions`                   | `Instruction Set Extensions`            |
| `types`                        | `Instruction Types`                     |
| `codecs`                       | `Instruction Encodings`                 |
| `compression`                  | `Compressed Instruction`                |
| `pseudos`                      | `Pseudo Instructions`                   |
: Instruction Directory

The instruction directory provides a comprehensive listing and categorization of all instructions defined in the RISC-V ISA, organized by their types and functionalities, facilitating easy reference and understanding of their usage.

![RV32IMAC](assets/RV32IMAC.svg){width=10cm}

RV32IMAC refers to a specific configuration within the RISC-V instruction set architecture, designed for 32-bit implementations. The acronym stands for the standard extensions supported by this configuration: I (base integer instructions), M (integer multiplication and division), A (atomic memory operations), and C (compressed instructions). The 'I' extension provides basic integer arithmetic and logic operations, essential for general-purpose computing. The 'M' extension includes instructions for multiplication and division operations, optimizing performance for mathematical computations. The 'A' extension introduces atomic memory operations, ensuring reliable and efficient handling of shared memory in concurrent applications. Lastly, the 'C' extension offers compressed instructions to reduce code size without sacrificing functionality. RV32IMAC thus combines these extensions to provide a comprehensive and versatile instruction set suitable for various embedded and general-purpose computing applications.

![RV64IMAC](assets/RV64IMAC.svg){width=10cm}

RV64IMAC refers to a specific configuration within the RISC-V instruction set architecture tailored for 64-bit implementations. The acronym denotes the standard extensions supported by this configuration: I (base integer instructions), M (integer multiplication and division), A (atomic memory operations), and C (compressed instructions). The 'I' extension encompasses fundamental integer arithmetic and logical operations essential for general-purpose computing tasks. The 'M' extension includes instructions for integer multiplication and division, crucial for computational tasks requiring higher precision and performance. The 'A' extension introduces atomic memory operations, ensuring reliable and efficient handling of shared memory in multi-threaded or concurrent applications. Lastly, the 'C' extension provides compressed instructions to reduce code size, optimizing memory usage and enhancing performance in memory-constrained environments. RV64IMAC thus integrates these extensions to offer a robust and versatile instruction set suitable for a wide range of applications, particularly those requiring 64-bit data processing capabilities.

![RV128IMAC](assets/RV128IMAC.svg){width=10cm}

RV128IMAC refers to a configuration within the RISC-V instruction set architecture specifically designed for 128-bit implementations. The acronym signifies the standard extensions supported by this configuration: I (base integer instructions), M (integer multiplication and division), A (atomic memory operations), and C (compressed instructions). The 'I' extension includes essential integer arithmetic and logical operations fundamental for general-purpose computing, now extended to support 128-bit data types. The 'M' extension encompasses instructions for integer multiplication and division, optimized for higher precision and performance in computational tasks requiring larger data sizes. The 'A' extension introduces atomic memory operations to ensure reliable and efficient handling of shared memory in concurrent applications, adapted to the 128-bit memory addressing capabilities. Lastly, the 'C' extension provides compressed instructions to reduce code size, beneficial for memory efficiency and performance optimization in resource-constrained environments. RV128IMAC thus integrates these extensions to provide a comprehensive and powerful instruction set suitable for demanding applications that leverage 128-bit data processing capabilities.

![Dependences](assets/dependences-global.svg){width=10cm}

A Multiprocessor System-on-Chip (MPSoC) is a highly integrated semiconductor device designed to incorporate multiple processing cores, specialized hardware accelerators, memory subsystems, and interconnects on a single chip. MPSoCs are engineered to efficiently execute concurrent tasks and applications by distributing workloads across multiple processing units, thereby improving performance and energy efficiency compared to traditional single-core or multi-core architectures. These systems are commonly used in applications requiring high computational throughput and real-time responsiveness, such as in embedded systems, telecommunications equipment, networking devices, automotive electronics, and multimedia processing. The architecture of an MPSoC typically includes a mix of general-purpose processors, such as CPUs or DSPs, along with application-specific processors like GPUs or accelerators tailored for specific tasks, all interconnected via advanced on-chip communication structures to enable efficient data exchange and synchronization.
