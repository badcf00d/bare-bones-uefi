# bare-bones-uefi

An extremely lightweight UEFI SDK that uses a standard clang instalation to compile C directly into UEFI applications. It uses the data structures and header files from gnu-efi, but does not use any of the toolchain of gnu-efi. I've also included a build of edk2 to make it easy to run the UEFI applications in qemu.

#### How to use:
 - `make` compiles `.c` files in the current directory into an efi application, it will then package that into a FAT-formatted image ready to run in qemu.
 - `make qemu` runs the compiled image in qemu.
 - `make clean` deletes the files created by the build process.
 - `make update_edk2` will download and update to the latest version of edk2.git-ovmf-x64.
 
 #### Contents:
```
├── hello_world.c                                                 # A Hello world example program
├── LICENSE                                                       # BSD 2-Clause License
├── Makefile                                                      # Makefile for GNU Make
├── README.md                                                     # Instructions
└── sdk
    ├── edk2.git-ovmf-x64-0-20200309.1355.g6e9bd495b3.noarch            # A build of edk2 from Tianocore
    └── gnu-efi                                                         # A fork of gnu-efi
 ```
