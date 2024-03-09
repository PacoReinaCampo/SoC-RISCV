## Test

Format of a line in the table:

`<test>`

| test rv32                | status      |
|--------------------------|:------------|
| `rv32ui-p-add`           | `passed`    |
| `rv32ui-p-addi`          | `passed`    |
| `rv32ui-p-and`           | `passed`    |
| `rv32ui-p-andi`          | `passed`    |
| `rv32ui-p-auipc`         | `passed`    |
| `rv32ui-p-beq`           | `passed`    |
| `rv32ui-p-bge`           | `passed`    |
| `rv32ui-p-bgeu`          | `passed`    |
| `rv32ui-p-blt`           | `passed`    |
| `rv32ui-p-bltu`          | `passed`    |
| `rv32ui-p-bne`           | `passed`    |
| `rv32ui-p-fence_i`       | `passed`    |
| `rv32ui-p-jal`           | `passed`    |
| `rv32ui-p-jalr`          | `passed`    |
| `rv32ui-p-lb`            | `passed`    |
| `rv32ui-p-lbu`           | `passed`    |
| `rv32ui-p-lh`            | `passed`    |
| `rv32ui-p-lhu`           | `passed`    |
| `rv32ui-p-lui`           | `passed`    |
| `rv32ui-p-lw`            | `passed`    |
| `rv32ui-p-ma_data`       | `no passed` |
| `rv32ui-p-or`            | `passed`    |
| `rv32ui-p-ori`           | `passed`    |
| `rv32ui-p-sb`            | `passed`    |
| `rv32ui-p-sh`            | `passed`    |
| `rv32ui-p-simple`        | `passed`    |
| `rv32ui-p-sll`           | `passed`    |
| `rv32ui-p-slli`          | `passed`    |
| `rv32ui-p-slt`           | `passed`    |
| `rv32ui-p-slti`          | `passed`    |
| `rv32ui-p-sltiu`         | `passed`    |
| `rv32ui-p-sltu`          | `passed`    |
| `rv32ui-p-sra`           | `passed`    |
| `rv32ui-p-srai`          | `passed`    |
| `rv32ui-p-srl`           | `passed`    |
| `rv32ui-p-srli`          | `passed`    |
| `rv32ui-p-sub`           | `passed`    |
| `rv32ui-p-sw`            | `passed`    |
| `rv32ui-p-xor`           | `passed`    |
| `rv32ui-p-xori`          | `passed`    |
| `rv32ui-v-add`           | `no passed` |
| `rv32ui-v-addi`          | `no passed` |
| `rv32ui-v-and`           | `no passed` |
| `rv32ui-v-andi`          | `no passed` |
| `rv32ui-v-auipc`         | `no passed` |
| `rv32ui-v-beq`           | `no passed` |
| `rv32ui-v-bge`           | `no passed` |
| `rv32ui-v-bgeu`          | `no passed` |
| `rv32ui-v-blt`           | `no passed` |
| `rv32ui-v-bltu`          | `no passed` |
| `rv32ui-v-bne`           | `no passed` |
| `rv32ui-v-fence_i`       | `no passed` |
| `rv32ui-v-jal`           | `no passed` |
| `rv32ui-v-jalr`          | `no passed` |
| `rv32ui-v-lb`            | `no passed` |
| `rv32ui-v-lbu`           | `no passed` |
| `rv32ui-v-lh`            | `no passed` |
| `rv32ui-v-lhu`           | `no passed` |
| `rv32ui-v-lui`           | `no passed` |
| `rv32ui-v-lw`            | `no passed` |
| `rv32ui-v-ma_data`       | `no passed` |
| `rv32ui-v-or`            | `no passed` |
| `rv32ui-v-ori`           | `no passed` |
| `rv32ui-v-sb`            | `no passed` |
| `rv32ui-v-sh`            | `no passed` |
| `rv32ui-v-simple`        | `no passed` |
| `rv32ui-v-sll`           | `no passed` |
| `rv32ui-v-slli`          | `no passed` |
| `rv32ui-v-slt`           | `no passed` |
| `rv32ui-v-slti`          | `no passed` |
| `rv32ui-v-sltiu`         | `no passed` |
| `rv32ui-v-sltu`          | `no passed` |
| `rv32ui-v-sra`           | `no passed` |
| `rv32ui-v-srai`          | `no passed` |
| `rv32ui-v-srl`           | `no passed` |
| `rv32ui-v-srli`          | `no passed` |
| `rv32ui-v-sub`           | `no passed` |
| `rv32ui-v-sw`            | `no passed` |
| `rv32ui-v-xor`           | `no passed` |
| `rv32ui-v-xori`          | `no passed` |
: RV32I - "RV32I Base Integer Instruction Set"

