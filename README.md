# RISC-V Docker Toolchain

This is Dockerfile for RISC-V 32/64 development environment, along with QEMU.

## Story:

I was working on a RISC-V ELF CTF challenge. The provided ELF itself was compiled 
for SiFive and can be emulated by QEMU, e.g., `qemu-system-riscv32 -nographic -machine sifive_e -kernel xxx.elf`. 
Of course QEMU can be used as GDB server so I can remote into emulated environment 
and trace the execution but my GDB just does not support such architecture. I tried 
to tap into RISC-V brew repository, compile their toolchian and perform a quick 
remote debug but it just failed. So I looked into rene-fonseca's [docker version RISC-V 
toolchain](https://github.com/rene-fonseca/docker-riscv) and rewrote into my version. 


## How to use.

~~For now I haven't upload the generated artifact on Docker Hub but you should be able 
to modify the Docker file and build your own image. Just cd into the repository and 
`docker build . -t riscv-toolchain`~~

```bash
docker run --name "riscv-toolchain" -it pwn2de4d/riscv-toolchain:latest
```

## What's included 

* 32/64 bit Statically linked user mode RISC-V QEMU, located at `/opt/qemu-riscv-static`
* 32/64 bit System mode RISC-V QEMU, located at `/usr/local/bin`
* 32 bit RISC-V toolchain, including GDB, located at `/opt/riscv32`
* 64 bit RISC-V toolchain, including GDB, located at `/opt/riscv64`

---

## For CTF Players

I believe most CTF players only need QEMU and GDB functionalities rather than the entire 
toolchain. Time values a lot during CTF session so I wrote the `Dockerfile.ctf` for CTF 
players. In this dockerfile, RISC-V GDB is configured to support Python 3.8. It also 
supports debugging both 32 and 64 bits version elf. QEMU is also compiled to support 
user and system mode. I installed GEF, the enhanced GDB plugin, as well to assist debugging.

To use this Docker image, you can build the Dockerfile by yourself, which cost way less 
time than building the entire toolchain, or you can simple pull and run the image from 
Docker hub. 

```bash
docker run --name "riscv-toolchain-ctf" -it pwn2de4d/riscv-toolchain-ctf:latest
```

## Example

GEF does support RISC-V but I don't think it's the same as doing RE for x86/ARM ELF.

Make QEMU listen on 1234 port and wait for incoming connection with s and S option. Launch another 
terminal, use compiled gdb exectuable file and remote into port 1234 on localhost. 

```bash
qemu-system-riscv32 -nographic -machine sifive_e -kernel /root/xxx.elf  -s -S
```

```bash
/opt/riscv-binutils-gdb/bin/riscv64-unknown-elf-gdb -f /root/xxx.elf
target remote 127.0.0.1:1234
```

![Image of Main Breakpoint](https://raw.githubusercontent.com/niklaus520/RISCVDockerEnv/master/images/main_breakpoint.png)


![Image of stepi](https://raw.githubusercontent.com/niklaus520/RISCVDockerEnv/master/images/stepi.png)
