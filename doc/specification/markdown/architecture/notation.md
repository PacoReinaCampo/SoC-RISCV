## NOTATION

Throughout the RISC-V ISA documentation, the following notations are commonly used:

- `rd`, `rs1`, `rs2`, `rs3`: Destination register, source registers 1, 2, and 3, respectively.
- `imm`: Immediate value used as an operand in certain instructions.
- `funct3`, `funct7`: Fields within instructions used to differentiate between similar operations.
- `rs1`, `rs2`: Register specifiers used for source operands.
- `rd`: Register specifier used for the destination operand.
- `imm[11:0]`: Immediate value field with specific bit ranges.

Format of a line in the table:

`<symbol> <alias> <arity> <description> <LaTeX code>`

| symbol        | alias         | arity   | description             | LaTeX code   |
|---------------|:--------------|:--------|:------------------------|:-------------|
| `=`           | `==`          | `2`     | `Equal To`              | `=`          |
| `!=`          | `!=`          | `2`     | `Not Equal To`          | `\neq`       |
| `<`           | `<`           | `2`     | `Less Than`             | `<`          |
| `>`           | `>`           | `2`     | `Greater Than`          | `>`          |
| `<=`          | `<=`          | `2`     | `Less Than Equal To`    | `\leq`       |
| `>=`          | `>=`          | `2`     | `Greater Than Equal To` | `\geq`       |
| `<<`          | `<<`          | `2`     | `Shift Left`            | `\ll`        |
| `>>`          | `>>`          | `2`     | `Shift Right`           | `\gg`        |
| `=`           | `=`           | `2`     | `Assignment`            | `\leftarrow` |
| `~`           | `~`           | `1`     | `Bitwise Not`           | `\neg`       |
| `&`           | `&`           | `2`     | `Bitwise And`           | `\wedge`     |
| `\|`          | `\|`          | `2`     | `Bitwise Or`            | `\vee`       |
| `^`           | `^`           | `2`     | `Bitwise Xor`           | `\oplus`     |
| `-`           | `-`           | `1`     | `Arithmetic Negate`     | `-`          |
| `-`           | `-`           | `2`     | `Subtract`              | `-`          |
| `+`           | `+`           | `2`     | `Add`                   | `+`          |
| `*`           | `*`           | `2`     | `Multiply`              | `imes`       |
| `/`           | `/`           | `2`     | `Divide`                | `\div`       |
| `,`           | `,`           | `2`     | `In Parallel`           | `\parallel`  |
| `;`           | `;`           | `2`     | `Statement Separator`   | `,`          |
| `%`           | `%`           | `2`     | `Modulus`               | `mod`        |
| `T[x]`        | `*(T*)(x)`    | `1`     | `Memory Reference`      | `T[x]`       |
| `T(x)`        | `T(x)`        | `1`     | `Type Cast`             | `T(x)`       |
| `f(x...)`     | `f(x...)`     | `n`     | `Function Call`         | `f(x...)`    |
| `inf`         | `inf`         | `0`     | `Infinity`              | `\infty`     |

:Notation

The notation table provides a guide to the symbols, abbreviations, and conventions used in the RISC-V ISA documentation for clarity and consistency.
