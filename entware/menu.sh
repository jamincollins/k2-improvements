#!/bin/ash

cd $(dirname ${0})

# Check if output is a terminal
if [ -t 1 ]; then
    # ANSI color codes using \e escape sequence
    RED="\e[31m"
    GREEN="\e[32m"
    YELLOW="\e[33m"
    BLUE="\e[34m"
    NC="\e[0m"  # No Color
else
    # No colors if not a terminal
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    NC=""
fi

# Installation tracking file
INSTALL_LOG="./installed_options.log"
touch "$INSTALL_LOG"
SERVICE_LOG="./services_to_restart.log"
rm -f "$SERVICE_LOG"
touch "$SERVICE_LOG"

# Clear screen function
clear_screen() {
    printf "\e[H\e[J"
}

# Check if an option is installed
is_installed() {
    grep -q "^$1$" "$INSTALL_LOG"
    return $?
}

# Mark an option as installed
mark_installed() {
    echo "$1" >> "$INSTALL_LOG"
}

add_service() {
    if ! grep -q "^$1$" "$SERVICE_LOG"; then
        echo "$1" >> "$SERVICE_LOG"
    fi
}

show_pending_services() {
    if [ -s "$SERVICE_LOG" ]; then
        printf "%bThe following services need to be restarted:%b\n" "$YELLOW" "$NC"
        while IFS= read -r service; do
            printf "  - %s\n" "$service"
        done < "$SERVICE_LOG"
        printf "\n"
    fi
}

restart_services() {
    if [ -s "$SERVICE_LOG" ]; then
        printf "%bRestarting services...%b\n" "$YELLOW" "$NC"
        while IFS= read -r service; do
            printf "Restarting %s...\n" "$service"
            # Add actual service restart command here, e.g.:
            /etc/init.d/$service restart
            sleep 1
        done < "$SERVICE_LOG"
        : > "$SERVICE_LOG"  # Clear the service log
        printf "%bAll services have been restarted.%b\n" "$GREEN" "$NC"
    else
        printf "%bNo services need to be restarted.%b\n" "$GREEN" "$NC"
    fi
}

ensure_entware_in_path() {
    case ":$PATH:" in
        *:/opt/bin:*) ;;
        *) PATH=$PATH:/opt/bin ;;
    esac

    case ":$PATH:" in
        *:/opt/sbin:*) ;;
        *) PATH=$PATH:/opt/sbin ;;
    esac
}

require() {
    if ! is_installed "$1"; then
        install_option_$1
        mark_installed "$1"
    fi
}

# Installation functions for each option
install_option_1() {
    entry_name="Entware"
    printf "Installing ${entry_name}...\n"
    ./generic.sh
    printf "${entry_name} installed.\n"
}

install_option_2() {
    entry_name="Classic Camera - mjpeg-streamer"
    require 1
    printf "Installing ${entry_name}...\n"
    ensure_entware_in_path
    opkg install mjpg-streamer mjpg-streamer-input-uvc mjpg-streamer-output-http
    cp features/classic_camera/mjpg-streamer /etc/init.d/mjpg-streamer
    printf "Configuring mjpg-streamer service ...\n"
    chmod +x /etc/init.d/mjpg-streamer
    /etc/init.d/mjpg-streamer enable
    /etc/init.d/mjpg-streamer start
    printf "${entry_name} installed.\n"
}

install_option_3() {
    entry_name="Obico"
    require 1
    printf "Installing ${entry_name}...\n"
    ensure_entware_in_path
    cur_dir=$(pwd)
    cd /mnt/UDISK
    git clone https://github.com/TheSpaghettiDetective/moonraker-obico.git
    cd moonraker-obico
    # apply our custom patch -- will be submitted as a PR
    git apply ${cur_dir}/features/obico/obico.patch
    export CREALITY_VARIANT=k2
    ./scripts/install_creality.sh
    printf "${entry_name} installed.\n"
    /etc/init.d/moonraker_obico_service restart
    cd $cur_dir
}

install_option_4() {
    entry_name="OctoEverywhere"
    require 1
    require 2
    printf "Installing ${entry_name}...\n"
    ensure_entware_in_path
    cur_dir=$(pwd)
    cd /mnt/UDISK
    git clone https://github.com/QuinnDamerell/OctoPrint-OctoEverywhere.git octoeverywhere
    cd octoeverywhere
    ./install.sh
    printf "${entry_name} installed.\n"
    /etc/init.d/octoeverywhere_service restart
    cd $cur_dir
}

# Display menu
show_menu() {
    clear_screen
    printf "%b============================================%b\n" "$BLUE" "$NC"
    printf "%b          System Installation Menu          %b\n" "$YELLOW" "$NC"
    printf "%b============================================%b\n" "$BLUE" "$NC"
    printf "\n"

    # Option 1
    entry_name="Entware"
    if is_installed "1"; then
        printf "1) %b[INSTALLED]%b ${entry_name}\n" "$GREEN" "$NC"
    else
        printf "1) ${entry_name}\n"
    fi

#    # Option 2
#    entry_name="Classic Camera - mjpeg-streamer"
#    if is_installed "2"; then
#        printf "2) %b[INSTALLED]%b ${entry_name}\n" "$GREEN" "$NC"
#    else
#        printf "2) ${entry_name}\n"
#    fi

    # Option 3
    entry_name="Obico"
    if is_installed "3"; then
        printf "3) %b[INSTALLED]%b ${entry_name}\n" "$GREEN" "$NC"
    else
        printf "3) ${entry_name}\n"
    fi

    # Option 4
    entry_name="OctoEverywhere"
    if is_installed "4"; then
        printf "4) %b[INSTALLED]%b ${entry_name}\n" "$GREEN" "$NC"
    else
        printf "4) ${entry_name}\n"
    fi

    printf "%b============================================%b\n" "$BLUE" "$NC"
    printf "a) Install all\n"
    printf "%b============================================%b\n" "$BLUE" "$NC"

    printf "\n"
    printf "q) %bExit%b\n" "$RED" "$NC"
    printf "\n"
    printf "%b============================================%b\n" "$BLUE" "$NC"

    show_pending_services
}

# Main menu loop
while true; do
    show_menu
    printf "Please enter your choice %b[1-4, a or q]%b: " "$YELLOW" "$NC"
    read choice

    case "$choice" in
        2)
            printf "%bThis option is currently disabled.%b\n" "$YELLOW" "$NC"
            printf "Press Enter to continue..."
            read dummy
            continue
            ;;
        1|4)
            if is_installed "$choice"; then
                printf "%bThis option is already installed.%b\n" "$YELLOW" "$NC"
                printf "Press Enter to continue..."
                read dummy
                continue
            fi

            clear_screen
            "install_option_$choice"
            mark_installed "$choice"
            printf "%bInstallation complete!%b\n" "$GREEN" "$NC"
            printf "Press Enter to continue..."
            read dummy
            ;;
        a|A)
            clear_screen
            for i in $(seq 1 4); do
                "install_option_$i"
                mark_installed "$i"
            done
            printf "%bInstallation complete!%b\n" "$GREEN" "$NC"
            printf "Press Enter to continue..."
            read dummy
            ;;
        q|Q)
            clear_screen
            # maybe ask for confirmation?
            restart_services
            printf "%bThank you for using the installation menu!%b\n" "$YELLOW" "$NC"
            exit 0
            ;;
        *)
            printf "%bInvalid option. Please try again.%b\n" "$RED" "$NC"
            printf "Press Enter to continue..."
            read dummy
            ;;
    esac
done
