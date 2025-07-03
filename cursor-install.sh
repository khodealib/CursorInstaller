#!/bin/bash

# ============================================================================
# Enhanced Cursor IDE Linux Installer
# Cross-distribution compatible installer for Cursor IDE
# Supports Ubuntu/Debian, Fedora/RHEL, Arch Linux, and others
# Enhanced with progress bars and screen clearing functionality
# ============================================================================

# --- ANSI Color Codes ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# --- Global Variables ---
CURSOR_EXTRACT_DIR="/opt/Cursor"
ICON_PATH="/usr/share/pixmaps/cursor.png"
EXECUTABLE_PATH="${CURSOR_EXTRACT_DIR}/AppRun"
DESKTOP_ENTRY_PATH="/usr/share/applications/cursor.desktop"
SYMLINK_PATH="/usr/local/bin/cursor"
REQUIRED_PACKAGES=("curl" "wget" "jq" "figlet" "rsync")

# --- Screen Clearing Function ---
clear_screen() {
    clear
    # Alternative method for better compatibility
    printf '\033[2J\033[H'
}

# --- Progress Bar Function ---
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    local remaining=$((width - completed))
    
    printf "\r["
    printf '%*s' $completed | tr ' ' '='
    printf '%*s' $remaining | tr ' ' '-'
    printf "] %d%%" $percentage
}

# --- Spinner Function ---
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# --- Progress Bar for Downloads ---
download_with_progress() {
    local url=$1
    local output=$2
    local description=$3
    
    print_info "$description"
    
    # Use wget with progress bar
    wget --progress=bar:force -O "$output" "$url" 2>&1 | \
    while IFS= read -r line; do
        if [[ $line =~ [0-9]+% ]]; then
            echo -ne "\r$line"
        fi
    done
    echo ""
}

# --- Progress Bar for Package Installation ---
install_with_progress() {
    local packages=("$@")
    local total=${#packages[@]}
    local current=0
    
    for package in "${packages[@]}"; do
        current=$((current + 1))
        show_progress $current $total
        printf " Installing %s..." "$package"
        (
            case $DISTRO_FAMILY in
                debian)
                    sudo apt-get install -y "$package" &>/dev/null
                    ;;
                rhel)
                    if command -v dnf &>/dev/null; then
                        sudo dnf install -y "$package" &>/dev/null
                    else
                        sudo yum install -y "$package" &>/dev/null
                    fi
                    ;;
                arch)
                    sudo pacman -S --noconfirm "$package" &>/dev/null
                    ;;
                suse)
                    sudo zypper install -y "$package" &>/dev/null
                    ;;
            esac
        ) &
        show_spinner $!
        wait
        printf "\r"
        show_progress $current $total
        printf " Installing %s... Done\n" "$package"
    done
    printf "\n"
}

# --- ASCII Art Display Function ---
display_cursor_logo() {
    echo -e "${CYAN}${BOLD}"
    cat << 'EOF'
     ██████╗██╗   ██╗██████╗ ███████╗ ██████╗ ██████╗ 
    ██╔════╝██║   ██║██╔══██╗██╔════╝██╔═══██╗██╔══██╗
    ██║     ██║   ██║██████╔╝███████╗██║   ██║██████╔╝
    ██║     ██║   ██║██╔══██╗╚════██║██║   ██║██╔══██╗
    ╚██████╗╚██████╔╝██║  ██║███████║╚██████╔╝██║  ██║
     ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
                                                        
            █████╗ ██╗    ██╗██████╗ ███████╗           
           ██╔══██╗██║    ██║██╔══██╗██╔════╝           
           ███████║██║    ██║██║  ██║█████╗             
           ██╔══██║██║    ██║██║  ██║██╔══╝             
           ██║  ██║██║    ██║██████╔╝███████╗           
           ╚═╝  ╚═╝╚═╝    ╚═╝╚═════╝ ╚══════╝           
                                                        
EOF
    echo -e "${RESET}"
    echo -e "${BOLD}${BLUE}         Advanced AI-Powered Code Editor${RESET}"
    echo -e "${CYAN}         Linux Installation Manager${RESET}"
    echo ""
}

# --- Print Colored Messages ---
print_success() {
    echo -e "${GREEN}${BOLD}[SUCCESS]${RESET} $1"
}

print_error() {
    echo -e "${RED}${BOLD}[ERROR]${RESET} $1"
}

