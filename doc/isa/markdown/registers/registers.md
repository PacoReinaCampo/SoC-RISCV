## REGISTERS ABI DEFINITIONS

RISC-V specifies a standard Application Binary Interface (ABI) that defines conventions for register usage across software and hardware interfaces. The ABI standardizes how registers are used for passing arguments to functions, returning values, and preserving state across function calls. It also defines callee-saved and caller-saved registers, ensuring compatibility and interoperability between different compilers and operating systems targeting RISC-V processors.

Format of a line in the table:

`<name> <alias> <type> <save> <description>`

`<type> is one of ireg, freg`

`<save> is one of caller, callee, global, zero`

| name   | alias   | type    | save      |  description                          |
|--------|:--------|:--------|:----------|:--------------------------------------|
| `x0`   | `zero`  | `ireg`  | `zero`    | `Hard-wired zero`                     |
| `x1`   | `ra`    | `ireg`  | `caller`  | `Return address Caller`               |
| `x2`   | `sp`    | `ireg`  | `callee`  | `Stack pointer Callee`                |
| `x3`   | `gp`    | `ireg`  | `global`  | `Global pointer`                      |
| `x4`   | `tp`    | `ireg`  | `callee`  | `Thread pointer Callee`               |
| `x5`   | `t0`    | `ireg`  | `caller`  | `Temporaries Caller`                  |
| `x6`   | `t1`    | `ireg`  | `caller`  | `Temporaries Caller`                  |
| `x7`   | `t2`    | `ireg`  | `caller`  | `Temporaries Caller`                  |
| `x8`   | `s0`    | `ireg`  | `callee`  | `Saved register/frame pointer Callee` |
| `x9`   | `s1`    | `ireg`  | `callee`  | `Saved registers Callee`              |
| `x10`  | `a0`    | `ireg`  | `caller`  | `Function arguments Caller`           |
| `x11`  | `a1`    | `ireg`  | `caller`  | `Function arguments Caller`           |
| `x12`  | `a2`    | `ireg`  | `caller`  | `Function arguments Caller`           |
| `x13`  | `a3`    | `ireg`  | `caller`  | `Function arguments Caller`           |
| `x14`  | `a4`    | `ireg`  | `caller`  | `Function arguments Caller`           |
| `x15`  | `a5`    | `ireg`  | `caller`  | `Function arguments Caller`           |
| `x16`  | `a6`    | `ireg`  | `caller`  | `Function arguments Caller`           |
| `x17`  | `a7`    | `ireg`  | `caller`  | `Function arguments Caller`           |
| `x18`  | `s2`    | `ireg`  | `callee`  | `Saved registers Callee`              |
| `x19`  | `s3`    | `ireg`  | `callee`  | `Saved registers Callee`              |
| `x20`  | `s4`    | `ireg`  | `callee`  | `Saved registers Callee`              |
| `x21`  | `s5`    | `ireg`  | `callee`  | `Saved registers Callee`              |
| `x22`  | `s6`    | `ireg`  | `callee`  | `Saved registers Callee`              |
| `x23`  | `s7`    | `ireg`  | `callee`  | `Saved registers Callee`              |
| `x24`  | `s8`    | `ireg`  | `callee`  | `Saved registers Callee`              |
| `x25`  | `s9`    | `ireg`  | `callee`  | `Saved registers Callee`              |
| `x26`  | `s10`   | `ireg`  | `callee`  | `Saved registers Callee`              |
| `x27`  | `s11`   | `ireg`  | `callee`  | `Saved registers Callee`              |
| `x28`  | `t3`    | `ireg`  | `caller`  | `Temporaries Caller`                  |
| `x29`  | `t4`    | `ireg`  | `caller`  | `Temporaries Caller`                  |
| `x30`  | `t5`    | `ireg`  | `caller`  | `Temporaries Caller`                  |
| `x31`  | `t6`    | `ireg`  | `caller`  | `Temporaries Caller`                  |

:Base Registers

| name   | alias   | type    | save      |  description                          |
|--------|:--------|:--------|:----------|:--------------------------------------|
| `f0`   | `ft0`   | `freg`  | `caller`  | `FP temporaries Caller`               |
| `f1`   | `ft1`   | `freg`  | `caller`  | `FP temporaries Caller`               |
| `f2`   | `ft2`   | `freg`  | `caller`  | `FP temporaries Caller`               |
| `f3`   | `ft3`   | `freg`  | `caller`  | `FP temporaries Caller`               |
| `f4`   | `ft4`   | `freg`  | `caller`  | `FP temporaries Caller`               |
| `f5`   | `ft5`   | `freg`  | `caller`  | `FP temporaries Caller`               |
| `f6`   | `ft6`   | `freg`  | `caller`  | `FP temporaries Caller`               |
| `f7`   | `ft7`   | `freg`  | `caller`  | `FP temporaries Caller`               |
| `f8`   | `fs0`   | `freg`  | `callee`  | `FP saved registers Callee`           |
| `f9`   | `fs1`   | `freg`  | `callee`  | `FP saved registers Callee`           |
| `f10`  | `fa0`   | `freg`  | `caller`  | `FP arguments Caller`                 |
| `f11`  | `fa1`   | `freg`  | `caller`  | `FP arguments Caller`                 |
| `f12`  | `fa2`   | `freg`  | `caller`  | `FP arguments Caller`                 |
| `f13`  | `fa3`   | `freg`  | `caller`  | `FP arguments Caller`                 |
| `f14`  | `fa4`   | `freg`  | `caller`  | `FP arguments Caller`                 |
| `f15`  | `fa5`   | `freg`  | `caller`  | `FP arguments Caller`                 |
| `f16`  | `fa6`   | `freg`  | `caller`  | `FP arguments Caller`                 |
| `f17`  | `fa7`   | `freg`  | `caller`  | `FP arguments Caller`                 |
| `f18`  | `fs2`   | `freg`  | `callee`  | `FP saved registers Callee`           |
| `f19`  | `fs3`   | `freg`  | `callee`  | `FP saved registers Callee`           |
| `f20`  | `fs4`   | `freg`  | `callee`  | `FP saved registers Callee`           |
| `f21`  | `fs5`   | `freg`  | `callee`  | `FP saved registers Callee`           |
| `f22`  | `fs6`   | `freg`  | `callee`  | `FP saved registers Callee`           |
| `f23`  | `fs7`   | `freg`  | `callee`  | `FP saved registers Callee`           |
| `f24`  | `fs8`   | `freg`  | `callee`  | `FP saved registers Callee`           |
| `f25`  | `fs9`   | `freg`  | `callee`  | `FP saved registers Callee`           |
| `f26`  | `fs10`  | `freg`  | `callee`  | `FP saved registers Callee`           |
| `f27`  | `fs11`  | `freg`  | `callee`  | `FP saved registers Callee`           |
| `f28`  | `ft8`   | `freg`  | `caller`  | `FP temporaries Caller`               |
| `f29`  | `ft9`   | `freg`  | `caller`  | `FP temporaries Caller`               |
| `f30`  | `ft10`  | `freg`  | `caller`  | `FP temporaries Caller`               |
| `f31`  | `ft11`  | `freg`  | `caller`  | `FP temporaries Caller`               |

:Float-Point Registers