| test rv64                | status      |
|--------------------------|:------------|
| `rv64ui-p-add`           | `passed`    |
| `rv64ui-p-addi`          | `passed`    |
| `rv64ui-p-addiw`         | `passed`    |
| `rv64ui-p-addw`          | `passed`    |
| `rv64ui-p-and`           | `passed`    |
| `rv64ui-p-andi`          | `passed`    |
| `rv64ui-p-auipc`         | `passed`    |
| `rv64ui-p-beq`           | `passed`    |
| `rv64ui-p-bge`           | `passed`    |
| `rv64ui-p-bgeu`          | `passed`    |
| `rv64ui-p-blt`           | `passed`    |
| `rv64ui-p-bltu`          | `passed`    |
| `rv64ui-p-bne`           | `passed`    |
| `rv64ui-p-fence_i`       | `?`         |
| `rv64ui-p-jal`           | `passed`    |
| `rv64ui-p-jalr`          | `passed`    |
| `rv64ui-p-lb`            | `?`         |
| `rv64ui-p-lbu`           | `?`         |
| `rv64ui-p-ld`            | `?`         |
| `rv64ui-p-lh`            | `?`         |
| `rv64ui-p-lhu`           | `?`         |
| `rv64ui-p-lui`           | `passed`    |
| `rv64ui-p-lw`            | `?`         |
| `rv64ui-p-lwu`           | `?`         |
| `rv64ui-p-ma_data`       | `no passed` |
| `rv64ui-p-or`            | `passed`    |
| `rv64ui-p-ori`           | `passed`    |
| `rv64ui-p-sb`            | `?`         |
| `rv64ui-p-sd`            | `?`         |
| `rv64ui-p-sh`            | `?`         |
| `rv64ui-p-simple`        | `passed`    |
| `rv64ui-p-sll`           | `passed`    |
| `rv64ui-p-slli`          | `passed`    |
| `rv64ui-p-slliw`         | `passed`    |
| `rv64ui-p-sllw`          | `passed`    |
| `rv64ui-p-slt`           | `passed`    |
| `rv64ui-p-slti`          | `passed`    |
| `rv64ui-p-sltiu`         | `passed`    |
| `rv64ui-p-sltu`          | `passed`    |
| `rv64ui-p-sra`           | `passed`    |
| `rv64ui-p-srai`          | `passed`    |
| `rv64ui-p-sraiw`         | `passed`    |
| `rv64ui-p-sraw`          | `passed`    |
| `rv64ui-p-srl`           | `passed`    |
| `rv64ui-p-srli`          | `passed`    |
| `rv64ui-p-srliw`         | `passed`    |
| `rv64ui-p-srlw`          | `passed`    |
| `rv64ui-p-sub`           | `passed`    |
| `rv64ui-p-subw`          | `passed`    |
| `rv64ui-p-sw`            | `no passed` |
| `rv64ui-p-xor`           | `passed`    |
| `rv64ui-p-xori`          | `passed`    |
| `rv64ui-v-add`           | `no passed` |
| `rv64ui-v-addi`          | `no passed` |
| `rv64ui-v-addiw`         | `no passed` |
| `rv64ui-v-addw`          | `no passed` |
| `rv64ui-v-and`           | `no passed` |
| `rv64ui-v-andi`          | `no passed` |
| `rv64ui-v-auipc`         | `no passed` |
| `rv64ui-v-beq`           | `no passed` |
| `rv64ui-v-bge`           | `no passed` |
| `rv64ui-v-bgeu`          | `no passed` |
| `rv64ui-v-blt`           | `no passed` |
| `rv64ui-v-bltu`          | `no passed` |
| `rv64ui-v-bne`           | `no passed` |
| `rv64ui-v-fence_i`       | `no passed` |
| `rv64ui-v-jal`           | `no passed` |
| `rv64ui-v-jalr`          | `no passed` |
| `rv64ui-v-lb`            | `no passed` |
| `rv64ui-v-lbu`           | `no passed` |
| `rv64ui-v-ld`            | `no passed` |
| `rv64ui-v-lh`            | `no passed` |
| `rv64ui-v-lhu`           | `no passed` |
| `rv64ui-v-lui`           | `no passed` |
| `rv64ui-v-lw`            | `no passed` |
| `rv64ui-v-lwu`           | `no passed` |
| `rv64ui-v-ma_data`       | `no passed` |
| `rv64ui-v-or`            | `no passed` |
| `rv64ui-v-ori`           | `no passed` |
| `rv64ui-v-sb`            | `no passed` |
| `rv64ui-v-sd`            | `no passed` |
| `rv64ui-v-sh`            | `no passed` |
| `rv64ui-v-simple`        | `no passed` |
| `rv64ui-v-sll`           | `no passed` |
| `rv64ui-v-slli`          | `no passed` |
| `rv64ui-v-slliw`         | `no passed` |
| `rv64ui-v-sllw`          | `no passed` |
| `rv64ui-v-slt`           | `no passed` |
| `rv64ui-v-slti`          | `no passed` |
| `rv64ui-v-sltiu`         | `no passed` |
| `rv64ui-v-sltu`          | `no passed` |
| `rv64ui-v-sra`           | `no passed` |
| `rv64ui-v-srai`          | `no passed` |
| `rv64ui-v-sraiw`         | `no passed` |
| `rv64ui-v-sraw`          | `no passed` |
| `rv64ui-v-srl`           | `no passed` |
| `rv64ui-v-srli`          | `no passed` |
| `rv64ui-v-srliw`         | `no passed` |
| `rv64ui-v-srlw`          | `no passed` |
| `rv64ui-v-sub`           | `no passed` |
| `rv64ui-v-subw`          | `no passed` |
| `rv64ui-v-sw`            | `no passed` |
| `rv64ui-v-xor`           | `no passed` |
| `rv64ui-v-xori`          | `no passed` |
: RV64I - "RV64I Base Integer Instruction Set (+ RV32I)"