print_warning() {
    echo -e "${YELLOW}${BOLD}[WARNING]${RESET} $1"
}

print_info() {
    echo -e "${BLUE}${BOLD}[INFO]${RESET} $1"
}

print_step() {
    echo -e "${CYAN}${BOLD}[STEP]${RESET} $1"
}

# --- Wait for User Input ---
wait_for_input() {
    echo -e "${YELLOW}Press Enter to continue...${RESET}"
    read -r
}

# --- Help Function ---
show_help() {
    clear_screen
    display_cursor_logo
    echo -e "${BOLD}USAGE:${RESET}"
    echo "  ./curser.txt [OPTIONS]"
    echo ""
    echo -e "${BOLD}OPTIONS:${RESET}"
    echo "  --help        Display this help message"
    echo "  --install     Install Cursor IDE"
    echo "  --update      Update existing installation"
    echo "  --uninstall   Remove Cursor IDE"
    echo ""
    echo -e "${BOLD}INTERACTIVE MODE:${RESET}"
    echo "  Run without arguments for interactive menu"
    echo ""
    echo -e "${BOLD}EXAMPLES:${RESET}"
    echo "  ./curser.txt              # Interactive installation"
    echo "  ./curser.txt --install    # Direct installation"
    echo "  ./curser.txt --help       # Show this help"
    echo ""
    wait_for_input
}

# --- Detect Linux Distribution ---
detect_distro() {
    print_step "Detecting Linux distribution..."
    
    # Show progress while detecting
    (sleep 1) &
    show_spinner $!
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_FAMILY=""
        
        case $DISTRO in
            ubuntu|debian|linuxmint|elementary|pop)
                DISTRO_FAMILY="debian"
                ;;
            fedora|rhel|centos|rocky|almalinux)
                DISTRO_FAMILY="rhel"
                ;;
            arch|manjaro|endeavouros|garuda)
                DISTRO_FAMILY="arch"
                ;;
            opensuse|suse)
                DISTRO_FAMILY="suse"
                ;;
            *)
                DISTRO_FAMILY="unknown"
                ;;
        esac
        
        print_info "Detected distribution: $PRETTY_NAME"
        print_info "Distribution family: $DISTRO_FAMILY"
    else
        print_error "Cannot detect Linux distribution"
        DISTRO_FAMILY="unknown"
    fi
}

