timedatectl set-ntp true
loadkeys br-abnt2

cfdisk /dev/nvme0
cfdisk /dev/sda

mkfs.vfat -F32 /dev/nvme0n1p1
mkfs.btrfs /dev/nvme0n1p2
mkfs.xfs /dev/sda1

mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot/EFI
mount /dev/nvme0n1p1 /mnt/boot/EFI
mkdir /mnt/home
mount /dev/sda1 /mnt/home

pacstrap /mnt base base-devel git linux linux-firmware nano sudo

genfstab -U /mnt >> /mnt/etc/fstab
noatime,compress=zstd:3


cat /mnt/etc/fstab
arch-chroot /mnt


ln -sf /usr/share/zoneinfo/America/Bahia /etc/localtime
hwclock --systohc

nano /etc/locale.gen    pt_BR.UTF-8
echo LANG=pt_BR.UTF-8 >> /etc/locale.conf
locale-gen

EDITOR=nano visudo
%wheel ALL=(ALL) ALL

useradd -m -G wheel ciromota
passwd ciromota