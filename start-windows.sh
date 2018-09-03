### parse program args ###
#defaults
CMDLINE_OPTS=""
PERFORMANCE=2 #choose from 1, 2, or 3, with 3 being the highest VM performance
#parse
while [ "$1" != "" ]; do
    case $1 in
        -a | --scarlett-audio ) PASS_SCARLETT=1 		#pass the Scarlett 2i4 through to the VM
                                ;;
        -s | --synergy )    	SYNERGY=1				#pass the keyboard and mouse to the vm
                                ;;
        -p | --performance )    shift
                                PERFORMANCE="$1"
                                ;;
        * )						CMDLINE_OPTS="$CMDLINE_OPTS $1"
    esac
    shift
done
case $PERFORMANCE in
    1)
        CORES=4
        RAM=6G
        ;;
    2)
        CORES=4
        RAM=10G
        ;;
    3)
        CORES=6
        RAM=12G
        ;;
    *)
        echo "[start-windows]: Invalid performance value \"$PERFORMANCE\"."
        exit 1;
esac

#### MAIN #####

#network identifiers
GUEST_NET_NAME="sly-fox"
GUEST_ID="fox"

#!/bin/bash
OPTS=""
# Basic CPU settings.
OPTS="$OPTS -cpu host,kvm=off"
OPTS="$OPTS -smp sockets=1,cores=$CORES,threads=2"
# Enable KVM full virtualization support.
OPTS="$OPTS -enable-kvm"
# Assign memory to the vm.
OPTS="$OPTS -m $RAM"
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
# OPTS="$OPTS -vga qxl"	#enable this to get a VGA window in the ubuntu monitor. 
OPTS="$OPTS -vga none -device qxl" 	#enable this for a separate windows display from the GTX1060
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
#forward USB devices
OPTS="$OPTS -device qemu-xhci"
if [ "$SYNERGY" = "1" ]; then
	#pass through the host mouse and keyboard 
	OPTS="$OPTS -device usb-host,vendorid=0x062a,productid=0x4102"	#mouse
	OPTS="$OPTS -device usb-host,vendorid=0x413c,productid=0x2111"	#keyboard
	#TODO: use xrandr to mirror or disable the left display (where windows is going)?
fi
if [ "$PASS_SCARLETT" = "1" ]; then
	OPTS="$OPTS -device usb-host,vendorid=0x1235,productid=0x800a"	#scarlett 2i4
fi

#### NETWORK SETUP #########
#set up net id and name
#synergy port forward
OPTS="$OPTS -netdev user,id=$GUEST_ID,hostname=$GUEST_NET_NAME,hostfwd=tcp::24800-:24800,hostfwd=tcp::3390-:3390"
OPTS="$OPTS -net nic,netdev=$GUEST_ID"
#windows RDP (remote desktop) forward


#run kvm with all options
# echo "sudo $VM_SOUND kvm $OPTS $CMDLINE_OPTS"
sudo $VM_SOUND kvm $OPTS $CMDLINE_OPTS
