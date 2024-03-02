## Instruction Set Extensions

Format of a line in the table:

`<prefix> <isa width> <alpha code> <instruction width> "<extension description>"`

| prefix | isa width | alpha code | instruction width | extension description                                                        |
|--------|:----------|:-----------|:------------------|:-----------------------------------------------------------------------------|
| `rv`   | `32`      | `i`        | `32`              | `RV32I Base Integer Instruction Set`                                         |
| `rv`   | `64`      | `i`        | `32`              | `RV64I Base Integer Instruction Set (+ RV32I)`                               |
| `rv`   | `128`     | `i`        | `32`              | `RV128I Base Integer Instruction Set (+ RV64I)`                              |
| `rv`   | `32`      | `m`        | `32`              | `RV32M Standard Extension for Integer Multiply and Divide`                   |
| `rv`   | `64`      | `m`        | `32`              | `RV64M Standard Extension for Integer Multiply and Divide (+ RV32M)`         |
| `rv`   | `128`     | `m`        | `32`              | `RV128M Standard Extension for Integer Multiply and Divide (+ RV64M)`        |
| `rv`   | `32`      | `a`        | `32`              | `RV32A Standard Extension for Atomic Instructions`                           |
| `rv`   | `64`      | `a`        | `32`              | `RV64A Standard Extension for Atomic Instructions (+ RV32A)`                 |
| `rv`   | `128`     | `a`        | `32`              | `RV128A Standard Extension for Atomic Instructions (+ RV64A)`                |
| `rv`   | `32`      | `s`        | `32`              | `RV32S Standard Extension for Supervisor-level Instructions`                 |
| `rv`   | `64`      | `s`        | `32`              | `RV64S Standard Extension for Supervisor-level Instructions`                 |
| `rv`   | `128`     | `s`        | `32`              | `RV128S Standard Extension for Supervisor-level Instructions`                |
| `rv`   | `32`      | `f`        | `32`              | `RV32F Standard Extension for Single-Precision Floating-Point`               |
| `rv`   | `64`      | `f`        | `32`              | `RV64F Standard Extension for Single-Precision Floating-Point (+ RV32F)`     |
| `rv`   | `128`     | `f`        | `32`              | `RV128F Standard Extension for Single-Precision Floating-Point (+ RV64F)`    |
| `rv`   | `32`      | `d`        | `32`              | `RV32D Standard Extension for Double-Precision Floating-Point`               |
| `rv`   | `64`      | `d`        | `32`              | `RV64D Standard Extension for Double-Precision Floating-Point (+ RV32D)`     |
| `rv`   | `128`     | `d`        | `32`              | `RV128D Standard Extension for Double-Precision Floating-Point (+ RV64D)`    |
| `rv`   | `32`      | `q`        | `32`              | `RV32Q Standard Extension for Quadruple-Precision Floating-Point`            |
| `rv`   | `64`      | `q`        | `32`              | `RV64Q Standard Extension for Quadruple-Precision Floating-Point (+ RV32Q)`  |
| `rv`   | `128`     | `q`        | `32`              | `RV128Q Standard Extension for Quadruple-Precision Floating-Point (+ RV64Q)` |
| `rv`   | `32`      | `c`        | `16`              | `RV32C Standard Extension for Compressed Instructions`                       |
| `rv`   | `64`      | `c`        | `16`              | `RV64C Standard Extension for Compressed Instructions (+ RV32C)`             |
| `rv`   | `128`     | `c`        | `16`              | `RV128C Standard Extension for Compressed Instructions (+ RV64C)`            |
: Instruction Set Extensions
