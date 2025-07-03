Certainly! Here's a comprehensive `README.md` reflecting your improvements, written clearly and professionally without emojis:


# Cursor AI IDE Installer for Linux

This project provides a fully rewritten, robust, and user-friendly installer script for installing, updating, and uninstalling the Cursor AI IDE on Linux systems. It enhances compatibility across major Linux distributions and offers an improved command-line interface (CLI) experience with dynamic feedback and versatile options.

---

## Features

### User Interface Improvements
- ANSI color-formatted ASCII art logo for a visually appealing CLI experience  
- Dynamic progress bars and spinners to provide real-time installation feedback  
- Clean, straightforward CLI messages without emojis for professional output  

### Enhanced Dependency Management
- Automatic detection of required dependencies  
- Smart package manager support across popular distros including APT, DNF, YUM, Pacman, and Zypper  
- Visualized installation progress per package for clarity  

### AppImage and Native Installer Support
- Attempts native installation using system packages (`.deb`, `.rpm`, AUR) when available  
- Automatic fallback to downloading and installing the AppImage version if native installation is not feasible  
- Option to manually specify a local AppImage file path for offline or custom installations  

### System Integration
- Creates proper desktop entries (`.desktop` files) for seamless menu integration  
- Installs application icons for easy identification  
- Adds a command-line symlink (`cursor`) to `/usr/local/bin` for VSCode-like command line launching  

### Interactive and Flag-Based Operation Modes
- Interactive menu-driven installer for ease of use, especially for beginners  
- Support for direct flags (`--install`, `--update`, `--uninstall`, `--help`) enabling scripting and automation  

### Update Process
- Safe and reliable update mechanism with automatic backup of the previous installation  
- Rollback support on update failure to prevent broken installs  

### Uninstallation
- Complete removal of installed files, desktop entries, icons, and command-line symlinks  
- Clean system state restoration after uninstall  

---

## Prerequisites

The installer requires these packages:

- `curl`  
- `wget`  
- `jq`  
- `figlet`  
- `rsync`  

The script detects and installs any missing dependencies on supported distributions automatically.

---

## Supported Linux Distributions

Tested and compatible with major Linux distributions using the following package managers:

- `apt` (Ubuntu, Debian, Linux Mint)  
- `dnf` (Fedora, CentOS 8+, RHEL 8+)  
- `yum` (CentOS, RHEL 7 and older)  
- `pacman` (Arch Linux, Manjaro)  
- `zypper` (openSUSE, SLES)  

---

## Quick Start

Run the installer with root privileges:

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/khodealib/CursorInstaller/master/cursor-install.sh)"
```

Follow the interactive menu or use command-line flags:

* `--install` : Install Cursor IDE
* `--update` : Update existing installation
* `--uninstall` : Remove Cursor IDE completely
* `--help` : Display usage instructions

---

## Detailed Usage

### Installation

You can choose between:

* **Automatic Native Installation**: Installs the native package if available for your distro.
* **AppImage Installation**: Downloads and installs the latest Cursor AppImage or uses a manually specified AppImage file.

### Updating

The update process backs up your current installation before applying the new version. If the update fails, it restores the previous state automatically.

### Uninstallation

Removes all installed files including:

* Application files in `/opt/Cursor/`
* Desktop entries in `/usr/share/applications/cursor.desktop`
* Application icon in `/usr/share/pixmaps/cursor.png`
* Command-line symlink `/usr/local/bin/cursor`

---

## Manual Operation

If preferred, you can manually perform the following steps:

1. Download and extract the Cursor AppImage or native package
2. Copy application files to `/opt/Cursor/`
3. Create a desktop entry in `/usr/share/applications/`
4. Install the icon in `/usr/share/pixmaps/`
5. Create a symlink in `/usr/local/bin/` pointing to the executable
6. Update the desktop database using `update-desktop-database`

---

## Troubleshooting

### Permission Issues

Ensure the installer script is executable:

```bash
chmod +x cursor-install.sh
```

### Missing Dependencies

Manually install missing dependencies using your package manager if automatic install fails:

```bash
# Ubuntu/Debian example
sudo apt-get update
sudo apt-get install curl wget jq figlet rsync
```

### Desktop Entry Missing

Run:

```bash
sudo update-desktop-database
```

### `cursor` Command Not Found

Verify the symlink:

```bash
ls -la /usr/local/bin/cursor
```

Create it manually if missing:

```bash
sudo ln -sf /opt/Cursor/AppRun /usr/local/bin/cursor
```

Ensure `/usr/local/bin` is in your PATH environment variable.

---

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m "Add your feature"`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

Please maintain code style, add tests, and update documentation accordingly.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Support

For issues and discussions, visit:

* [GitHub Issues](https://github.com/khodealib/CursorInstaller/issues)
* [GitHub Discussions](https://github.com/khodealib/CursorInstaller/discussions)

---

*Thank you for using the Cursor AI IDE Installer.*
