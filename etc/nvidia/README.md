# NVIDIA CUDA Driver Installation (No Display)

## 1. Boot with nomodeset

At GRUB menu, press `e` to edit boot entry, then add `nomodeset` to the linux line:

```
linux /boot/vmlinuz... root=... quiet splash nomodeset
```

Press `Ctrl+X` to boot.

## 2. Switch to TTY

Press `Ctrl+Alt+F3` to open TTY terminal.

## 3. Stop Display Manager

```bash
sudo systemctl stop gdm      # GNOME
sudo systemctl stop sddm     # KDE
sudo systemctl stop lightdm  # Others
```

## 4. Remove Conflicting Packages

```bash
# Remove old nvidia drivers
sudo apt purge 'nvidia-*'
sudo apt purge 'libnvidia-*'

# Remove nouveau (open source driver)
sudo apt purge xserver-xorg-video-nouveau

# Clean up
sudo apt autoremove
```

## 5. Blacklist Nouveau

```bash
echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
sudo update-initramfs -u
```

## 6. Install NVIDIA Driver

```bash
# Option A: From Ubuntu repo
sudo apt install nvidia-driver-550

# Option B: From .run file
chmod +x NVIDIA-Linux-x86_64-*.run
sudo ./NVIDIA-Linux-x86_64-*.run
```

## 7. Reboot

```bash
sudo reboot
```

## Troubleshooting

Check driver status:
```bash
nvidia-smi
```

If screen still black, boot with nomodeset again and check logs:
```bash
journalctl -b | grep -i nvidia
dmesg | grep -i nvidia
```
