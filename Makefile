CFLAGS = -target x86_64-unknown-windows      	\
         -ffreestanding                      	\
         -fshort-wchar                       	\
         -mno-red-zone                       	\
         -Isdk/gnu-efi/inc               		\
         -Isdk/gnu-efi/inc/x86_64        		\
         -Isdk/gnu-efi/inc/protocol 			\
         -Isdk/gnu-efi/lib

LDFLAGS = -target x86_64-unknown-windows      	\
          -nostdlib                           	\
          -Wl,-entry:efi_main                 	\
          -Wl,-subsystem:efi_application		\
          -fuse-ld=lld

# C Compiler
CC = clang

# Finds all .c files in the current directory
SRC = $(wildcard *.c)
# Swaps the .c for .o to get the object output paths
OBJ = $(SRC:%.c=%.o)

# Final output filenames
EFI = out.efi
BOOT_DRIVE = out.img

# Calculates the required image size, essentially max(EFI_SIZE, MIN_SIZE)
EFI_SIZE = $(shell stat -L -c %s $(EFI))
MIN_SIZE = 51200
IMG_SIZE = $(shell echo $$(($(EFI_SIZE) > $(MIN_SIZE) ? $(EFI_SIZE) : $(MIN_SIZE))))

# Finds the path of the OVMF_CODE-pure-efi.fd file in the sdk folder
EDK2_PATH = $(shell find ./sdk -maxdepth 1 -type d -name "edk2.git-ovmf-x64*")
EDK2_BIOS = $(EDK2_PATH)/usr/share/edk2.git/ovmf-x64/OVMF_CODE-pure-efi.fd

# Finds the URL to download the latest version of edk2.git-ovmf-x64
EDK2_BASE_URL = https://www.kraxel.org/repos/jenkins/edk2/
EDK2_FILE_URL = $(shell wget -q $(BASE_URL) -O - | grep -Po 'edk2.git-ovmf-x64[^"]*' | head -1)


.PHONY: clean qemu all img update_edk2



all: $(OBJ)
	$(CC) $(LDFLAGS) -o $(EFI) $(OBJ)
	make img

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<


qemu:
	qemu-system-x86_64 -bios $(EDK2_BIOS) -drive file=$(BOOT_DRIVE),format=raw

clean:
	rm -f $(OBJ) $(BOOT_DRIVE) $(EFI)

img:
ifeq (, $(shell which mkfs.vfat))
	$(error "Can't find mkfs.vfat, consider doing sudo apt install dosfstools")
endif
ifeq (, $(shell which mcopy))
	$(error "Can't find mcopy, consider doing sudo apt install mtools")
endif
	dd if=/dev/zero of=$(BOOT_DRIVE) bs=$(IMG_SIZE) count=1
	mkfs.vfat $(BOOT_DRIVE)
	mmd -i $(BOOT_DRIVE) ::EFI
	mmd -i $(BOOT_DRIVE) ::EFI/BOOT
	mcopy -i $(BOOT_DRIVE) $(EFI) ::EFI/BOOT/BOOTX64.EFI

update_edk2:
	wget $(EDK2_BASE_URL)$(EDK2_FILE_URL)
