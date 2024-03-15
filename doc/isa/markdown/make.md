HAS_RV32I = 1
HAS_RV64I = 1
HAS_RV32A = 1
HAS_RV64A = 1
HAS_RV32M = 1
HAS_RV64M = 1
HAS_RV32F = 1
HAS_RV64F = 1
HAS_RV32D = 1
HAS_RV64D = 1
HAS_RV32C = 1
HAS_RV64C = 1

HAS_RV64SVNAPOT = 1

HAS_RV64ZICBO = 1

HAS_RV32ZBA = 1
HAS_RV64ZBA = 1
HAS_RV32ZBB = 1
HAS_RV64ZBB = 1
HAS_RV32ZBC = 1
HAS_RV64ZBC = 1
HAS_RV32ZBS = 1
HAS_RV64ZBS = 1
HAS_RV32ZFH = 1
HAS_RV64ZFH = 1

HAS_U32 = 1
HAS_U64 = 1
HAS_S32 = 1
HAS_S64 = 1
HAS_H32 = 1
HAS_H64 = 1
HAS_M32 = 1
HAS_M64 = 1

# User Mode RV64I Tests
USER_RV32I_TESTS = \
rv32ui-add \
rv32ui-addi \
rv32ui-and \
rv32ui-andi \
rv32ui-auipc \
rv32ui-beq \
rv32ui-bge \
rv32ui-bgeu \
rv32ui-blt \
rv32ui-bltu \
rv32ui-bne \
rv32ui-fence_i \
rv32ui-jal \
rv32ui-jalr \
rv32ui-lb \
rv32ui-lbu \
rv32ui-lh \
rv32ui-lhu \
rv32ui-lui \
rv32ui-lw \
rv32ui-ma_data \
rv32ui-or \
rv32ui-ori \
rv32ui-sb \
rv32ui-sh \
rv32ui-simple \
rv32ui-sll \
rv32ui-slli \
rv32ui-slt \
rv32ui-slti \
rv32ui-sltiu \
rv32ui-sltu \
rv32ui-sra \
rv32ui-srai \
rv32ui-srl \
rv32ui-srli \
rv32ui-sub \
rv32ui-sw \
rv32ui-xor \
rv32ui-xori

# User Mode RV32I Tests
USER_RV64I_TESTS = \
rv64ui-add \
rv64ui-addi \
rv64ui-addiw \
rv64ui-addw \
rv64ui-and \
rv64ui-andi \
rv64ui-auipc \
rv64ui-beq \
rv64ui-bge \
rv64ui-bgeu \
rv64ui-blt \
rv64ui-bltu \
rv64ui-bne \
rv64ui-fence_i \
rv64ui-jal \
rv64ui-jalr \
rv64ui-lb \
rv64ui-lbu \
rv64ui-ld \
rv64ui-lh \
rv64ui-lhu \
rv64ui-lui \
rv64ui-lw \
rv64ui-lwu \
rv64ui-ma_data \
rv64ui-or \
rv64ui-ori \
rv64ui-sb \
rv64ui-sd \
rv64ui-sh \
rv64ui-simple \
rv64ui-sll \
rv64ui-slli \
rv64ui-slliw \
rv64ui-sllw \
rv64ui-slt \
rv64ui-slti \
rv64ui-sltiu \
rv64ui-sltu \
rv64ui-sra \
rv64ui-srai \
rv64ui-sraiw \
rv64ui-sraw \
rv64ui-srl \
rv64ui-srli \
rv64ui-srliw \
rv64ui-srlw \
rv64ui-sub \
rv64ui-subw \
rv64ui-sw \
rv64ui-xor \
rv64ui-xori

# User Mode RV32M Tests
USER_RV32M_TESTS = \
rv32um-div \
rv32um-divu \
rv32um-mul \
rv32um-mulh \
rv32um-mulhsu \
rv32um-mulhu \
rv32um-rem \
rv32um-remu

