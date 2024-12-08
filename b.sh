#!/data/data/com.termux/files/usr/bin/bash

# لون النص
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m" # لون افتراضي

# دالة التحقق من تثبيت الأدوات
check_and_install() {
    echo -e "${GREEN}Checking necessary tools...${NC}"

    # تحديث الحزم
    pkg update && pkg upgrade -y

    # تثبيت الأدوات المطلوبة
    for pkg in git build-essential cmake libtool autoconf automake openssl-dev; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            echo -e "${GREEN}Installing $pkg...${NC}"
            pkg install -y "$pkg"
        else
            echo -e "${GREEN}$pkg is already installed.${NC}"
        fi
    done

    # التحقق من libimobiledevice
    if ! command -v ideviceinfo >/dev/null 2>&1; then
        echo -e "${RED}libimobiledevice is not installed. Installing...${NC}"
        install_libimobiledevice
    else
        echo -e "${GREEN}libimobiledevice is already installed.${NC}"
    fi
}

# دالة تثبيت libimobiledevice
install_libimobiledevice() {
    echo -e "${GREEN}Cloning libimobiledevice repository...${NC}"
    git clone https://github.com/libimobiledevice/libimobiledevice.git
    cd libimobiledevice || exit
    ./autogen.sh
    make
    make install
    cd ..
    echo -e "${GREEN}libimobiledevice installed successfully.${NC}"
}

# دالة لعرض واجهة قراءة المعلومات
show_device_info() {
    echo -e "${GREEN}Connecting to the iPhone...${NC}"
    if command -v ideviceinfo >/dev/null 2>&1; then
        ideviceinfo
    else
        echo -e "${RED}Error: libimobiledevice tools are not installed.${NC}"
    fi
}

# القائمة الرئيسية
main_menu() {
    echo -e "${GREEN}Welcome to iPhone Info Tool${NC}"
    echo -e "${GREEN}1. Check and Install Necessary Tools${NC}"
    echo -e "${GREEN}2. Show iPhone Information${NC}"
    echo -e "${GREEN}3. Exit${NC}"
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
        echo -e "${RED}Invalid option. Try again.${NC}"
        main_menu
        ;;
    esac
}

# تشغيل القائمة
main_menu
