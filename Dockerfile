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
# FROM build_env AS build_riscv_toolchain_32_64
    
# Although `--enable-multilib` is supported during configuration stage
# I still would rather to have them compiled seperately as my main goal
# is the gdb functionality 

# WORKDIR /tmp/riscv-gnu-toolchain
# git layer takes about 5.94GB storage and makes the entire image size to 
# 11.4GB. It's just insane so I just merged this part into compilation stage 

# Build 32/64 bits RISC-V toolchain for both newlib and linux 
RUN git clone --recursive https://github.com/riscv/riscv-gnu-toolchain \
    && mkdir -p /opt/riscv32 \
    && mkdir -p /opt/riscv64 \
    && cd /tmp/riscv-gnu-toolchain \
    && ./configure --prefix=/opt/riscv32 --with-arch=rv32gc --with-abi=ilp32d --enable-gdb \
    && make -j $(nproc) && make clean \
    # && ./configure --prefix=/opt/riscv32 --with-arch=rv32gc --with-abi=ilp32d --enable-gdb \
    && make -j $(nproc) linux && make clean \
    # Here we build 64 bits version
    && ./configure --prefix=/opt/riscv64 --enable-gdb \
    && make -j $(nproc) && make clean \
    # && ./configure --prefix=/opt/riscv64 --enable-gdb \
    && make -j $(nproc) linux && make clean \
    && rm -rf /tmp/riscv-gnu-toolchain

# Build QEMU for system emulation 
# FROM build_riscv_toolchain_32_64 AS build_qemu_system_32_64
# Removed this FROM AS statement to reduce the storage occupation 

WORKDIR /tmp

# Use QEMU v5.0.0, keep the same version as RISC-V
RUN mkdir riscv-qemu-linux \ 
    && cd riscv-qemu-linux \
    && git clone --depth=1 --branch=v5.0.0 https://github.com/qemu/qemu

WORKDIR /tmp/riscv-qemu-linux/qemu

# Build qemu with system emulation 
# Build target: riscv64-softmmu and riscv32-softmmu with system
RUN ./configure --target-list=riscv32-softmmu,riscv64-softmmu \
    && make -j $(nproc) \
    && make install \
    && make clean \
    && mkdir -p /opt/qemu-riscv-static \
    # Build user mode riscv QEMU
    && ./configure --target-list=riscv32-linux-user,riscv64-linux-user \
    --static \
    --disable-system \
    --enable-linux-user \
    --prefix=/opt/qemu-riscv-static \
    && make -j $(nproc) \
    && make install \
    && make clean \
    && rm -rf /tmp/riscv-qemu-linux \
    && rm -rf /var/lib/apt/lists/*

# DONE: Clean all pulled and generated files

WORKDIR /root