x86_64_asm_source_files := $(shell find src/boot -name *.asm) 
x86_64_asm_object_files := $(patsubst src/build/%.asm, build/x86_64/%.o, $(x86_64_asm_source_files))

$(x86_64_asm_object_files): build/x86_64/%.o : src/build/%.asm
	mkdir -p  $(dir $@) && \
	nasm -f elf64 $(patsubst build/x86_64/%.o, src/build/%.asm, $@) -o $@

.PHONY: build-x86_64
build-x86_64: $(x86_64_asm_object_files)
	mkdir -p dist/x86_64 && \ 
	x86_64-elf-ld -n -o dist/x86_64/kernel.bin -T targets\x86_64\linker.ld $(x86_64_asm_object_files) && \
	cp dist/x86_64/kernel.bin targets/x86_64/iso/boot/kernel.bin \
	grub-mkrescure /usr/lib/grub/i386-pc -o dist/x86_64/kernel.iso targets/x86_64/iso