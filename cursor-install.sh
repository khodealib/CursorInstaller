#!/bin/bash

# --- Global Variables ---
CURSOR_EXTRACT_DIR="/opt/Cursor"
ICON_PATH="/usr/share/pixmaps/cursor.png"
EXECUTABLE_PATH="${CURSOR_EXTRACT_DIR}/AppRun"
DESKTOP_ENTRY_PATH="/usr/share/applications/cursor.desktop"
SYMLINK_PATH="/usr/local/bin/cursor"

# --- Download Latest Cursor AppImage Function ---
download_latest_cursor_appimage() {
    API_URL="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
    USER_AGENT="Mozilla/5.0 (X11; Linux x86_64)"
    DOWNLOAD_PATH="/tmp/latest-cursor.AppImage"
    FINAL_URL=$(curl -sL -A "$USER_AGENT" "$API_URL" | jq -r '.url // .downloadUrl')

    if [ -z "$FINAL_URL" ] || [ "$FINAL_URL" = "null" ]; then
        echo "❌ Could not retrieve the final AppImage URL." >&2
        return 1
    fi

    echo "Downloading AppImage from: $FINAL_URL"
    wget -q -O "$DOWNLOAD_PATH" "$FINAL_URL"

    if [ $? -eq 0 ] && [ -s "$DOWNLOAD_PATH" ]; then
        echo "✅ Downloaded successfully!" >&2
        echo "$DOWNLOAD_PATH"
        return 0
    else
        echo "❌ Download failed." >&2
        return 1
    fi
}

# --- Install Function ---
installCursor() {
    if [ -d "$CURSOR_EXTRACT_DIR" ]; then
        echo "⚠️ Already installed at $CURSOR_EXTRACT_DIR"
        echo "Use the update option instead."
        return
    fi

    figlet -f slant "Install Cursor"
    echo "1. Download latest AppImage automatically"
    echo "2. Provide local AppImage path"
    read -p "Choose 1 or 2: " appimage_option

    local CURSOR_DOWNLOAD_PATH=""

    if [ "$appimage_option" = "1" ]; then
        for cmd in curl wget jq; do
            if ! command -v $cmd &>/dev/null; then
                echo "$cmd not found. Installing..."
                sudo apt-get update
                sudo apt-get install -y $cmd
            fi
        done
        CURSOR_DOWNLOAD_PATH=$(download_latest_cursor_appimage | tail -n 1)
        if [ $? -ne 0 ] || [ ! -f "$CURSOR_DOWNLOAD_PATH" ]; then
            echo "❌ Download failed. Enter path manually? (y/n)"
            read -r retry
            if [[ "$retry" =~ ^[Yy]$ ]]; then
                read -p "Enter AppImage path: " CURSOR_DOWNLOAD_PATH
            else
                echo "Exiting."
                exit 1
            fi
        fi
    else
        read -p "Enter AppImage file path: " CURSOR_DOWNLOAD_PATH
    fi

    if [ ! -f "$CURSOR_DOWNLOAD_PATH" ]; then
        echo "❌ File does not exist: $CURSOR_DOWNLOAD_PATH"
        exit 1
    fi

    chmod +x "$CURSOR_DOWNLOAD_PATH"
    echo "Extracting AppImage..."
    (cd /tmp && "$CURSOR_DOWNLOAD_PATH" --appimage-extract >/dev/null)
    if [ ! -d "/tmp/squashfs-root" ]; then
        echo "❌ Extraction failed."
        sudo rm -f "$CURSOR_DOWNLOAD_PATH"
        exit 1
    fi

    echo "Installing to ${CURSOR_EXTRACT_DIR}..."
    sudo mkdir -p "$CURSOR_EXTRACT_DIR"
    sudo rsync -a --remove-source-files /tmp/squashfs-root/ "$CURSOR_EXTRACT_DIR/"
    sudo rm -f "$CURSOR_DOWNLOAD_PATH"
    sudo rm -rf /tmp/squashfs-root

    # Install icon from AppImage to standard location
    echo "Installing icon..."
    if [ -f "${CURSOR_EXTRACT_DIR}/usr/share/icons/hicolor/128x128/apps/cursor.png" ]; then
        sudo cp "${CURSOR_EXTRACT_DIR}/usr/share/icons/hicolor/128x128/apps/cursor.png" "$ICON_PATH"
    elif [ -f "${CURSOR_EXTRACT_DIR}/cursor.png" ]; then
        sudo cp "${CURSOR_EXTRACT_DIR}/cursor.png" "$ICON_PATH"
    elif [ -f "${CURSOR_EXTRACT_DIR}/resources/app/assets/cursor.png" ]; then
        sudo cp "${CURSOR_EXTRACT_DIR}/resources/app/assets/cursor.png" "$ICON_PATH"
    else
        echo "⚠️  Icon not found in AppImage, using default application icon"
    fi

    echo "Creating desktop entry..."
    sudo bash -c "cat > \"$DESKTOP_ENTRY_PATH\"" <<EOL
[Desktop Entry]
Name=Cursor AI IDE
Exec=${EXECUTABLE_PATH} --no-sandbox
Icon=cursor
Type=Application
Categories=Development;
EOL

    # Update desktop database
    sudo update-desktop-database

    # Create symlink for command line access
    echo "Creating command line symlink..."
    sudo ln -sf "$EXECUTABLE_PATH" "$SYMLINK_PATH"

    echo "✅ Cursor installation complete!"
    echo "You can now run 'cursor' from anywhere in the terminal!"
}