| test rv32                | status      |
|--------------------------|:------------|
| `rv32um-p-div`           | `passed`    |
| `rv32um-p-divu`          | `passed`    |
| `rv32um-p-mul`           | `passed`    |
| `rv32um-p-mulh`          | `passed`    |
| `rv32um-p-mulhsu`        | `passed`    |
| `rv32um-p-mulhu`         | `passed`    |
| `rv32um-p-rem`           | `passed`    |
| `rv32um-p-remu`          | `passed`    |
| `rv32um-v-div`           | `no passed` |
| `rv32um-v-divu`          | `no passed` |
| `rv32um-v-mul`           | `no passed` |
| `rv32um-v-mulh`          | `no passed` |
| `rv32um-v-mulhsu`        | `no passed` |
| `rv32um-v-mulhu`         | `no passed` |
| `rv32um-v-rem`           | `no passed` |
| `rv32um-v-remu`          | `no passed` |
: RV32M - "RV32M Standard Extension for Integer Multiply and Divide"

| test rv64                | status      |
|--------------------------|:------------|
| `rv64um-p-div`           | `passed`    |
| `rv64um-p-divu`          | `passed`    |
| `rv64um-p-divuw`         | `passed`    |
| `rv64um-p-divw`          | `passed`    |
| `rv64um-p-mul`           | `passed`    |
| `rv64um-p-mulh`          | `passed`    |
| `rv64um-p-mulhsu`        | `passed`    |
| `rv64um-p-mulhu`         | `passed`    |
| `rv64um-p-mulw`          | `passed`    |
| `rv64um-p-rem`           | `passed`    |
| `rv64um-p-remu`          | `passed`    |
| `rv64um-p-remuw`         | `passed`    |
| `rv64um-p-remw`          | `passed`    |
| `rv64um-v-div`           | `no passed` |
| `rv64um-v-divu`          | `no passed` |
| `rv64um-v-divuw`         | `no passed` |
| `rv64um-v-divw`          | `no passed` |
| `rv64um-v-mul`           | `no passed` |
| `rv64um-v-mulh`          | `no passed` |
| `rv64um-v-mulhsu`        | `no passed` |
| `rv64um-v-mulhu`         | `no passed` |
| `rv64um-v-mulw`          | `no passed` |
| `rv64um-v-rem`           | `no passed` |
| `rv64um-v-remu`          | `no passed` |
| `rv64um-v-remuw`         | `no passed` |
| `rv64um-v-remw`          | `no passed` |
: RV64M - "RV64M Standard Extension for Integer Multiply and Divide (+ RV32M)"

