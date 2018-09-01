#network identifiers
GUEST_NET_NAME="sly-fox"
GUEST_ID="fox"

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
# OPTS="$OPTS -vga qxl"
OPTS="$OPTS -vga none -device qxl" 	#uncomment the above to have a vga window in this monitor
# Redirect QEMU's console input and output.
OPTS="$OPTS -monitor stdio"

#### DEVICE SETUP ###########
# Emulate a sound device
OPTS="$OPTS -soundhw hda"
# Select a QEMU sound driver and specify its settings.
VM_SOUND=""
VM_SOUND="$VM_SOUND QEMU_AUDIO_DRV=alsa"
VM_SOUND="$VM_SOUND QEMU_ALSA_DAC_BUFFER_SIZE=512"
VM_SOUND="$VM_SOUND QEMU_ALSA_DAC_PERIOD_SIZE=170"
#forward mouse and keyboard

#### NETWORK SETUP #########
#set up net id and name
#synergy port forward
OPTS="$OPTS -netdev user,id=$GUEST_ID,hostname=$GUEST_NET_NAME,hostfwd=tcp::24800-:24800"
OPTS="$OPTS -net nic,netdev=$GUEST_ID"

#add cmdline args to the end of the cmd string
OPTS="$OPTS $@"

sudo $VM_SOUND kvm $OPTS 