# User Mode RV64M Tests
USER_RV64M_TESTS = \
rv64um-div \
rv64um-divu \
rv64um-divuw \
rv64um-divw \
rv64um-mul \
rv64um-mulh \
rv64um-mulhsu \
rv64um-mulhu \
rv64um-mulw \
rv64um-rem \
rv64um-remu \
rv64um-remuw \
rv64um-remw

# User Mode RV32A Tests
USER_RV32A_TESTS = \
rv32ua-amoadd_w \
rv32ua-amoand_w \
rv32ua-amomaxu_w \
rv32ua-amomax_w \
rv32ua-amominu_w \
rv32ua-amomin_w \
rv32ua-amoor_w \
rv32ua-amoswap_w \
rv32ua-amoxor_w \
rv32ua-lrsc

# User Mode RV64A Tests
USER_RV64A_TESTS = \
rv64ua-amoadd_d \
rv64ua-amoadd_w \
rv64ua-amoand_d \
rv64ua-amoand_w \
rv64ua-amomax_d \
rv64ua-amomaxu_d \
rv64ua-amomaxu_w \
rv64ua-amomax_w \
rv64ua-amomin_d \
rv64ua-amominu_d \
rv64ua-amominu_w \
rv64ua-amomin_w \
rv64ua-amoor_d \
rv64ua-amoor_w \
rv64ua-amoswap_d \
rv64ua-amoswap_w \
rv64ua-amoxor_d \
rv64ua-amoxor_w \
rv64ua-lrsc

# User Mode RV32C Tests
USER_RV32C_TESTS = \
rv32uc-rvc

# User Mode RV64C Tests
USER_RV64C_TESTS = \
rv64uc-rvc

# User Mode RV32F Tests
USER_RV32F_TESTS = \
rv32uf-fadd \
rv32uf-fclass \
rv32uf-fcmp \
rv32uf-fcvt \
rv32uf-fcvt_w \
rv32uf-fdiv \
rv32uf-fmadd \
rv32uf-fmin \
rv32uf-ldst \
rv32uf-move \
rv32uf-recoding

# User Mode RV64F Tests
USER_RV64F_TESTS = \
rv64uf-fadd \
rv64uf-fclass \
rv64uf-fcmp \
rv64uf-fcvt \
rv64uf-fcvt_w \
rv64uf-fdiv \
rv64uf-fmadd \
rv64uf-fmin \
rv64uf-ldst \
rv64uf-move \
rv64uf-recoding

# User Mode RV32D Tests
USER_RV32D_TESTS = \
rv32ud-fadd \
rv32ud-fclass \
rv32ud-fcmp \
rv32ud-fcvt \
rv32ud-fcvt_w \
rv32ud-fdiv \
rv32ud-fmadd \
rv32ud-fmin \
rv32ud-ldst \
rv32ud-recoding

# User Mode RV64D Tests
USER_RV64D_TESTS = \
rv64ud-fadd \
rv64ud-fclass \
rv64ud-fcmp \
rv64ud-fcvt \
rv64ud-fcvt_w \
rv64ud-fdiv \
rv64ud-fmadd \
rv64ud-fmin \
rv64ud-ldst \
rv64ud-move \
rv64ud-recoding \
rv64ud-structural

# User Mode RV32ZBA Tests
USER_RV32ZBA_TESTS = \
rv32uzba-sh1add \
rv32uzba-sh2add \
rv32uzba-sh3add

# User Mode RV64ZBA Tests
USER_RV64ZBA_TESTS = \
rv64uzba-add_uw \
rv64uzba-sh1add \
rv64uzba-sh1add_uw \
rv64uzba-sh2add \
rv64uzba-sh2add_uw \
rv64uzba-sh3add \
rv64uzba-sh3add_uw \
rv64uzba-slli_uw

