CFLAGS = -target x86_64-unknown-windows      	\
         -ffreestanding                      	\
         -fshort-wchar                       	\
         -mno-red-zone                       	\
         -Ignu-efi/inc               		 	\
         -Ignu-efi/inc/x86_64        		 	\
         -Ignu-efi/inc/protocol 				\
         -Ignu-efi/lib

LDFLAGS = -target x86_64-unknown-windows      	\
          -nostdlib                           	\
          -Wl,-entry:efi_main                 	\
          -Wl,-subsystem:efi_application		\
          -fuse-ld=lld

CC = clang

SRC = $(wildcard *.c)
OBJ = $(SRC:%.c=%.o)
EFI = out.efi
BOOT_DRIVE = out.img
BIOS = ovmf-uefi.bios

.PHONY: clean qemu all img



all: $(OBJ)
	$(CC) $(LDFLAGS) -o $(EFI) $(OBJ)
	make img

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<


qemu:
	qemu-system-x86_64 -bios $(BIOS) -drive file=$(BOOT_DRIVE),format=raw

clean:
	rm -f $(OBJ) $(BOOT_DRIVE) $(EFI)

img:
ifeq (, $(shell which mkfs.vfat))
	$(error "Can't find mkfs.vfat, consider doing sudo apt install dosfstools")
endif
ifeq (, $(shell which mcopy))
	$(error "Can't find mcopy, consider doing sudo apt install mtools")
endif
	dd if=/dev/zero of=$(BOOT_DRIVE) bs=1M count=1
	mkfs.vfat $(BOOT_DRIVE)
	mmd -i $(BOOT_DRIVE) ::EFI
	mmd -i $(BOOT_DRIVE) ::EFI/BOOT
	mcopy -i $(BOOT_DRIVE) $(EFI) ::EFI/BOOT/BOOTX64.EFI