| test rv32                | status      |
|--------------------------|:------------|
| `rv32ua-p-amoadd_w`      | `no passed` |
| `rv32ua-p-amoand_w`      | `no passed` |
| `rv32ua-p-amomaxu_w`     | `no passed` |
| `rv32ua-p-amomax_w`      | `no passed` |
| `rv32ua-p-amominu_w`     | `no passed` |
| `rv32ua-p-amomin_w`      | `no passed` |
| `rv32ua-p-amoor_w`       | `no passed` |
| `rv32ua-p-amoswap_w`     | `no passed` |
| `rv32ua-p-amoxor_w`      | `no passed` |
| `rv32ua-p-lrsc`          | `no passed` |
| `rv32ua-v-amoadd_w`      | `no passed` |
| `rv32ua-v-amoand_w`      | `no passed` |
| `rv32ua-v-amomaxu_w`     | `no passed` |
| `rv32ua-v-amomax_w`      | `no passed` |
| `rv32ua-v-amominu_w`     | `no passed` |
| `rv32ua-v-amomin_w`      | `no passed` |
| `rv32ua-v-amoor_w`       | `no passed` |
| `rv32ua-v-amoswap_w`     | `no passed` |
| `rv32ua-v-amoxor_w`      | `no passed` |
| `rv32ua-v-lrsc`          | `no passed` |
: RV32A - "RV32A Standard Extension for Atomic Instructions"

| test rv64                | status      |
|--------------------------|:------------|
| `rv64ua-p-amoadd_d`      | `no passed` |
| `rv64ua-p-amoadd_w`      | `no passed` |
| `rv64ua-p-amoand_d`      | `no passed` |
| `rv64ua-p-amoand_w`      | `no passed` |
| `rv64ua-p-amomax_d`      | `no passed` |
| `rv64ua-p-amomaxu_d`     | `no passed` |
| `rv64ua-p-amomaxu_w`     | `no passed` |
| `rv64ua-p-amomax_w`      | `no passed` |
| `rv64ua-p-amomin_d`      | `no passed` |
| `rv64ua-p-amominu_d`     | `no passed` |
| `rv64ua-p-amominu_w`     | `no passed` |
| `rv64ua-p-amomin_w`      | `no passed` |
| `rv64ua-p-amoor_d`       | `no passed` |
| `rv64ua-p-amoor_w`       | `no passed` |
| `rv64ua-p-amoswap_d`     | `no passed` |
| `rv64ua-p-amoswap_w`     | `no passed` |
| `rv64ua-p-amoxor_d`      | `no passed` |
| `rv64ua-p-amoxor_w`      | `no passed` |
| `rv64ua-p-lrsc`          | `no passed` |
| `rv64ua-v-amoadd_d`      | `no passed` |
| `rv64ua-v-amoadd_w`      | `no passed` |
| `rv64ua-v-amoand_d`      | `no passed` |
| `rv64ua-v-amoand_w`      | `no passed` |
| `rv64ua-v-amomax_d`      | `no passed` |
| `rv64ua-v-amomaxu_d`     | `no passed` |
| `rv64ua-v-amomaxu_w`     | `no passed` |
| `rv64ua-v-amomax_w`      | `no passed` |
| `rv64ua-v-amomin_d`      | `no passed` |
| `rv64ua-v-amominu_d`     | `no passed` |
| `rv64ua-v-amominu_w`     | `no passed` |
| `rv64ua-v-amomin_w`      | `no passed` |
| `rv64ua-v-amoor_d`       | `no passed` |
| `rv64ua-v-amoor_w`       | `no passed` |
| `rv64ua-v-amoswap_d`     | `no passed` |
| `rv64ua-v-amoswap_w`     | `no passed` |
| `rv64ua-v-amoxor_d`      | `no passed` |
| `rv64ua-v-amoxor_w`      | `no passed` |
| `rv64ua-v-lrsc`          | `no passed` |
: RV64A - "RV64A Standard Extension for Atomic Instructions (+ RV32A)"