# User Mode RV32ZBB Tests
USER_RV32ZBB_TESTS = \
rv32uzbb-andn \
rv32uzbb-clz \
rv32uzbb-cpop \
rv32uzbb-ctz \
rv32uzbb-max \
rv32uzbb-maxu \
rv32uzbb-min \
rv32uzbb-minu \
rv32uzbb-orc_b \
rv32uzbb-orn \
rv32uzbb-rev8 \
rv32uzbb-rol \
rv32uzbb-ror \
rv32uzbb-rori \
rv32uzbb-sext_b \
rv32uzbb-sext_h \
rv32uzbb-xnor \
rv32uzbb-zext_h

# User Mode RV64ZBB Tests
USER_RV64ZBB_TESTS = \
rv64uzbb-andn \
rv64uzbb-clz \
rv64uzbb-clzw \
rv64uzbb-cpop \
rv64uzbb-cpopw \
rv64uzbb-ctz \
rv64uzbb-ctzw \
rv64uzbb-max \
rv64uzbb-maxu \
rv64uzbb-min \
rv64uzbb-minu \
rv64uzbb-orc_b \
rv64uzbb-orn \
rv64uzbb-rev8 \
rv64uzbb-rol \
rv64uzbb-rolw \
rv64uzbb-ror \
rv64uzbb-rori \
rv64uzbb-roriw \
rv64uzbb-rorw \
rv64uzbb-sext_b \
rv64uzbb-sext_h \
rv64uzbb-xnor \
rv64uzbb-zext_h

# User Mode RV32ZBC Tests
USER_RV32ZBC_TESTS = \
rv32uzbc-clmul \
rv32uzbc-clmulh \
rv32uzbc-clmulr

# User Mode RV64ZBC Tests
USER_RV64ZBC_TESTS = \
rv64uzbc-clmul \
rv64uzbc-clmulh \
rv64uzbc-clmulr

# User Mode RV32ZBS Tests
USER_RV32ZBS_TESTS = \
rv32uzbs-bclr \
rv32uzbs-bclri \
rv32uzbs-bext \
rv32uzbs-bexti \
rv32uzbs-binv \
rv32uzbs-binvi \
rv32uzbs-bset \
rv32uzbs-bseti

# User Mode RV64ZBS Tests
USER_RV64ZBS_TESTS = \
rv64uzbs-bclr \
rv64uzbs-bclri \
rv64uzbs-bext \
rv64uzbs-bexti \
rv64uzbs-binv \
rv64uzbs-binvi \
rv64uzbs-bset \
rv64uzbs-bseti

# User Mode RV32ZFH Tests
USER_RV32ZFH_TESTS = \
rv32uzfh-fadd \
rv32uzfh-fclass \
rv32uzfh-fcmp \
rv32uzfh-fcvt \
rv32uzfh-fcvt_w \
rv32uzfh-fdiv \
rv32uzfh-fmadd \
rv32uzfh-fmin \
rv32uzfh-ldst \
rv32uzfh-move \
rv32uzfh-recoding

# User Mode RV64ZFH Tests
USER_RV64ZFH_TESTS = \
rv64uzfh-fadd \
rv64uzfh-fclass \
rv64uzfh-fcmp \
rv64uzfh-fcvt \
rv64uzfh-fcvt_w \
rv64uzfh-fdiv \
rv64uzfh-fmadd \
rv64uzfh-fmin \
rv64uzfh-ldst \
rv64uzfh-move \
rv64uzfh-recoding


# Supervisor Mode RV32I Tests
SUPERVISOR_RV32I_TESTS = \
rv32si-csr \
rv32si-dirty \
rv32si-ma_fetch \
rv32si-sbreak \
rv32si-scall \
rv32si-wfi

# Supervisor Mode RV64I Tests
SUPERVISOR_RV64I_TESTS = \
rv64si-csr \
rv64si-dirty \
rv64si-icache-alias \
rv64si-ma_fetch \
rv64si-sbreak \
rv64si-scall \
rv64si-wfi

# Supervisor Mode RV64SVNAPOT Tests
SUPERVISOR_RV64SVNAPOT_TESTS = \
rv64ssvnapot-napot


