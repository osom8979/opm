# GRUB

## Manual Boot

If GRUB menu is broken, you can boot manually.

### 1. Enter GRUB Command Line

Press `c` at GRUB menu to open command line.

### 2. Find Your Disk

```
ls
```

This shows all disks like `(hd0,gpt1)`, `(hd0,gpt2)`, etc.

To check contents:

```
ls (hd0,gpt2)/
```

Find the partition with `/boot` or `/vmlinuz`.

### 3. Set Root

```
set root=(hd0,gpt2)
```

Use your partition number.

### 4. Load Kernel

```
linux /vmlinuz root=/dev/sda2 ro
```

- Change `/dev/sda2` to your root partition
- If kernel is in `/boot`: `linux /boot/vmlinuz root=/dev/sda2 ro`

### 5. Load Initramfs

```
initrd /initrd.img
```

Or `/boot/initrd.img` if in boot folder.

### 6. Boot

```
boot
```

### Quick Example

```
set root=(hd0,gpt2)
linux /vmlinuz root=/dev/sda2 ro quiet
initrd /initrd.img
boot
```

### Tips

- Use `Tab` for auto-complete
- `ls (hd0,gpt2)/` to browse files
- NVMe disks: root is `/dev/nvme0n1p2` not `/dev/sda2`
