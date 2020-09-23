# Install all dependency we need so we dont have to 
# install them during every different buidling stage
FROM ubuntu:18.04 AS build_env

RUN apt -y update \
    && apt install -y autoconf automake autotools-dev curl \
    libmpc-dev libmpfr-dev libgmp-dev \
    python3 pkg-config libglib2.0-dev libpixman-1-dev gawk \
    build-essential bison flex texinfo gperf libtool patchutils \
    bc zlib1g-dev libexpat-dev git 

# Build 32/64 bits RISC-V toolchain from source code
FROM build_env AS build_riscv_toolchain_32_64

RUN mkdir -p /opt/riscv32 \
    && mkdir -p /opt/riscv64 
    
WORKDIR /tmp
RUN git clone --recursive https://github.com/riscv/riscv-gnu-toolchain

# Although `--enable-multilib` is supported during configuration stage
# I still would rather to have them compiled seperately as my main goal
# is the gdb functionality 
WORKDIR /tmp/riscv-gnu-toolchain

# Build 32 bit RISC-V toolchain for both newlib and linux 
RUN ./configure --prefix=/opt/riscv32 --with-arch=rv32gc --with-abi=ilp32d --enable-gdb \
    && make -j $(nproc) && make clean \
    && make -j $(nproc) linux && make clean 

# Build 64 bit RISC-V toolchain for both newlib and linux 
RUN ./configure --prefix=/opt/riscv64 --enable-gdb \
    && make -j $(nproc) && make clean \
    && make -j $(nproc) linux && make clean 

# Build QEMU for system emulation 
FROM build_riscv_toolchain_32_64 AS build_qemu_system_32_64

WORKDIR /tmp

# Use QEMU v5.0.0, keep the same version as RISC-V
RUN mkdir riscv-qemu-linux \ 
    && cd riscv-qemu-linux \
    && git clone --depth=1 --branch=v5.0.0 https://github.com/qemu/qemu

WORKDIR /tmp/riscv-qemu-linux/qemu

# Build qemu with system emulation 
# Build target: riscv64-softmmu and riscv32-softmmu
RUN ./configure --target-list=riscv32-softmmu,riscv64-softmmu \
    && make -j $(nproc) \
    && make install \
    && make clean

# TODO: Build qemu with user mode and we would like it to be statically linked

# TODO: Clean all pulled and generated files
