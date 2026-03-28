#!/usr/bin/env bash

test "$UID" = 0 || exec sudo "$0" "$@"

if ! ping -c 1 1.1.1.1 &> /dev/null; then
  echo "No internet connection"
  exit 1
fi

TYPE=""
while [ -z "$TYPE" ]; do
  clear
  echo "Which machine should I install?"
  echo
  read -r -p "> " MACHINE

  if CFG="$(machines | tail -n +2 | sed "s/^/@/" | grep -F "@$MACHINE,")"; then
    TYPE="$(cut -d , -f 2 <<< "$CFG")"
    BOOT="$(cut -d , -f 3 <<< "$CFG")"
  fi
done

DEV=""
until [ -b "$DEV" ]; do
  clear
  echo "Which device should I use?"
  echo
  lsblk
  echo
  read -r -p "> " DEV
  test -b "$DEV" || DEV="/dev/$DEV"
done

if [ "$BOOT" = "SB" ]; then
  if ! sbctl status &> /dev/null || [ "$(sbctl status --json | jq .setup_mode)" = "false" ]; then
    echo "Secure boot is disabled or not in setup mode"
    exit 1
  fi
fi

if [ "$BOOT" = "BIOS" ]; then
  echo "Formatting $DEV..."
  parted "$DEV" -- mklabel msdos
  parted "$DEV" -- mkpart primary btrfs 512MB 100%
  parted "$DEV" -- mkpart primary fat32 1MB 512MB
  parted "$DEV" -- set 2 boot on

  PART_NIXOS=""
  until [ -b "$PART_NIXOS" ]; do
    clear
    echo "Where is the system partition?"
    echo
    lsblk
    echo
    read -r -p "> " PART_NIXOS
    test -b "$PART_NIXOS" || PART_NIXOS="/dev/$PART_NIXOS"
  done

  PART_BOOT=""
  until [ -b "$PART_BOOT" ]; do
    clear
    echo "Where is the boot partition?"
    echo
    lsblk
    echo
    read -r -p "> " PART_BOOT
    test -b "$PART_BOOT" || PART_BOOT="/dev/$PART_BOOT"
  done
else
  echo "Formatting $DEV..."
  parted "$DEV" -- mklabel gpt
  parted "$DEV" -- mkpart nixos btrfs 512MB 100%
  parted "$DEV" -- mkpart BOOT fat32 1MB 512MB
  parted "$DEV" -- set 2 esp on

  echo "Waiting for partitions..."
  PART_NIXOS="/dev/disk/by-partlabel/nixos"
  until [ -b "$PART_NIXOS" ]; do sleep 1; done

  PART_BOOT="/dev/disk/by-partlabel/BOOT"
  until [ -b "$PART_BOOT" ]; do sleep 1; done
fi

if [ "$TYPE" = "desktop" ]; then
  echo "Encrypting root partition..."
  read -rs -p "Enter disk encryption password: " FDE_PASS

  cryptsetup luksFormat "$PART_NIXOS" <<< "$FDE_PASS"
  cryptsetup open "$PART_NIXOS" nixos <<< "$FDE_PASS"

  unset FDE_PASS
  PART_NIXOS="/dev/mapper/nixos"
fi

echo "Creating filesystems..."
mkfs.btrfs --force --label nixos "$PART_NIXOS"
mkfs.fat -F 32 -n BOOT "$PART_BOOT"

echo "Creating subvolumes..."
mount "$PART_NIXOS" /mnt
btrfs subvolume create /mnt/{nix,perm,root}
umount /mnt

echo "Mounting partitions..."
mount -o compress=zstd,subvol=root "$PART_NIXOS" /mnt
mkdir /mnt/{boot,nix,perm}
mount -o compress=zstd,noatime,subvol=nix "$PART_NIXOS" /mnt/nix
mount -o compress=zstd,subvol=perm "$PART_NIXOS" /mnt/perm
mount -o umask=077 "$PART_BOOT" /mnt/boot

if [ "$BOOT" = "SB" ]; then
  echo "Setting up secure boot..."
  mkdir -p /mnt/perm/var/lib/sbctl
  ln -s /mnt/perm/var/lib/sbctl /var/lib/sbctl
  sbctl create-keys
  sbctl enroll-keys --microsoft
fi

echo "Generating hardware configuration..."
mkdir -p /mnt/perm/etc/nixos
nixos-generate-config --root /mnt --show-hardware-config --no-filesystems > /mnt/perm/etc/nixos/hardware.nix
ln -s /mnt/perm/etc/nixos/hardware.nix /etc/nixos/hardware.nix
test "$BOOT" = "BIOS" && sed -i "\$i\\  boot.loader.grub.device = \"$DEV\";" /mnt/perm/etc/nixos/hardware.nix

echo "Cloning NixOS configuration..."
git clone https://github.com/pdiehm/nixos.git /mnt/perm/home/pascal/.config/nixos
git --git-dir /mnt/perm/home/pascal/.config/nixos/.git remote set-url origin git@github.com:pdiehm/nixos.git
chown --recursive 1000:100 /mnt/perm/home/pascal
chmod 700 /mnt/perm/home/pascal

echo "Preparing GnuPG..."
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
echo "pinentry-program $(which pinentry-tty)" > ~/.gnupg/gpg-agent.conf

echo "Setting up GnuPG..."
mkdir -p /mnt/perm/etc/nixos/.gnupg
chmod 700 /mnt/perm/etc/nixos/.gnupg
echo "disable-scdaemon" > /mnt/perm/etc/nixos/.gnupg/gpg-agent.conf

echo "Installing secret key..."
curl -fsSLO "https://raw.githubusercontent.com/pdiehm/nixos/main/resources/secrets/$TYPE/key.gpg"
gpg --decrypt key.gpg | gpg --homedir /mnt/perm/etc/nixos/.gnupg --import

echo "Installing NixOS..."
nixos-install --impure --no-channel-copy --no-root-password --flake "github:pdiehm/nixos#$MACHINE"
