# NixOS on Raspberry Pi 4 over USB

> **TL;DR;** The officially supported SD image[↗](https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi_4) available in Hydra only works when booting off of SD cards, due to some bug in U-Boot. Here's a workaround to get the Pi to boot NixOS from a USB drive or an SSD.

### Requirements
- A Raspberry Pi 4 (duh!)
- An SD card (it will be our installer)
- A USB Drive (NixOS will be installed to it)

### Preparing the Pi to boot from USB
Write the `misc utility images -> Bootloader (Pi 4 family) -> USB Boot` image onto an SD card using Raspberry Pi Imager (`pkgs.rpi-imager`) and boot the Pi with it. Once booted, wait for 10-15 seconds and turn off the Pi. This will update the Pi's firmware to prefer booting from USB.

### Preparing the installer SD card (installer)
- Download a recent version of the aarch64 SD card image from [Hydra↗](https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image.aarch64-linux)
- The image will be compressed with ZSTD, so it needs to be decompressed before being written to the SD card
  ```sh
    zstd --decompress nixos-sd-image-24.11preblah.blahblah-aarch64-linux.img.zst
  ```
- Write the decompressed image to the SD card (we'll call it /dev/mmcblkN from now on)
  ```sh
    dd if=nixos-sd-image-24.11preblah.blahblah-aarch64-linux.img of=/dev/mmcblkN
  ```

### Preparing the USB drive
#### Disk Layout
> [!NOTE]
> We're make it work just like a normal UEFI machine so the partitions will resemble that
- Partitioning the USB device (we'll call it /dev/sdN)
  - An EFI partition (FAT32) of reasonable size (will be mounted on /boot and the kernel/initrd will go in there)
  - A partition for / (ext4, btrfs or whatever's your choice)
  I'm going with a 1GiB EFI partition and the remaining space as a single btrfs partition
- Format the partitions
  ```sh
    mkfs.vfat -F32 -n NIXOS_BOOT /dev/sdN1
    mkfs.btrfs -L NIXOS_ROOT /dev/sdN2
  ```
#### Files
- Download the latest release of the Raspberry Pi 4 UEFI firmware [↗](https://github.com/pftf/RPi4/releases)
- Extract the contents onto the EFI partition on the USB disk
  ```sh
    mkdir /tmp/efi
    mount /dev/sdN1 /tmp/efi
    unzip RPi4_UEFI_Firmware_v1.37.zip -d /tmp/efi/
    umount /tmp/efi
  ```
#### Optional: Download the Raspberry Pi device tree overlays
> [!NOTE]
> This is only required if you need a working GPIO, to use any HATs etc.
> I need it because I power the Pi using the PoE+ HAT and the fans on the HAT doesn't work without this.
- Download a recent version of the Raspberry Pi OS[↗](https://www.raspberrypi.com/software/operating-systems/). The 64-bit Lite version should be enough.
- Extract the overlays
  ```sh
    losetup /dev/loop0 2024-03-15-raspios-bookworm-arm64-lite.img
    partx -u /dev/loop0
    mkdir /tmp/firmware
    mount /dev/loop0p1 /tmp/firmware
    mkdir /tmp/efi
    mount /dev/sdN1 /tmp/efi
    mkdir /tmp/efi/overlays
    cp /tmp/firmware/overlays/* /tmp/efi/overlays/
    umount /tmp/efi
  ```

### Installing
Use the installed SD card prepared above to boot the Pi. (Don't plug in the USB drive yet, otherwise the Pi will try to boot from it).
Once it's successfully booted and shows the TTY, plug in the USB drive. At this point the USB drive can be mounted to `/mnt` or anywhere and NixOS can be installed to it with the `nixos-generate-config` and `nixos-install` scripts.

If any HATs are to be used or if the GPIO is needed, make sure to change `boot.kernelPackages` to `pkgs.linuxPackages_rpi4` in the configuration.nix before doing nixos-install.

### Post Install
Once the installation is done, power off the Pi and remove the SD card. Now turning it on with the USB drive plugged in will show a screen with a big Raspberry Pi logo. Press <kbd>Esc</kbd> to go to the UEFI Firmware settings.

Two things need to be changed here.
1. There's a 3GB limit on the RAM due to a hardware bug in the Broadcom SoC. A Kernel version of 5.8 or later has a workaround for this so we can turn off the limit.
Go to `Device Manager` → `Raspberry Pi Configuration` → `Advanced Settings` in the UEFI settings and disable the 3GB limit.
2. **(Optional: only required if HATs/GPIO are used)** In the same `Advanced Settings` page, change the second item from `ACPI` to `ACPI + Device Tree`

Hit <kbd>F10</kbd> to save and use <kbd>Esc</kbd> to go back to the main page. Use the `Continue` option to resume booting. It will ask to reset, press <kbd>Y</kbd>

If everything went well, it should now boot into Freshly installed NixOS, booted from a USB device on the Pi 4 :)
