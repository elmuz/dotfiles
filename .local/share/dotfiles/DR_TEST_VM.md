# DR Test VM — libvirt setup guide

How to build a throwaway VM for testing the disaster-recovery procedure
(`INSTALL.sh` → `system-setup.sh` → `restore-from-backup.sh`).

> **Why a VM:** the only way to actually verify the recovery scripts work is to
> rebuild from a fresh install. A VM is a safe, repeatable place to do that —
> it will never touch the real laptop.
>
> **UEFI is used** to match the real laptop's firmware. The scripts themselves
> are boot-method-agnostic, but keeping UEFI gives an honest end-to-end test.

---

## 1. Host prerequisites

```bash
sudo pacman -S --needed qemu-desktop libvirt dnsmasq virt-viewer edk2-ovmf
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt "$USER"   # log out/in after this
```

- `qemu-desktop` — QEMU with the GUI frontends (lighter than `qemu-full`)
- `edk2-ovmf` — **UEFI firmware** for the VM (OVMF)
- `dnsmasq` — DHCP/DNS for libvirt's default NAT network
- `virt-viewer` — to open the VM console
- no host reboot is needed after installing `edk2-ovmf` (it's a firmware library)

Use the **QEMU/KVM (system session**, `qemu:///system`) connection — that's where
the `default` NAT network (`virbr0`, `192.168.122.1`) lives. (Ignore the
`libvirt/LXC` entry virt-manager shows; that's a container driver, not a VM. If
`virt-install` defaulted to the user session, add `--connect qemu:///system`.)

## 2. Download the ISO

```bash
curl -LO https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso
```

## 3. Image location & permissions

Keep the images in libvirt's default pool, where libvirt auto-manages ownership
for the `libvirt-qemu` user (home dirs are `700` and block QEMU otherwise):

```bash
sudo mkdir -p /var/lib/libvirt/images
sudo cp ~/Downloads/archlinux-x86_64.iso /var/lib/libvirt/images/
```

## 4. Create the vanilla base disk + UEFI VM

```bash
sudo qemu-img create -f qcow2 /var/lib/libvirt/images/vanilla.qcow2 60G

virt-install --connect qemu:///system \
  --name arch-dr \
  --memory 8192 --vcpus 4 \
  --disk path=/var/lib/libvirt/images/vanilla.qcow2,format=qcow2 \
  --cdrom /var/lib/libvirt/images/archlinux-x86_64.iso \
  --os-variant archlinux \
  --network network=default \
  --graphics spice \
  --boot uefi \
  --noautoconsole
```

Open the console: `virt-viewer arch-dr`.

> `--boot uefi` is what selects OVMF. Without it the VM boots legacy BIOS and
> `grub-install --target=x86_64-efi` fails with *"EFI variables are not
> supported"* / *"no BIOS boot partition"*.

## 5. Vanilla install (inside the VM)

### Partition (GPT/UEFI, btrfs)
```bash
parted /dev/vda -- mklabel gpt
parted /dev/vda -- mkpart ESP fat32 1MiB 513MiB
parted /dev/vda -- set 1 esp on
parted /dev/vda -- mkpart primary btrfs 513MiB 100%
```

### Format + subvolumes (`@`/`@home`, snapper-friendly)
```bash
mkfs.fat -F32 /dev/vda1
mkfs.btrfs -f /dev/vda2

mount /dev/vda2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
umount /mnt

mount -o subvol=@ /dev/vda2 /mnt
mkdir -p /mnt/home
mount -o subvol=@home /dev/vda2 /mnt/home
mkdir -p /mnt/boot
mount /dev/vda1 /mnt/boot
```

### pacstrap (note `efibootmgr` — required by grub for UEFI)
```bash
pacstrap -K /mnt base base-devel linux linux-firmware btrfs-progs iwd sudo efibootmgr
genfstab -U /mnt >> /mnt/etc/fstab
```

### chroot config
```bash
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "arch-dr" > /etc/hostname   # hostname can be anything
```

### Bootloader (UEFI)
```bash
pacman -S --noconfirm grub       # efibootmgr already installed via pacstrap
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

### User + sudo
```bash
useradd -mG wheel alessio        # use the SAME username as the laptop
passwd alessio
echo "alessio ALL=(ALL:ALL) ALL" > /etc/sudoers.d/alessio
```
> **Same username matters:** `restore-from-backup.sh` defaults to `$USER` and the
> backup stores `/home/alessio/...`; several tracked configs also hardcode
> `/home/alessio`.

### Network (VM has no wifi — ethernet via systemd-networkd)
```bash
cat > /etc/systemd/network/20-wired.network <<'EOF'
[Match]
Name=enp1s0

[Network]
DHCP=yes
EOF

systemctl enable --now systemd-networkd systemd-resolved iwd
```
> `iwd` manages wifi only; the VM's virtio NIC (`enp1s0`) needs `systemd-networkd`
> for DHCP. On the real laptop, wifi is handled by iwd — this is a VM-only step.

### Finish
```bash
exit
umount -R /mnt
reboot
```

Log in as `alessio`, confirm internet:
```bash
curl -sI https://archlinux.org | head -1
```

## 6. Snapshot the vanilla state (overlay)

`vanilla.qcow2` is now your pristine baseline — **never boot it directly again**.

Create a thin overlay for the actual test:
```bash
sudo qemu-img create -f qcow2 -F qcow2 \
  -b /var/lib/libvirt/images/vanilla.qcow2 \
  /var/lib/libvirt/images/test.qcow2
```
Point the VM's disk at `test.qcow2` (virt-manager → edit → disk → change path,
or `virsh edit arch-dr`).

## 7. Run a DR test
```bash
virsh -c qemu:///system start arch-dr     # boots from the overlay
```
then inside the VM:
```bash
curl -sSL https://raw.githubusercontent.com/elmuz/dotfiles/main/.local/share/dotfiles/INSTALL.sh | sh
```
(replace `main` with the tested tag/commit)

## 8. Revert to vanilla (instant factory reset)
```bash
virsh -c qemu:///system destroy arch-dr 2>/dev/null
sudo rm -f /var/lib/libvirt/images/test.qcow2
sudo qemu-img create -f qcow2 -F qcow2 \
  -b /var/lib/libvirt/images/vanilla.qcow2 \
  /var/lib/libvirt/images/test.qcow2
virsh -c qemu:///system start arch-dr
```
Because `vanilla.qcow2` is never modified, deleting the overlay is a full reset.
Each retest is ~2 minutes.

---

## Gotchas (learned the hard way)

| Symptom | Cause | Fix |
|---------|-------|-----|
| `virt-install` → "Network not found: default" | It used the **user** session | add `--connect qemu:///system` |
| "EFI variables are not supported" / "no BIOS boot partition" | VM in **legacy BIOS** mode | install `edk2-ovmf` + `--boot uefi` |
| Images in `~/...` → permission denied | home is `700`, QEMU runs as `libvirt-qemu` | put images in `/var/lib/libvirt/images` |
| No network after reboot, `enp1s0` DOWN | `iwd` handles wifi only | enable `systemd-networkd` + `20-wired.network` |