# --- Update Function ---
updateCursor() {
    if [ ! -d "$CURSOR_EXTRACT_DIR" ]; then
        echo "❌ Cursor is not installed."
        return
    fi

    figlet -f slant "Update Cursor"
    echo "1. Download latest version"
    echo "2. Use existing AppImage file"
    read -p "Choose 1 or 2: " appimage_option

    local CURSOR_DOWNLOAD_PATH=""

    if [ "$appimage_option" = "1" ]; then
        CURSOR_DOWNLOAD_PATH=$(download_latest_cursor_appimage | tail -n 1)
        if [ $? -ne 0 ] || [ ! -f "$CURSOR_DOWNLOAD_PATH" ]; then
            echo "❌ Download failed."
            exit 1
        fi
    else
        read -p "Enter new AppImage file path: " CURSOR_DOWNLOAD_PATH
    fi

    if [ ! -f "$CURSOR_DOWNLOAD_PATH" ]; then
        echo "❌ File not found: $CURSOR_DOWNLOAD_PATH"
        exit 1
    fi

    chmod +x "$CURSOR_DOWNLOAD_PATH"
    (cd /tmp && "$CURSOR_DOWNLOAD_PATH" --appimage-extract >/dev/null)
    if [ ! -d "/tmp/squashfs-root" ]; then
        echo "❌ Extraction failed."
        sudo rm -f "$CURSOR_DOWNLOAD_PATH"
        exit 1
    fi

    echo "Replacing old version..."
    sudo rm -rf "${CURSOR_EXTRACT_DIR:?}"/*
    sudo rsync -a --remove-source-files /tmp/squashfs-root/ "$CURSOR_EXTRACT_DIR/"
    sudo rm -f "$CURSOR_DOWNLOAD_PATH"
    sudo rm -rf /tmp/squashfs-root

    # Update symlink for command line access
    echo "Updating command line symlink..."
    sudo ln -sf "$EXECUTABLE_PATH" "$SYMLINK_PATH"

    echo "✅ Cursor updated successfully."
}

# --- Uninstall Function ---
uninstallCursor() {
    figlet -f slant "Uninstall Cursor"
    echo "⚠️  This will remove Cursor AI IDE."
    read -p "Are you sure? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Uninstallation canceled."
        return
    fi

    if [ -d "$CURSOR_EXTRACT_DIR" ]; then
        sudo rm -rf "$CURSOR_EXTRACT_DIR"
        echo "✅ Removed directory: $CURSOR_EXTRACT_DIR"
    else
        echo "ℹ️ Directory not found."
    fi

    if [ -f "$DESKTOP_ENTRY_PATH" ]; then
        sudo rm -f "$DESKTOP_ENTRY_PATH"
        echo "✅ Removed desktop entry."
    fi

    if [ -f "$ICON_PATH" ]; then
        sudo rm -f "$ICON_PATH"
        echo "✅ Removed icon file."
    fi

    if [ -L "$SYMLINK_PATH" ] || [ -f "$SYMLINK_PATH" ]; then
        sudo rm -f "$SYMLINK_PATH"
        echo "✅ Removed command line symlink."
    fi

    # Update desktop database
    sudo update-desktop-database

    echo "✅ Cursor uninstalled completely."
}

# --- Main Menu ---
if ! command -v figlet &>/dev/null; then
    echo "Installing figlet..."
    sudo apt-get update
    sudo apt-get install -y figlet
fi

figlet -f slant "Cursor AI IDE"
echo "Ubuntu 24.04 compatible"
echo "--------------------------------------------"
echo "1. Install Cursor"
echo "2. Update Cursor"
echo "3. Uninstall Cursor"
echo "--------------------------------------------"
read -p "Choose an option (1/2/3): " choice

case $choice in
1)
    installCursor
    ;;
2)
    updateCursor
    ;;
3)
    uninstallCursor
    ;;
*)
    echo "❌ Invalid option."
    exit 1
    ;;
esac

exit 0