# Machine Mode RV32I Tests
MACHINE_RV32I_TESTS = \
rv32mi-breakpoint \
rv32mi-csr \
rv32mi-illegal \
rv32mi-lh-misaligned \
rv32mi-lw-misaligned \
rv32mi-ma_addr \
rv32mi-ma_fetch \
rv32mi-mcsr \
rv32mi-sbreak \
rv32mi-scall \
rv32mi-shamt \
rv32mi-sh-misaligned \
rv32mi-sw-misaligned \
rv32mi-zicntr

# Machine Mode RV64I Tests
MACHINE_RV64I_TESTS = \
rv64mi-access \
rv64mi-breakpoint \
rv64mi-csr \
rv64mi-illegal \
rv64mi-ld-misaligned \
rv64mi-lh-misaligned \
rv64mi-lw-misaligned \
rv64mi-ma_addr \
rv64mi-ma_fetch \
rv64mi-mcsr \
rv64mi-sbreak \
rv64mi-scall \
rv64mi-sd-misaligned \
rv64mi-sh-misaligned \
rv64mi-sw-misaligned \
rv64mi-zicntr

# Machine Mode RV64ZICBO Tests
MACHINE_RV64ZICBO_TESTS = \
rv64mzicbo-zero


# User Mode RV32I Tests
u32itst_lst += $(if $(HAS_RV32I) > 0, $(foreach t, $(USER_RV32I_TESTS),rv32ui-p-$t))

# User Mode RV64I Tests
u64itst_lst += $(if $(HAS_RV64I) > 0, $(foreach t, $(USER_RV64I_TESTS),rv64ui-p-$t))

# User Mode RV32M Tests
u32mtst_lst += $(if $(HAS_RV32M) > 0, $(foreach t, $(USER_RV32M_TESTS),rv32um-p-$t))

# User Mode RV64M Tests
u64mtst_lst += $(if $(HAS_RV64M) > 0, $(foreach t, $(USER_RV64M_TESTS),rv64um-p-$t))

# User Mode RV32A Tests
u32atst_lst += $(if $(HAS_RV32A) > 0, $(foreach t, $(USER_RV32A_TESTS),rv32ua-p-$t))

# User Mode RV64A Tests
u64atst_lst += $(if $(HAS_RV64A) > 0, $(foreach t, $(USER_RV64A_TESTS),rv64ua-p-$t))

# User Mode RV32F Tests
u32ftst_lst += $(if $(HAS_RV32F) > 0, $(foreach t, $(USER_RV32F_TESTS),rv32uf-p-$t))

# User Mode RV64F Tests
u64ftst_lst += $(if $(HAS_RV64F) > 0, $(foreach t, $(USER_RV64F_TESTS),rv64uf-p-$t))

# User Mode RV32D Tests
u32dtst_lst += $(if $(HAS_RV32D) > 0, $(foreach t, $(USER_RV32D_TESTS),rv32ud-p-$t))

# User Mode RV64D Tests
u64dtst_lst += $(if $(HAS_RV64D) > 0, $(foreach t, $(USER_RV64D_TESTS),rv64ud-p-$t))

# User Mode RV32C Tests
u32ctst_lst += $(if $(HAS_RV32C) > 0, $(foreach t, $(USER_RV32C_TESTS),rv32uc-p-$t))

# User Mode RV64C Tests
u64ctst_lst += $(if $(HAS_RV64C) > 0, $(foreach t, $(USER_RV64C_TESTS),rv64uc-p-$t))

# User Mode RV32ZBA Tests
u64zbatst_lst += $(if $(HAS_RV32ZBA) > 0, $(foreach t, $(USER_RV32ZBA_TESTS),rv32uzba-p-$t))

# User Mode RV64ZBA Tests
u64zbatst_lst += $(if $(HAS_RV64ZBA) > 0, $(foreach t, $(USER_RV64ZBA_TESTS),rv64uzba-p-$t))