# --- Check and Install Dependencies ---
check_and_install_dependencies() {
    print_step "Checking system dependencies..."
    
    local missing_packages=()
    local total_packages=${#REQUIRED_PACKAGES[@]}
    local current=0
    
    # Check each required package with progress
    for package in "${REQUIRED_PACKAGES[@]}"; do
        current=$((current + 1))
        show_progress $current $total_packages
        printf " Checking %s..." "$package"
        
        if ! command -v "$package" &>/dev/null; then
            printf " Checking %s... Missing\r" "$package"
            missing_packages+=("$package")
        else
            printf " Checking %s... Found\r" "$package"
        fi
        sleep 0.2
    done
    printf "\n"
    
    # If no missing packages, return success
    if [ ${#missing_packages[@]} -eq 0 ]; then
        print_success "All required dependencies are installed"
        return 0
    fi
    
    print_warning "Missing dependencies: ${missing_packages[*]}"
    
    # Update package database first
    print_step "Updating package database..."
    case $DISTRO_FAMILY in
        debian)
            (sudo apt-get update -qq) &
            show_spinner $!
            ;;
        rhel)
            if command -v dnf &>/dev/null; then
                (sudo dnf check-update) &
                show_spinner $!
            fi
            ;;
        arch)
            (sudo pacman -Sy --noconfirm) &
            show_spinner $!
            ;;
    esac
    
    # Install missing packages with progress
    print_step "Installing missing packages..."
    install_with_progress "${missing_packages[@]}"
    
    # Verify installation
    print_step "Verifying installation..."
    local still_missing=()
    for package in "${missing_packages[@]}"; do
        if ! command -v "$package" &>/dev/null; then
            still_missing+=("$package")
        fi
    done
    
    if [ ${#still_missing[@]} -eq 0 ]; then
        print_success "All dependencies installed successfully"
        return 0
    else
        print_error "Some packages are still missing: ${still_missing[*]}"
        return 1
    fi
}

# --- Download Latest Cursor AppImage ---
download_latest_cursor_appimage() {
    print_step "Downloading latest Cursor AppImage..."
    
    local api_url="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
    local user_agent="Mozilla/5.0 (X11; Linux x86_64)"
    local download_path="/tmp/cursor-latest.AppImage"
    
    # Get download URL with progress
    print_info "Fetching download URL..."
    (
        local final_url=$(curl -sL -A "$user_agent" "$api_url" | jq -r '.url // .downloadUrl')
        echo "$final_url" > /tmp/cursor_url
    ) &
    show_spinner $!
    
    local final_url=$(cat /tmp/cursor_url)
    rm -f /tmp/cursor_url
    
    if [ -z "$final_url" ] || [ "$final_url" = "null" ]; then
        print_error "Could not retrieve download URL"
        return 1
    fi
    
    print_info "Download URL: $final_url"
    
    # Download with enhanced progress bar
    download_with_progress "$final_url" "$download_path" "Downloading Cursor AppImage..."
    
    if [ $? -eq 0 ] && [ -s "$download_path" ]; then
        print_success "Download completed successfully"
        echo "$download_path"
        return 0
    else
        print_error "Download failed"
        return 1
    fi
}

# --- Install Cursor IDE ---
install_cursor() {
    clear_screen
    display_cursor_logo
    
    if [ -d "$CURSOR_EXTRACT_DIR" ]; then
        print_warning "Cursor IDE is already installed at $CURSOR_EXTRACT_DIR"
        echo "Use the update option to upgrade your installation."
        wait_for_input
        return 1
    fi
    
    # Check dependencies
    if ! check_and_install_dependencies; then
        print_error "Failed to install required dependencies"
        wait_for_input
        return 1
    fi
    
    # Try native installation first
    print_step "Attempting native package installation..."
    if try_native_installation; then
        print_success "Native installation completed successfully"
        configure_desktop_integration
        launch_cursor_prompt
        wait_for_input
        return 0
    fi
    
    # Fallback to AppImage
    print_info "Falling back to AppImage installation..."
    
    print_step "Choose installation method:"
    echo "  1. Download latest AppImage automatically"
    echo "  2. Provide local AppImage path"
    echo "  3. Cancel installation"
    
    while true; do
        read -p "Enter your choice [1-3]: " choice
        case $choice in
            1)
                clear_screen
                display_cursor_logo
                local download_path
                download_path=$(download_latest_cursor_appimage)
                if [ $? -eq 0 ] && [ -f "$download_path" ]; then
                    install_appimage "$download_path"
                    launch_cursor_prompt
                    wait_for_input
                    return $?
                else
                    print_error "Download failed"
                    wait_for_input
                    return 1
                fi
                ;;
            2)
                read -p "Enter AppImage file path: " local_path
                if [ -f "$local_path" ]; then
                    clear_screen
                    display_cursor_logo
                    install_appimage "$local_path"
                    launch_cursor_prompt
                    wait_for_input
                    return $?
                else
                    print_error "File not found: $local_path"
                fi
                ;;
            3)
                print_info "Installation cancelled"
                wait_for_input
                return 1
                ;;
            *)
                print_error "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
}

# --- Try Native Installation ---
try_native_installation() {
    print_info "Attempting native installation..."
    
    case $DISTRO_FAMILY in
        debian)
            try_debian_installation
            ;;
        rhel)
            try_rhel_installation
            ;;
        arch)
            try_arch_installation
            ;;
        *)
            return 1
            ;;
    esac
}

# --- Debian-based Installation ---
try_debian_installation() {
    print_info "Attempting to install Cursor via .deb package..."
    
    # Check if cursor is available in repositories
    print_step "Checking repositories..."
    (apt-cache search cursor-ide) &
    show_spinner $!
    
    if apt-cache search cursor-ide &>/dev/null; then
        print_info "Found Cursor in repositories"
        (sudo apt-get update -qq) &
        show_spinner $!
        
        if sudo apt-get install -y cursor-ide &>/dev/null; then
            print_success "Installed Cursor via apt"
            return 0
        fi
    fi
    
    # Try downloading .deb directly
    print_step "Downloading .deb package..."
    local deb_url="https://www.cursor.com/latest/linux/deb"
    local deb_path="/tmp/cursor.deb"
    
    download_with_progress "$deb_url" "$deb_path" "Downloading .deb package..."
    
    if [ -f "$deb_path" ]; then
        print_info "Installing .deb package..."
        (sudo dpkg -i "$deb_path") &
        show_spinner $!
        
        if sudo dpkg -i "$deb_path" &>/dev/null; then
            print_success "Installed Cursor via .deb package"
            # Fix dependencies
            (sudo apt-get install -f -y) &
            show_spinner $!
            rm -f "$deb_path"
            return 0
        else
            print_warning ".deb installation failed"
            rm -f "$deb_path"
        fi
    fi
    
    return 1
}

