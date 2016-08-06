KERNEL_VERSION=4.6.4
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(KERNEL_VERSION).tar.xz
BUSYBOX_VERSION=1.24.2
BUSYBOX_URL=https://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2

all: fs.tar

linux-$(KERNEL_VERSION).tar.xz:
	wget $(KERNEL_URL)

linux-$(KERNEL_VERSION): linux-$(KERNEL_VERSION).tar.xz
	tar -xf linux-$(KERNEL_VERSION).tar.xz
	cp kernel-config linux-$(KERNEL_VERSION)/.config

bzImage: linux-$(KERNEL_VERSION) kernel-config
	$(MAKE) -C linux-$(KERNEL_VERSION)
	cp linux-$(KERNEL_VERSION)/arch/x86/boot/bzImage .

busybox-$(BUSYBOX_VERSION).tar.bz2:
	wget $(BUSYBOX_URL)

busybox-$(BUSYBOX_VERSION): busybox-$(BUSYBOX_VERSION).tar.bz2
	tar -xf busybox-$(BUSYBOX_VERSION).tar.bz2

busybox: busybox-$(BUSYBOX_VERSION) bb-config
	sed '1,1i#include <sys/resource.h>' -i busybox-$(BUSYBOX_VERSION)/include/libbb.h
	cp bb-config busybox-$(BUSYBOX_VERSION)/.config
	$(MAKE) CFLAGS="-O2 -fstack-protector-strong" CC=musl-gcc -C busybox-$(BUSYBOX_VERSION)
	cp busybox-$(BUSYBOX_VERSION)/busybox .

fs.tar: bzImage busybox
	$(MAKE) -C filesystem

mdos.img: fs.tar gen_image.sh
	./gen_image.sh

.PHONY: fs.tar