| test rv32                | status      |
|--------------------------|:------------|
| `rv32uf-p-fadd`          | `no passed` |
| `rv32uf-p-fclass`        | `no passed` |
| `rv32uf-p-fcmp`          | `no passed` |
| `rv32uf-p-fcvt`          | `no passed` |
| `rv32uf-p-fcvt_w`        | `no passed` |
| `rv32uf-p-fdiv`          | `no passed` |
| `rv32uf-p-fmadd`         | `no passed` |
| `rv32uf-p-fmin`          | `no passed` |
| `rv32uf-p-ldst`          | `no passed` |
| `rv32uf-p-move`          | `no passed` |
| `rv32uf-p-recoding`      | `no passed` |
| `rv32uf-v-fadd`          | `no passed` |
| `rv32uf-v-fclass`        | `no passed` |
| `rv32uf-v-fcmp`          | `no passed` |
| `rv32uf-v-fcvt`          | `no passed` |
| `rv32uf-v-fcvt_w`        | `no passed` |
| `rv32uf-v-fdiv`          | `no passed` |
| `rv32uf-v-fmadd`         | `no passed` |
| `rv32uf-v-fmin`          | `no passed` |
| `rv32uf-v-ldst`          | `no passed` |
| `rv32uf-v-move`          | `no passed` |
| `rv32uf-v-recoding`      | `no passed` |
: RV32F - "RV32F Standard Extension for Single-Precision Floating-Point"

| test rv64                | status      |
|--------------------------|:------------|
| `rv64uf-p-fadd`          | `no passed` |
| `rv64uf-p-fclass`        | `no passed` |
| `rv64uf-p-fcmp`          | `no passed` |
| `rv64uf-p-fcvt`          | `no passed` |
| `rv64uf-p-fcvt_w`        | `no passed` |
| `rv64uf-p-fdiv`          | `no passed` |
| `rv64uf-p-fmadd`         | `no passed` |
| `rv64uf-p-fmin`          | `no passed` |
| `rv64uf-p-ldst`          | `no passed` |
| `rv64uf-p-move`          | `no passed` |
| `rv64uf-p-recoding`      | `no passed` |
| `rv64uf-v-fadd`          | `no passed` |
| `rv64uf-v-fclass`        | `no passed` |
| `rv64uf-v-fcmp`          | `no passed` |
| `rv64uf-v-fcvt`          | `no passed` |
| `rv64uf-v-fcvt_w`        | `no passed` |
| `rv64uf-v-fdiv`          | `no passed` |
| `rv64uf-v-fmadd`         | `no passed` |
| `rv64uf-v-fmin`          | `no passed` |
| `rv64uf-v-ldst`          | `no passed` |
| `rv64uf-v-move`          | `no passed` |
| `rv64uf-v-recoding`      | `no passed` |
: RV64F - "RV64F Standard Extension for Single-Precision Floating-Point (+ RV32F)"

| test rv32                | status      |
|--------------------------|:------------|
| `rv32ud-p-fadd`          | `passed`    |
| `rv32ud-p-fclass`        | `passed`    |
| `rv32ud-p-fcmp`          | `passed`    |
| `rv32ud-p-fcvt`          | `passed`    |
| `rv32ud-p-fcvt_w`        | `passed`    |
| `rv32ud-p-fdiv`          | `passed`    |
| `rv32ud-p-fmadd`         | `passed`    |
| `rv32ud-p-fmin`          | `passed`    |
| `rv32ud-p-ldst`          | `passed`    |
| `rv32ud-p-recoding`      | `passed`    |
| `rv32ud-v-fadd`          | `no passed` |
| `rv32ud-v-fclass`        | `no passed` |
| `rv32ud-v-fcmp`          | `no passed` |
| `rv32ud-v-fcvt`          | `no passed` |
| `rv32ud-v-fcvt_w`        | `no passed` |
| `rv32ud-v-fdiv`          | `no passed` |
| `rv32ud-v-fmadd`         | `no passed` |
| `rv32ud-v-fmin`          | `no passed` |
| `rv32ud-v-ldst`          | `no passed` |
| `rv32ud-v-recoding`      | `no passed` |
: RV32D - "RV32D Standard Extension for Double-Precision Floating-Point"

