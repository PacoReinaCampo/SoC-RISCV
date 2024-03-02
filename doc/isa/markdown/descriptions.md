## Descriptions

Format of a line in the table:

`<symbol[,alias]> description>`

| symbol        | description                                             |
|---------------|:--------------------------------------------------------|
| `s8,b`        | `Signed 8-bit Byte`                                     |
| `u8,bu`       | `Unsigned 8-bit Byte`                                   |
| `s16,h`       | `Signed 16-bit Word`                                    |
| `u16,hu`      | `Unsigned 16-bit Half Word`                             |
| `s32,w`       | `Signed 32-bit Word`                                    |
| `u32,wu`      | `Unsigned 32-bit Word`                                  |
| `s64,l,d`     | `Signed 64-bit Word`                                    |
| `u64,lu`      | `Unsigned 64-bit Word`                                  |
| `s128,c,q`    | `Signed 128-bit Word` `c,cu are placeholders for fcvt`  |
| `u128,cu`     | `Unsigned 128-bit Word`                                 |
| `sx`          | `Signed Full Width Word (32, 64 or 128-bit)`            |
| `ux`          | `Unsigned Full width Word (32, 64 or 128-bit)`          |
: Word Type

| symbol        | description                                             |
|---------------|:--------------------------------------------------------|
| `f32,s`       | `Single Precision Floating-point`                       |
| `f64,d`       | `Double Precision Floating-point`                       |
| `f128,q`      | `Quadruple Precision Floating-point`                    |
: Precision Floating-point

| symbol        | description                                             |
|---------------|:--------------------------------------------------------|
| `XLEN`        | `Integer Register Width in Bits (32, 64 or 128)`        |
| `FLEN`        | `Floating-point Register Width in Bits (32, 64 or 128)` |
: Register Width in Bits

| symbol        | description                                             |
|---------------|:--------------------------------------------------------|
| `rd`          | `Integer Register Destination`                          |
| `rs[n]`       | `Integer Register Source [n]`                           |
: Integer Register

| symbol        | description                                             |
|---------------|:--------------------------------------------------------|
| `frd`         | `Floating-Point Register Destination`                   |
| `frs[n]`      | `Floating-Point Register Source [n]`                    |
: Floating-Point Register

| symbol        | description                                             |
|---------------|:--------------------------------------------------------|
| `hart`        | `hardware thread`                                       |
| `pc`          | `Program Counter`                                       |
| `imm`         | `Immediate Value encoded in an instruction`             |
| `offset`      | `Immediate Value decoded as a relative offset`          |
| `shamt`       | `Immediate Value decoded as a shift amount`             |
: Values

| symbol        | description                                             |
|---------------|:--------------------------------------------------------|
| `SP`          | `Single Precision`                                      |
| `DP`          | `Double Precision`                                      |
| `QP`          | `Quadruple Precision`                                   |
: Precision

| symbol        | description                                             |
|---------------|:--------------------------------------------------------|
| `M`           | `Machine`                                               |
| `U`           | `User`                                                  |
| `S`           | `Supervisor`                                            |
| `H`           | `Hypervisor`                                            |
: Privilege Modes I

| symbol        | description                                             |
|---------------|:--------------------------------------------------------|
| `ABI`         | `Application Binary Interface`                          |
| `AEE`         | `Application Execution Environment`                     |
| `SBI`         | `Supervisor Binary Interface`                           |
| `SEE`         | `Supervisor Execution Environment`                      |
| `HBI`         | `Hypervisor Binary Interface`                           |
| `HEE`         | `Hypervisor Execution Environment`                      |
: Privilege Modes II

| symbol        | description                                             |
|---------------|:--------------------------------------------------------|
| `CSR`         | `Control and Status Register`                           |
: Control and Status Register

| symbol        | description                                             |
|---------------|:--------------------------------------------------------|
| `PA`          | `Physical Address`                                      |
| `VA`          | `Virtual Address`                                       |
| `PPN`         | `Physical Page Number`                                  |
: Address & Page Number

| symbol        | description                                             |
|---------------|:--------------------------------------------------------|
| `ASID`        | `Address Space Identifier`                              |
| `PDID`        | `Protection Domain Identifier`                          |
| `PMA`         | `Physical Memory Attribute`                             |
| `PMP`         | `Physical Memory Protection`                            |
| `PPN`         | `Physical Page Number`                                  |
| `VPN`         | `Virtual Page Number`                                   |
| `VCLN`        | `Virtual Cache Line Number`                             |
: Physical & Virtual
