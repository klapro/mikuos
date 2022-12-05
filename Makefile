
LIBTOOL = $(SHELL) $(top_builddir)/libtool

GPPPARAMS = -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore
LDPARAMS = -melf_i386
LOADERPARAMS = --32
objects = dist/loader.o dist/kernel.o 

dist/%.o: %.cpp
	mkdir -p dist
	g++ $(GPPPARAMS) -o $@ -c $<

dist/%.o: %.s
	mkdir -p dist
	as $(LOADERPARAMS) -o $@ $<

mykernel.bin: linker.ld $(objects)
	mkdir -p dist
	ld $(LDPARAMS) -T $< -o dist/$@ $(objects)

install: mykernel.bin
	mkdir -p dist
	sudo cp $< /boot/mykernel.bin

mykernel.iso: mykernel.bin
	mkdir -p dist
	mkdir -p dist/iso
	mkdir -p dist/iso/boot
	mkdir -p dist/iso/boot/grub
	cp dist/$< dist/iso/boot
	echo 'menuentry "My Operating System" {' >> dist/iso/boot/grub/grub.cfg
	echo ' multiboot /boot/mykernel.bin' >> dist/iso/boot/grub/grub.cfg
	echo ' boot' >> dist/iso/boot/grub/grub.cfg
	echo '}' >> dist/iso/boot/grub/grub.cfg
	grub-mkrescue --output=dist/$@ dist/iso

clean: 
	rm -rf dist