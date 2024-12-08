#!/data/data/com.termux/files/usr/bin/bash

# إعداد ألوان النصوص
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m" # لون افتراضي

# التحقق من تثبيت الأداة
check_and_install() {
    echo -e "${GREEN}Checking and installing necessary tools...${NC}"

    # تحديث الحزم
    pkg update && pkg upgrade -y

    # تثبيت الحزم الضرورية
    for pkg in git build-essential cmake libtool autoconf automake openssl-dev pkg-config; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            echo -e "${GREEN}Installing $pkg...${NC}"
            pkg install -y "$pkg"
        else
            echo -e "${GREEN}$pkg is already installed.${NC}"
        fi
    done

    # التحقق من وجود libimobiledevice
    if ! command -v ideviceinfo >/dev/null 2>&1; then
        echo -e "${RED}libimobiledevice is not installed. Installing...${NC}"
        install_libimobiledevice
    else
        echo -e "${GREEN}libimobiledevice is already installed.${NC}"
    fi
}

# تثبيت مكتبة libimobiledevice
install_libimobiledevice() {
    echo -e "${GREEN}Cloning libimobiledevice repository...${NC}"
    if [ ! -d "libimobiledevice" ]; then
        git clone https://github.com/libimobiledevice/libimobiledevice.git || {
            echo -e "${RED}Failed to clone repository. Check your internet connection.${NC}"
            exit 1
        }
    fi

    cd libimobiledevice || exit
    echo -e "${GREEN}Building and installing libimobiledevice...${NC}"
    ./autogen.sh || { echo -e "${RED}Autogen failed.${NC}"; exit 1; }
    make || { echo -e "${RED}Build failed.${NC}"; exit 1; }
    make install || { echo -e "${RED}Installation failed.${NC}"; exit 1; }
    cd ..
    echo -e "${GREEN}libimobiledevice installed successfully.${NC}"
}

# قراءة معلومات الهاتف
show_device_info() {
    echo -e "${GREEN}Fetching iPhone information...${NC}"
    if command -v ideviceinfo >/dev/null 2>&1; then
        ideviceinfo || echo -e "${RED}Failed to connect to the device. Ensure the iPhone is connected and trusted.${NC}"
    else
        echo -e "${RED}libimobiledevice tools are not installed.${NC}"
    fi
}

# القائمة الرئيسية
main_menu() {
    while true; do
        echo -e "${GREEN}\nWelcome to iPhone Info Tool${NC}"
        echo -e "1. Check and Install Necessary Tools"
        echo -e "2. Show iPhone Information"
        echo -e "3. Exit"
        read -p "Choose an option: " choice

        case $choice in
        1)
            check_and_install
            ;;
        2)
            show_device_info
            ;;
        3)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            ;;
        esac
    done
}

# بدء البرنامج
main_menu
