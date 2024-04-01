# osom package manager

## Install

```bash
git clone https://github.com/osom8979/opm.git ~/.opm
cd ~/.opm
bash ./install.sh
```

## Oracle cloud init

Change your account password (The initial username is `ubuntu`):

```bash
sudo -s
passwd ubuntu
passwd root
```

Change username in **cloud shell**:

```bash
sudo -s
NEW_USERNAME=...
usermod -l ${NEW_USERNAME} ubuntu
groupmod -n ${NEW_USERNAME} ubuntu
usermod -d /home/${NEW_USERNAME} -m ${NEW_USERNAME}
```

Create swapfile in `VM.Standard.E2.1.Micro` instance:

```bash
sudo -s
fallocate -l 2GB /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon -s
echo "/swapfile    none    swap    sw    0    0" >> /etc/fstab
```

## License

See the [LICENSE](./LICENSE) file for details. In summary,
**opm** is licensed under the **MIT license**.