# --- RHEL-based Installation ---
try_rhel_installation() {
    print_info "Attempting to install Cursor via .rpm package..."
    
    local rpm_url="https://www.cursor.com/latest/linux/rpm"
    local rpm_path="/tmp/cursor.rpm"
    
    download_with_progress "$rpm_url" "$rpm_path" "Downloading .rpm package..."
    
    if [ -f "$rpm_path" ]; then
        print_info "Installing .rpm package..."
        
        if command -v dnf &>/dev/null; then
            (sudo dnf install -y "$rpm_path") &
            show_spinner $!
            
            if sudo dnf install -y "$rpm_path" &>/dev/null; then
                print_success "Installed Cursor via dnf"
                rm -f "$rpm_path"
                return 0
            fi
        elif command -v yum &>/dev/null; then
            (sudo yum install -y "$rpm_path") &
            show_spinner $!
            
            if sudo yum install -y "$rpm_path" &>/dev/null; then
                print_success "Installed Cursor via yum"
                rm -f "$rpm_path"
                return 0
            fi
        fi
        rm -f "$rpm_path"
    fi
    
    return 1
}

# --- Arch-based Installation ---
try_arch_installation() {
    print_info "Attempting to install Cursor via AUR..."
    
    # Check if yay is available
    if command -v yay &>/dev/null; then
        print_info "Using yay to install from AUR..."
        (yay -S --noconfirm cursor-ide) &
        show_spinner $!
        
        if yay -S --noconfirm cursor-ide &>/dev/null; then
            print_success "Installed Cursor via AUR (yay)"
            return 0
        fi
    fi
    
    # Check if paru is available
    if command -v paru &>/dev/null; then
        print_info "Using paru to install from AUR..."
        (paru -S --noconfirm cursor-ide) &
        show_spinner $!
        
        if paru -S --noconfirm cursor-ide &>/dev/null; then
            print_success "Installed Cursor via AUR (paru)"
            return 0
        fi
    fi
    
    print_warning "No AUR helper found or AUR installation failed"
    return 1
}

# --- Install AppImage ---
install_appimage() {
    local appimage_path="$1"
    
    print_step "Installing Cursor from AppImage..."
    
    # Make executable
    chmod +x "$appimage_path"
    
    # Extract AppImage with progress
    print_info "Extracting AppImage..."
    cd /tmp
    ("$appimage_path" --appimage-extract) &
    show_spinner $!
    
    if [ ! -d "/tmp/squashfs-root" ]; then
        print_error "AppImage extraction failed"
        return 1
    fi
    
    # Install to system with progress
    print_info "Installing to system directory..."
    sudo mkdir -p "$CURSOR_EXTRACT_DIR"
    
    # Show progress for file copying
    local total_files=$(find /tmp/squashfs-root -type f | wc -l)
    local current_file=0
    
    (
        sudo rsync -a --remove-source-files /tmp/squashfs-root/ "$CURSOR_EXTRACT_DIR/"
    ) &
    
    # Show progress while copying
    while ps -p $! > /dev/null 2>&1; do
        current_file=$(find "$CURSOR_EXTRACT_DIR" -type f 2>/dev/null | wc -l)
        show_progress $current_file $total_files
        printf " Copying files..."
        sleep 0.5
    done
    
    show_progress $total_files $total_files
    printf " Copying files... Complete\n"
    
    if [ $? -eq 0 ]; then
        print_success "AppImage installed successfully"
        sudo rm -rf /tmp/squashfs-root
        rm -f "$appimage_path"
        configure_desktop_integration
        return 0
    else
        print_error "Installation failed"
        sudo rm -rf /tmp/squashfs-root
        return 1
    fi
}

