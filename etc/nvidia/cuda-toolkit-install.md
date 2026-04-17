# CUDA SDK Run File Installation Guide

## Basic Installation

```bash
chmod +x cuda_12.4.0_550.54.14_linux.run
sudo ./cuda_12.4.0_550.54.14_linux.run
```

## Common Installation Scenarios

### 1. Install Both Driver and Toolkit (Interactive)

```bash
sudo ./cuda_12.4.0_550.54.14_linux.run
```

You can choose components from the interactive menu.

### 2. Install Toolkit Only (When Driver Is Already Installed)

```bash
sudo ./cuda_12.4.0_550.54.14_linux.run --silent --toolkit
```

### 3. Install Driver Only

```bash
sudo ./cuda_12.4.0_550.54.14_linux.run --silent --driver
```

### 4. Install Toolkit to a Custom Path

```bash
sudo ./cuda_12.4.0_550.54.14_linux.run --silent --toolkit \
  --toolkitpath=/opt/cuda-12.4
```

Default path: `/usr/local/cuda-12.4`

### 5. Headless Server (No Display)

```bash
sudo ./cuda_12.4.0_550.54.14_linux.run --silent \
  --driver --toolkit --no-opengl-libs --no-drm
```

- `--no-opengl-libs`: Skip installing NVIDIA GL libraries (when a non-NVIDIA GPU drives the display)
- `--no-drm`: Skip installing the nvidia-drm kernel module

### 6. Use the Open Kernel Module (Turing or Newer)

```bash
sudo ./cuda_12.4.0_550.54.14_linux.run --silent \
  --driver --toolkit -m=kernel-open
```

### 7. Extract Run File Only

```bash
./cuda_12.4.0_550.54.14_linux.run --extract=/tmp/cuda-extracted
```

Useful when you want to extract the driver runfile separately and install it with custom options.

## Key Options Summary

| Option | Purpose |
|--------|---------|
| `--silent` | Unattended installation (auto-accepts EULA) |
| `--driver` | Install the driver |
| `--toolkit` | Install the toolkit |
| `--toolkitpath=<path>` | Specify the toolkit installation path |
| `--installpath=<path>` | Install path for all components (overrides toolkitpath) |
| `--override` | Ignore compiler version checks |
| `--no-opengl-libs` | Exclude GL libraries |
| `--no-drm` | Exclude the nvidia-drm module |
| `--no-man-page` | Do not install man pages |
| `--kernel-module-build-directory=<kernel\|kernel-open>` | Select the kernel module build flavor |
| `--kernel-source-path=<path>` | Specify a non-standard kernel source path |
| `--kernel-output-path=<path>` | Specify a non-standard kernel output path |
| `--run-nvidia-xconfig` | Update X configuration via nvidia-xconfig |
| `--tmpdir=<path>` | Use a custom temporary directory instead of `/tmp` |

## Post-Installation Environment Variables

```bash
echo 'export PATH=/usr/local/cuda-12.4/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

## Verify the Installation

```bash
nvcc --version
nvidia-smi
```

## Notes

- Using the `--silent` option implies acceptance of the EULA.
- When running without root permissions, additional command-line options may be required for further customization.
- Do not use `--run-nvidia-xconfig` on systems that require a custom X configuration or where a non-NVIDIA GPU drives the display.
- Use the `--no-drm` option only to work around failures to build or install the nvidia-drm kernel module. It disables PRIME, DRM-KMS, and X11 autoconfiguration.