# User Mode RV32ZBB Tests
u64zbbtst_lst += $(if $(HAS_RV32ZBB) > 0, $(foreach t, $(USER_RV32ZBB_TESTS),rv32uzbb-p-$t))

# User Mode RV64ZBB Tests
u64zbbtst_lst += $(if $(HAS_RV64ZBB) > 0, $(foreach t, $(USER_RV64ZBB_TESTS),rv64uzbb-p-$t))

# User Mode RV32ZBC Tests
u64zbctst_lst += $(if $(HAS_RV32ZBC) > 0, $(foreach t, $(USER_RV32ZBC_TESTS),rv32uzbc-p-$t))

# User Mode RV64ZBC Tests
u64zbctst_lst += $(if $(HAS_RV64ZBC) > 0, $(foreach t, $(USER_RV64ZBC_TESTS),rv64uzbc-p-$t))

# User Mode RV32ZFH Tests
u64zfhtst_lst += $(if $(HAS_RV32ZFH) > 0, $(foreach t, $(USER_RV32ZFH_TESTS),rv32uzfh-p-$t))

# User Mode RV64ZFH Tests
u64zfhtst_lst += $(if $(HAS_RV64ZFH) > 0, $(foreach t, $(USER_RV64ZFH_TESTS),rv64uzfh-p-$t))

# User Mode
u32tests = $(if $(HAS_U32) > 0, $(u32itst_lst) $(u32mtst_lst) $(u32atst_lst) $(u32ftst_lst))
u64tests = $(if $(HAS_U64) > 0, $(u64itst_lst) $(u64mtst_lst) $(u64atst_lst) $(u64ftst_lst))


# Supervisor Mode RV32I Tests
s32itst_lst = $(if $(HAS_S32) > 0, $(foreach t, $(SUPERVISOR_RV32I_TESTS),rv32si-p-$t))

# Supervisor Mode RV64I Tests
s64itst_lst = $(if $(HAS_S64) > 0, $(foreach t, $(SUPERVISOR_RV64I_TESTS),rv64si-p-$t))

# Supervisor Mode RV64SVNAPOT Tests
s64svnapottst_lst = $(if $(HAS_RV64SVNAPOT) > 0, $(foreach t, $(SUPERVISOR_RV64SVNAPOT_TESTS),rv64ssvnapot-p-$t))

# Supervisor Mode
s32tests = $(if $(HAS_M32) > 0, $(s32itst_lst))
s64tests = $(if $(HAS_M64) > 0, $(s64itst_lst) $(s64svnapottst_lst))


# Hypervisor Mode RV32I Tests
h32itst_lst = $(if $(HAS_H32) > 0, $(foreach t, $(HYPERVISOR_RV32I_TESTS),rv32hi-p-$t))

# Hypervisor Mode RV64I Tests
h64itst_lst = $(if $(HAS_H64) > 0, $(foreach t, $(HYPERVISOR_RV64I_TESTS),rv64hi-p-$t))

# Hypervisor Mode
h32tests = $(if $(HAS_M32) > 0, $(h32itst_lst))
h64tests = $(if $(HAS_M64) > 0, $(h64itst_lst))


# Machine Mode RV32I Tests
m32itst_lst = $(if $(HAS_M32) > 0, $(foreach t, $(MACHINE_RV32I_TESTS),rv32mi-p-$t))

# Machine Mode RV64I Tests
m64itst_lst = $(if $(HAS_M64) > 0, $(foreach t, $(MACHINE_RV64I_TESTS),rv64mi-p-$t))

# Machine Mode RV64ZICBO Tests
m64zicbotst_lst = $(if $(HAS_RV64ZICBO) > 0, $(foreach t, $(MACHINE_RV64ZICBO_TESTS),rv64mzicbo-p-$t))

# Machine Mode
m32tests = $(if $(HAS_M32) > 0, $(m32itst_lst))
m64tests = $(if $(HAS_M64) > 0, $(m64itst_lst) $(m64zicbotst_lst))


# All Tests
tests = $(u32tests) $(m32tests)
