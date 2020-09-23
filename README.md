# RISC-V Docker Toolchain

This is Dockerfile for RISC-V 32/64 development environment, along with QEMU.

## Story:

I was working on a RISC-V ELF CTF challenge. The provided ELF itself was compiled 
for SiFive and can be emulated by QEMU, e.g., `qemu-system-riscv32 -nographic -machine sifive_e -kernel xxx.elf`. 
Of course QEMU can be used as GDB server so I can remote into emulated environment 
and trace the execution but my GDB just does not support such architecture. I tried 
to tap into RISC-V brew repository, compile their toolchian and perform and quick 
remote debug but it just failed. So I looked into other people's docker version RISC-V 
toolchain and rewrote into my version. 


## How to use.

For now I haven't upload the generated artifact on Docker Hub but you should be able 
to modify the Docker file and build your own image.

Just cd into the repository and `docker build . -t riscv-toolchain`