| test rv64                | status      |
|--------------------------|:------------|
| `rv64ud-p-fadd`          | `passed`    |
| `rv64ud-p-fclass`        | `passed`    |
| `rv64ud-p-fcmp`          | `passed`    |
| `rv64ud-p-fcvt`          | `no passed` |
| `rv64ud-p-fcvt_w`        | `no passed` |
| `rv64ud-p-fdiv`          | `passed`    |
| `rv64ud-p-fmadd`         | `passed`    |
| `rv64ud-p-fmin`          | `passed`    |
| `rv64ud-p-ldst`          | `passed`    |
| `rv64ud-p-move`          | `no passed` |
| `rv64ud-p-recoding`      | `no passed` |
| `rv64ud-p-structural`    | `no passed` |
| `rv64ud-v-fadd`          | `no passed` |
| `rv64ud-v-fclass`        | `no passed` |
| `rv64ud-v-fcmp`          | `no passed` |
| `rv64ud-v-fcvt`          | `no passed` |
| `rv64ud-v-fcvt_w`        | `no passed` |
| `rv64ud-v-fdiv`          | `no passed` |
| `rv64ud-v-fmadd`         | `no passed` |
| `rv64ud-v-fmin`          | `no passed` |
| `rv64ud-v-ldst`          | `no passed` |
| `rv64ud-v-move`          | `no passed` |
| `rv64ud-v-recoding`      | `passed`    |
| `rv64ud-v-structural`    | `no passed` |
: RV64D - "RV64D Standard Extension for Double-Precision Floating-Point (+ RV32D)"

| test rv32                | status      |
|--------------------------|:------------|
| `rv32uc-p-rvc`           | `no passed` |
| `rv32uc-v-rvc`           | `no passed` |
: RV32C - "RV32C Standard Extension for Compressed Instructions"

| test rv64                | status      |
|--------------------------|:------------|
| `rv64uc-p-rvc`           | `no passed` |
| `rv64uc-v-rvc`           | `no passed` |
: RV64C - "RV64C Standard Extension for Compressed Instructions (+ RV32C)"

| test rv32                | status      |
|--------------------------|:------------|
| `rv32si-p-csr`           | `no passed` |
| `rv32si-p-dirty`         | `no passed` |
| `rv32si-p-ma_fetch`      | `no passed` |
| `rv32si-p-sbreak`        | `no passed` |
| `rv32si-p-scall`         | `no passed` |
| `rv32si-p-wfi`           | `no passed` |
: RV32S - "RV32S Standard Extension for Supervisor-level Instructions"

| test rv64                | status      |
|--------------------------|:------------|
| `rv64si-p-csr`           | `no passed` |
| `rv64si-p-dirty`         | `no passed` |
| `rv64si-p-icache-alias`  | `no passed` |
| `rv64si-p-ma_fetch`      | `no passed` |
| `rv64si-p-sbreak`        | `no passed` |
| `rv64si-p-scall`         | `no passed` |
| `rv64si-p-wfi`           | `no passed` |
: RV64S - "RV64S Standard Extension for Supervisor-level Instructions (+ RV32S)"

| test rv32                | status      |
|--------------------------|:------------|
| `rv32uzfh-p-fadd`        | `no passed` |
| `rv32uzfh-p-fclass`      | `no passed` |
| `rv32uzfh-p-fcmp`        | `no passed` |
| `rv32uzfh-p-fcvt`        | `no passed` |
| `rv32uzfh-p-fcvt_w`      | `no passed` |
| `rv32uzfh-p-fdiv`        | `no passed` |
| `rv32uzfh-p-fmadd`       | `no passed` |
| `rv32uzfh-p-fmin`        | `no passed` |
| `rv32uzfh-p-ldst`        | `no passed` |
| `rv32uzfh-p-move`        | `no passed` |
| `rv32uzfh-p-recoding`    | `no passed` |
| `rv32uzfh-v-fadd`        | `no passed` |
| `rv32uzfh-v-fclass`      | `no passed` |
| `rv32uzfh-v-fcmp`        | `no passed` |
| `rv32uzfh-v-fcvt`        | `no passed` |
| `rv32uzfh-v-fcvt_w`      | `no passed` |
| `rv32uzfh-v-fdiv`        | `no passed` |
| `rv32uzfh-v-fmadd`       | `no passed` |
| `rv32uzfh-v-fmin`        | `no passed` |
| `rv32uzfh-v-ldst`        | `no passed` |
| `rv32uzfh-v-move`        | `no passed` |
| `rv32uzfh-v-recoding`    | `no passed` |
: RV32H - "RV32H Standard Extension for Hypervisor-level Instructions"

