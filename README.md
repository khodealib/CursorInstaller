# 🎯 Cursor AI IDE Installer

A convenient bash script to install, update, and uninstall [Cursor AI IDE](https://cursor.com) on Linux systems. This
installer automatically downloads the latest Cursor AppImage and sets up a proper system integration with desktop
entries and icons.

## ✨ Features

-   **🚀 Easy Installation**: One-command installation with automatic AppImage download
-   **🔄 Auto-Update**: Download and install the latest version automatically
-   **🗑️ Clean Uninstall**: Complete removal of all installed files and desktop entries
-   **🎨 Desktop Integration**: Creates proper desktop entries with icons
-   **⌨️ Command Line Access**: Adds `cursor` command to PATH (like VSCode's `code` command)
-   **📱 Interactive Menu**: User-friendly menu interface with ASCII art
-   **🔧 Flexible Options**: Support for both automatic download and local AppImage files
-   **🐧 Linux Compatible**: Optimized for Ubuntu 24.04 and other Debian-based distributions

## 📋 Prerequisites

Before running the installer, ensure you have the following dependencies:

-   **curl** - For downloading files
-   **wget** - For downloading AppImage files
-   **jq** - For parsing JSON responses
-   **figlet** - For ASCII art display
-   **rsync** - For file synchronization

> **Note**: The script will automatically install missing dependencies on Ubuntu/Debian systems.

## 🚀 Quick Start

1. **Download the installer**:

    ```bash
    wget https://raw.githubusercontent.com/khodealib/CursorInstaller/master/cursor-install.sh
    chmod +x cursor-install.sh
    ```

2. **Run the installer**:

    ```bash
    ./cursor-install.sh
    ```

3. **Choose your option**:

    - `1` - Install Cursor AI IDE
    - `2` - Update existing installation
    - `3` - Uninstall Cursor AI IDE

4. **Start using Cursor**:
    ```bash
    cursor                    # Launch Cursor
    cursor /path/to/project   # Open a project
    cursor .                  # Open current directory
    ```

## 📖 Detailed Usage

### Installation Process

When you choose to install Cursor, you'll have two options:

1. **Automatic Download** (Recommended):

    - Downloads the latest stable version from Cursor's official API
    - Automatically handles version detection and download

2. **Local AppImage**:
    - Use an existing AppImage file you've downloaded
    - Useful for offline installations or specific versions

### Installation Locations

The installer sets up Cursor in the following locations:

-   **Application**: `/opt/Cursor/`
-   **Desktop Entry**: `/usr/share/applications/cursor.desktop`
-   **Icon**: `/usr/share/pixmaps/cursor.png`
-   **Executable**: `/opt/Cursor/AppRun`
-   **Command Line Symlink**: `/usr/local/bin/cursor`

### Desktop Integration

After installation, Cursor will be available:

-   In your application menu under "Development"
-   As a desktop entry with proper icon
-   From the command line using the `cursor` command (like VSCode's `code` command)
-   Launchable from command line via the desktop entry

## 🔧 Advanced Usage

### Running Cursor from Command Line

After installation, you can run Cursor in several ways:

**Using the `cursor` command** (Recommended - works like VSCode's `code` command):

```bash
cursor                    # Launch Cursor
cursor /path/to/project   # Open a specific project
cursor file.txt           # Open a specific file
cursor .                  # Open current directory
```

**Direct execution**:

```bash
/opt/Cursor/AppRun
```

**Using the desktop entry**:

```bash
gtk-launch cursor
```

### Manual Installation Steps

If you prefer to understand what the script does:

1. Downloads/extracts the Cursor AppImage
2. Copies files to `/opt/Cursor/`
3. Creates a desktop entry file
4. Installs the application icon
5. Creates a command line symlink (`/usr/local/bin/cursor`)
6. Updates the desktop database

## 🛠️ Troubleshooting

### Common Issues

**Permission Denied**:

```bash
chmod +x cursor-install.sh
```

**Missing Dependencies**:

```bash
sudo apt-get update
sudo apt-get install curl wget jq figlet rsync
```

**Download Fails**:

-   Check your internet connection
-   Try using option 2 with a manually downloaded AppImage
-   Verify the Cursor API is accessible

**Desktop Entry Not Appearing**:

```bash
sudo update-desktop-database
```

**`cursor` Command Not Found**:

```bash
# Check if symlink exists
ls -la /usr/local/bin/cursor

# If missing, reinstall or create manually
sudo ln -sf /opt/Cursor/AppRun /usr/local/bin/cursor

# Make sure /usr/local/bin is in your PATH
echo $PATH | grep -q /usr/local/bin || echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to the branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Development Guidelines

-   Follow existing code style and formatting
-   Test your changes on multiple Linux distributions
-   Update documentation for any new features
-   Ensure backward compatibility

## 📊 Compatibility

**Tested On**:

-   Ubuntu 24.04 LTS
-   Ubuntu 22.04 LTS
-   Debian 12
-   Linux Mint 21+

**Should Work On**:

-   Most Debian-based distributions
-   Systems with `systemd` and standard directory structure

## 🔒 Security

This installer:

-   Only downloads from official Cursor sources
-   Verifies file integrity before installation
-   Uses secure download methods (HTTPS)
-   Requires explicit user confirmation for destructive operations

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

-   [Cursor AI](https://cursor.com) for creating an amazing AI-powered IDE
-   The Linux community for continuous support and feedback
-   Contributors who help improve this installer

## 📞 Support

-   **Issues**: [GitHub Issues](https://github.com/khodealib/CursorInstaller/issues)
-   **Discussions**: [GitHub Discussions](https://github.com/khodealib/CursorInstaller/discussions)

---

⭐ **Star this repository** if you found it helpful!

💡 **Have suggestions?** Open an issue or pull request!