# --- Configure Desktop Integration ---
configure_desktop_integration() {
    print_step "Configuring desktop integration..."
    
    # Install icon with progress
    print_info "Installing icon..."
    (
        if [ -f "${CURSOR_EXTRACT_DIR}/usr/share/icons/hicolor/128x128/apps/cursor.png" ]; then
            sudo cp "${CURSOR_EXTRACT_DIR}/usr/share/icons/hicolor/128x128/apps/cursor.png" "$ICON_PATH"
        elif [ -f "${CURSOR_EXTRACT_DIR}/cursor.png" ]; then
            sudo cp "${CURSOR_EXTRACT_DIR}/cursor.png" "$ICON_PATH"
        else
            print_warning "Icon not found, using default"
        fi
    ) &
    show_spinner $!
    
    # Create desktop entry
    print_info "Creating desktop entry..."
    (
        sudo tee "$DESKTOP_ENTRY_PATH" > /dev/null << EOF
[Desktop Entry]
Name=Cursor AI IDE
Comment=Advanced AI-powered code editor
Exec=${EXECUTABLE_PATH} --no-sandbox %F
Icon=cursor
Type=Application
Categories=Development;IDE;
MimeType=text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java-source;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/x-ruby;text/x-sql;text/x-sh;
StartupNotify=true
StartupWMClass=Cursor
EOF
    ) &
    show_spinner $!
    
    # Update desktop database
    print_info "Updating desktop database..."
    (sudo update-desktop-database) &
    show_spinner $!
    
    # Create command line symlink
    print_info "Creating command line symlink..."
    (sudo ln -sf "$EXECUTABLE_PATH" "$SYMLINK_PATH") &
    show_spinner $!
    
    print_success "Desktop integration configured"
    print_info "You can now run 'cursor' from the command line"
}