| test rv64                | status      |
|--------------------------|:------------|
| `rv64uzfh-p-fadd`        | `no passed` |
| `rv64uzfh-p-fclass`      | `no passed` |
| `rv64uzfh-p-fcmp`        | `no passed` |
| `rv64uzfh-p-fcvt`        | `no passed` |
| `rv64uzfh-p-fcvt_w`      | `no passed` |
| `rv64uzfh-p-fdiv`        | `no passed` |
| `rv64uzfh-p-fmadd`       | `no passed` |
| `rv64uzfh-p-fmin`        | `no passed` |
| `rv64uzfh-p-ldst`        | `no passed` |
| `rv64uzfh-p-move`        | `no passed` |
| `rv64uzfh-p-recoding`    | `no passed` |
| `rv64uzfh-v-fadd`        | `no passed` |
| `rv64uzfh-v-fclass`      | `no passed` |
| `rv64uzfh-v-fcmp`        | `no passed` |
| `rv64uzfh-v-fcvt`        | `no passed` |
| `rv64uzfh-v-fcvt_w`      | `no passed` |
| `rv64uzfh-v-fdiv`        | `no passed` |
| `rv64uzfh-v-fmadd`       | `no passed` |
| `rv64uzfh-v-fmin`        | `no passed` |
| `rv64uzfh-v-ldst`        | `no passed` |
| `rv64uzfh-v-move`        | `no passed` |
| `rv64uzfh-v-recoding`    | `no passed` |
: RV64H - "RV64H Standard Extension for Hypervisor-level Instructions (+ RV32H)"

| test rv32                | status      |
|--------------------------|:------------|
| `rv32mi-p-breakpoint`    | `passed`    |
| `rv32mi-p-csr`           | `passed`    |
| `rv32mi-p-illegal`       | `passed`    |
| `rv32mi-p-lh-misaligned` | `no passed` |
| `rv32mi-p-lw-misaligned` | `no passed` |
| `rv32mi-p-ma_addr`       | `passed`    |
| `rv32mi-p-ma_fetch`      | `passed`    |
| `rv32mi-p-mcsr`          | `passed`    |
| `rv32mi-p-sbreak`        | `passed`    |
| `rv32mi-p-scall`         | `passed`    |
| `rv32mi-p-shamt`         | `passed`    |
| `rv32mi-p-sh-misaligned` | `no passed` |
| `rv32mi-p-sw-misaligned` | `no passed` |
| `rv32mi-p-zicntr`        | `no passed` |
: RV32M - "RV32M Standard Extension for Machine-level Instructions"

| test rv64                | status      |
|--------------------------|:------------|
| `rv64mi-p-access`        | `no passed` |
| `rv64mi-p-breakpoint`    | `passed`    |
| `rv64mi-p-csr`           | `passed`    |
| `rv64mi-p-illegal`       | `?`         |
| `rv64mi-p-ld-misaligned` | `no passed` |
| `rv64mi-p-lh-misaligned` | `no passed` |
| `rv64mi-p-lw-misaligned` | `no passed` |
| `rv64mi-p-ma_addr`       | `?`         |
| `rv64mi-p-ma_fetch`      | `?`         |
| `rv64mi-p-mcsr`          | `passed`    |
| `rv64mi-p-sbreak`        | `passed`    |
| `rv64mi-p-scall`         | `passed`    |
| `rv64mi-p-sd-misaligned` | `no passed` |
| `rv64mi-p-sh-misaligned` | `no passed` |
| `rv64mi-p-sw-misaligned` | `no passed` |
| `rv64mi-p-zicntr`        | `no passed` |
: RV64M - "RV64M Standard Extension for Machine-level Instructions (+ RV32M)"

| test rv64                | status      |
|--------------------------|:------------|
| `rv64mzicbo-p-zero`      | `no passed` |
| `rv64ssvnapot-p-napot`   | `no passed` |
: RV64 - "RV64 Standard Extension (+ RV32)"
