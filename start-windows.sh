#!/bin/bash
OPTS=""
# Basic CPU settings.
OPTS="$OPTS -cpu host,kvm=off"
OPTS="$OPTS -smp 8,sockets=1,cores=4,threads=2"
# Enable KVM full virtualization support.
OPTS="$OPTS -enable-kvm"
# Assign memory to the vm.
OPTS="$OPTS -m 8G"
# VFIO GPU and GPU sound passthrough.
OPTS="$OPTS -device vfio-pci,host=01:00.0,multifunction=on"
OPTS="$OPTS -device vfio-pci,host=01:00.1"
# Supply OVMF (general UEFI bios, needed for EFI boot support with GPT disks).
OPTS="$OPTS -drive if=pflash,format=raw,readonly,file=/usr/share/edk2.git/ovmf-x64/OVMF_CODE-pure-efi.fd"
OPTS="$OPTS -drive if=pflash,format=raw,file=$(pwd)/OVMF_VARS-pure-efi.fd"
# Load our created VM image as a harddrive.
OPTS="$OPTS -drive file=$(pwd)/windows.img,format=raw,index=0,media=disk"
# Load our OS setup image e.g. ISO file.
# uncomment if we need to reinstall windows
# OPTS="$OPTS -cdrom $(pwd)/Win10_1803_English_x64.iso"
# Use the following emulated video device (use none for disabled).
OPTS="$OPTS -vga qxl"
# Redirect QEMU's console input and output.
OPTS="$OPTS -monitor stdio"
#add cmdline args to the end of the cmd string
OPTS="$OPTS $@"

sudo kvm $OPTS 