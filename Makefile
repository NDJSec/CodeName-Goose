CC=x86_64-elf-gcc
CFLAGS=-g -Wall -Werror -Wpedantic -ffreestanding

kernel_source_files := $(shell find src/kernel -name *.c)
kernel_object_files := $(patsubst src/kernel/%.c, build/kernel/%.o, $(kernel_source_files))

libc_c_source_files := $(shell find src/libc -name *.c)
libc_c_object_files := $(patsubst src/libc/%.c, build/libc/%.o, $(libc_c_source_files))

x86_64_asm_source_files := $(shell find src/kernel/arch/x86_64/boot -name *.asm)
x86_64_asm_object_files := $(patsubst src/kernel/arch/x86_64/boot/%.asm, build/kernel/arch/x86_64/boot/%.o, $(x86_64_asm_source_files))

x86_64_object_files := $(libc_c_object_files) $(x86_64_asm_object_files)

INCLUDE_DIRS := $(shell find src/kernel/include src/libc/include -type d)
INCLUDE_FLAGS := $(addprefix -I,$(INCLUDE_DIRS))

$(kernel_object_files): build/kernel/%.o : src/kernel/%.c
	mkdir -p $(dir $@) && \
	$(CC) -c $(INCLUDE_FLAGS) $(CFLAGS) -D__is_kernel $(patsubst build/kernel/%.o, src/kernel/%.c, $@) -o $@

$(libc_c_object_files): build/libc/%.o : src/libc/%.c
	mkdir -p $(dir $@) && \
	$(CC) -c $(INCLUDE_FLAGS) $(CFLAGS) -D__is_libk $(patsubst build/libc/%.o, src/libc/%.c, $@) -o $@

$(x86_64_asm_object_files): build/kernel/arch/x86_64/boot/%.o : src/kernel/arch/x86_64/boot/%.asm
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst build/kernel/arch/x86_64/boot/%.o, src/kernel/arch/x86_64/boot/%.asm, $@) -o $@

.PHONY: qemu-docker
qemu-docker:
	docker run --rm -v $(PWD):/root/env -w /root/env goose_build make build-x86_64
	qemu-system-x86_64 -cdrom dist/x86_64/kernel.iso

.PHONY: build-x86_64
build-x86_64: $(kernel_object_files) $(x86_64_object_files)
	mkdir -p dist/x86_64 && \
	x86_64-elf-ld -n -o dist/x86_64/kernel.bin -T targets/x86_64/linker.ld $(kernel_object_files) $(x86_64_object_files) && \
	cp dist/x86_64/kernel.bin targets/x86_64/iso/boot/kernel.bin && \
	grub-mkrescue /usr/lib/grub/i386-pc -o dist/x86_64/kernel.iso targets/x86_64/iso

.PHONY: clean
clean:
	rm -rf build/* dist 
