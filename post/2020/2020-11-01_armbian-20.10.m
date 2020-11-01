---
title: "Armbian 20.10"
date: 2020-11-01T10:21:20+08:00
tags: [linux]
categories: [linux]
---

1 修改extlinux下面的extlinux.conf

LABEL Armbian
LINUX /zImage
INITRD /uInitrd

FDT /dtb/amlogic/meson-gxl-s905d-phicomm-n1.dtb
APPEND root=LABEL=ROOTFSrootflags=data=writeback rw console=ttyAML0,115200n8 console=tty0no_console_suspend consoleblank=0 fsck.fix=yes fsck.repair=yes net.ifnames=0

2 复制U盘根目录u-boot-s905x-s912为u-boot.ext
3 开机按任意键，输入run usb_boot启动，startx进桌面
