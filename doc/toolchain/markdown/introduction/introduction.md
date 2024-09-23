# INTRODUCTION

type:

```
sudo apt install -y autoconf
sudo apt install -y automake
sudo apt install -y autotools-dev
sudo apt install -y bc
sudo apt install -y bison
sudo apt install -y build-essential
sudo apt install -y curl
sudo apt install -y flex
sudo apt install -y gawk
sudo apt install -y gperf
sudo apt install -y libexpat-dev
sudo apt install -y libgmp-dev
sudo apt install -y libmpc-dev
sudo apt install -y libmpfr-dev
sudo apt install -y libtool
sudo apt install -y patchutils
sudo apt install -y python3
sudo apt install -y texinfo
sudo apt install -y zlib1g-dev
```

type:

```
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain

cd riscv-gnu-toolchain

./configure --prefix=/opt/riscv-elf-gcc
sudo make clean
sudo make

./configure --prefix=/opt/riscv-app-gcc --enable-multilib
sudo make clean
sudo make linux
```

| Tool       | Address                                                   |
|------------|-----------------------------------------------------------|
| `binutils` | `https://sourceware.org/git/binutils-gdb.git`             |
| `dejagnu`  | `https://git.savannah.gnu.org/git/dejagnu.git`            |
| `gcc`      | `https://gcc.gnu.org/git/gcc.git`                         |
| `gdb`      | `https://sourceware.org/git/binutils-gdb.git`             |
| `glibc`    | `https://sourceware.org/git/glibc.git`                    |
| `llvm`     | `https://github.com/llvm/llvm-project.git`                |
| `musl`     | `https://git.musl-libc.org/git/musl`                      |
| `newlib`   | `https://sourceware.org/git/newlib-cygwin.git`            |
| `pk`       | `https://github.com/riscv-software-src/riscv-pk.git`      |
| `qemu`     | `https://gitlab.com/qemu-project/qemu.git`                |
| `spike`    | `https://github.com/riscv-software-src/riscv-isa-sim.git` |
| `uclibc`   | `https://git.uclibc-ng.org/git/uclibc-ng.git`             |
: GNU ToolChain

Here is the list of configure option for specify source tree:

    --with-binutils-src
    --with-dejagnu-src
    --with-gcc-src
    --with-gdb-src
    --with-glibc-src
    --with-llvm-src
    --with-musl-src
    --with-newlib-src
    --with-pk-src
    --with-qemu-src
    --with-spike-src
    --with-uclibc-src

| Tool            |
|-----------------|
| `riscv32-elf`   |
| `riscv32-glibc` |
: Compilation 32-Bit

| Tool            |
|-----------------|
| `riscv64-elf`   |
| `riscv64-glibc` |
| `riscv64-musl`  |
: Compilation 64-Bit