# --- Update Cursor ---
update_cursor() {
    clear_screen
    display_cursor_logo
    
    if [ ! -d "$CURSOR_EXTRACT_DIR" ]; then
        print_error "Cursor IDE is not installed"
        print_info "Use the install option to install Cursor first"
        wait_for_input
        return 1
    fi
    
    print_step "Updating Cursor IDE..."
    
    # Backup current installation
    print_info "Creating backup of current installation..."
    (sudo cp -r "$CURSOR_EXTRACT_DIR" "${CURSOR_EXTRACT_DIR}.backup") &
    show_spinner $!
    
    # Try native update first
    if try_native_update; then
        print_success "Native update completed"
        (sudo rm -rf "${CURSOR_EXTRACT_DIR}.backup") &
        show_spinner $!
        launch_cursor_prompt
        wait_for_input
        return 0
    fi
    
    # Fallback to AppImage update
    print_info "Updating via AppImage..."
    
    local download_path
    download_path=$(download_latest_cursor_appimage)
    if [ $? -eq 0 ] && [ -f "$download_path" ]; then
        # Remove old installation
        print_info "Removing old installation..."
        (sudo rm -rf "${CURSOR_EXTRACT_DIR:?}"/*) &
        show_spinner $!
        
        # Install new version
        if install_appimage "$download_path"; then
            print_success "Update completed successfully"
            (sudo rm -rf "${CURSOR_EXTRACT_DIR}.backup") &
            show_spinner $!
            launch_cursor_prompt
            wait_for_input
            return 0
        else
            print_error "Update failed, restoring backup..."
            (
                sudo rm -rf "$CURSOR_EXTRACT_DIR"
                sudo mv "${CURSOR_EXTRACT_DIR}.backup" "$CURSOR_EXTRACT_DIR"
            ) &
            show_spinner $!
            wait_for_input
            return 1
        fi
    else
        print_error "Download failed, keeping current installation"
        (sudo rm -rf "${CURSOR_EXTRACT_DIR}.backup") &
        show_spinner $!
        wait_for_input
        return 1
    fi
}

# --- Try Native Update ---
try_native_update() {
    print_info "Attempting native update..."
    
    case $DISTRO_FAMILY in
        debian)
            (sudo apt-get update -qq && sudo apt-get upgrade -y cursor-ide) &
            show_spinner $!
            
            if sudo apt-get update -qq && sudo apt-get upgrade -y cursor-ide &>/dev/null; then
                return 0
            fi
            ;;
        rhel)
            if command -v dnf &>/dev/null; then
                (sudo dnf upgrade -y cursor-ide) &
                show_spinner $!
                
                if sudo dnf upgrade -y cursor-ide &>/dev/null; then
                    return 0
                fi
            elif command -v yum &>/dev/null; then
                (sudo yum update -y cursor-ide) &
                show_spinner $!
                
                if sudo yum update -y cursor-ide &>/dev/null; then
                    return 0
                fi
            fi
            ;;
        arch)
            if command -v yay &>/dev/null; then
                (yay -Syu --noconfirm cursor-ide) &
                show_spinner $!
                
                if yay -Syu --noconfirm cursor-ide &>/dev/null; then
                    return 0
                fi
            elif command -v paru &>/dev/null; then
                (paru -Syu --noconfirm cursor-ide) &
                show_spinner $!
                
                if paru -Syu --noconfirm cursor-ide &>/dev/null; then
                    return 0
                fi
            fi
            ;;
    esac
    return 1
}

# --- Uninstall Cursor ---
uninstall_cursor() {
    clear_screen
    display_cursor_logo
    
    print_warning "This will completely remove Cursor IDE from your system"
    echo "The following will be removed:"
    echo "  - Application files ($CURSOR_EXTRACT_DIR)"
    echo "  - Desktop entry ($DESKTOP_ENTRY_PATH)"
    echo "  - Icon file ($ICON_PATH)"
    echo "  - Command line symlink ($SYMLINK_PATH)"
    echo ""
    
    read -p "Are you sure you want to continue? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Uninstallation cancelled"
        wait_for_input
        return 0
    fi
    
    print_step "Removing Cursor IDE..."
    
    # Remove components with progress
    local components=("$CURSOR_EXTRACT_DIR" "$DESKTOP_ENTRY_PATH" "$ICON_PATH" "$SYMLINK_PATH")
    local total=${#components[@]}
    local current=0
    
    for component in "${components[@]}"; do
        current=$((current + 1))
        show_progress $current $total
        
        if [[ "$component" == "$CURSOR_EXTRACT_DIR" ]] && [ -d "$component" ]; then
            printf " Removing application directory..."
            (sudo rm -rf "$component") &
            show_spinner $!
            echo " Done"
        elif [ -f "$component" ] || [ -L "$component" ]; then
            printf " Removing %s..." "$(basename "$component")"
            (sudo rm -f "$component") &
            show_spinner $!
            echo " Done"
        else
            printf " Skipping %s (not found)..." "$(basename "$component")"
            echo " Done"
        fi
    done
    echo ""
    
    # Update desktop database
    print_info "Updating desktop database..."
    (sudo update-desktop-database) &
    show_spinner $!
    
    print_success "Cursor IDE has been completely removed"
    wait_for_input
}

# --- Launch Cursor Prompt ---
launch_cursor_prompt() {
    echo ""
    read -p "Would you like to launch Cursor now? [y/N]: " launch
    if [[ "$launch" =~ ^[Yy]$ ]]; then
        print_info "Launching Cursor IDE..."
        if command -v cursor &>/dev/null; then
            cursor &
            print_success "Cursor launched successfully"
        else
            print_error "Could not launch Cursor"
        fi
    fi
}

# --- Main Menu ---
show_main_menu() {
    clear_screen
    display_cursor_logo
    
    echo -e "${BOLD}${BLUE}Linux Installation Manager${RESET}"
    echo -e "${CYAN}Compatible with Ubuntu, Debian, Fedora, RHEL, Arch, and more${RESET}"
    echo ""
    echo "----------------------------------------"
    echo "  1. Install Cursor IDE"
    echo "  2. Update Cursor IDE"
    echo "  3. Uninstall Cursor IDE"
    echo "  4. Show Help"
    echo "  5. Exit"
    echo "----------------------------------------"
    echo ""
    
    while true; do
        read -p "Choose an option [1-5]: " choice
        case $choice in
            1)
                install_cursor
                show_main_menu
                break
                ;;
            2)
                update_cursor
                show_main_menu
                break
                ;;
            3)
                uninstall_cursor
                show_main_menu
                break
                ;;
            4)
                show_help
                show_main_menu
                break
                ;;
            5)
                clear_screen
                print_info "Thank you for using Cursor IDE Linux Installer!"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please enter 1, 2, 3, 4, or 5."
                ;;
        esac
    done
}

# --- Main Execution ---
main() {
    # Parse command line arguments
    case "${1:-}" in
        --help|-h)
            show_help
            ;;
        --install)
            detect_distro
            install_cursor
            ;;
        --update)
            detect_distro
            update_cursor
            ;;
        --uninstall)
            uninstall_cursor
            ;;
        "")
            detect_distro
            show_main_menu
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

# --- Script Entry Point ---
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# --- End of Script ---
