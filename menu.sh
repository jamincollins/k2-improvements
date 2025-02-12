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

backup() {
    target=${1}
    local today=$(date +%Y%m%d)
    local count=1

    local backup_dir=/mnt/UDISK/backups

    mkdir -p ${backup_dir}

    local marker=${today}_${count}
    while [ -f ${backup_dir}/${target}_${marker}.tar.gz ]; do
        count=$((count + 1))
        marker=${today}_${count}
    done

    printf "Backing up ${target} ...\n"
    tar_options="-czf"
    case ${target} in
        klipper)
            tar ${tar_options} ${backup_dir}/${target}_${marker}.tar.gz /usr/share/klipper/klippy/extras
            ;;
        moonraker)
            tar ${tar_options} ${backup_dir}/${target}_${marker}.tar.gz /usr/share/moonraker
            ;;
        fluidd)
            tar ${tar_options} ${backup_dir}/${target}_${marker}.tar.gz /usr/share/fluidd
            ;;
    esac

    printf "Backup saved to ${backup_dir}/${target}_${marker}.tar.gz\n"
}

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

# Installation functions for each option
install_option_1() {
    entry_name="Bed Screws - SCREWS_TILT_CALCULATE"
    printf "Installing ${entry_name}...\n"
    backup klipper
    cp features/bed_screws/screws_tilt_adjust.py \
        /usr/share/klipper/klippy/extras/screws_tilt_adjust.py
    mkdir -p /mnt/UDISK/printer_data/config/custom
    cp features/bed_screws/bed_screws.cfg \
        /mnt/UDISK/printer_data/config/custom/bed_screws.cfg
    ./scripts/ensure_included.py custom/bed_screws.cfg
    # schedule klipper restart
    add_service klipper
    printf "${entry_name} installed.\n"
}

install_option_2() {
    entry_name="Bed Mesh - allow additional mesh sizes"
    # gate this on firmware version
    version=$(fw_printenv -n version)

    # Split first three components
    major_minor_patch=$(echo "$version" | cut -d'.' -f1-3)

    if expr "$major_minor_patch" \>= "1.1.2" >/dev/null 2>&1; then
        printf "Not installing ${entry_name}, no longer needed ...\n"
    else
        printf "Installing ${entry_name}...\n"
        backup klipper
        cp features/bed_mesh/bed_mesh.py \
            /usr/share/klipper/klippy/extras/bed_mesh.py
        rm -f /usr/share/klipper/klippy/extras/bed_mesh.pyc
        # schedule klipper restart
        add_service klipper
        printf "${entry_name} installed.\n"
    fi
}

install_option_3() {
    entry_name="Web Cam - update Fluidd and Moonraker"
    printf "Installing ${entry_name}...\n"
    backup moonraker
    backup fluidd
    # replace Fluidd
    rm -fr /usr/share/fluidd/*
    tar -C /usr/share/fluidd -xzf features/fluidd/fluidd.tar.gz
    # update moonraker webcam
    cp features/camera/webcam.py \
        /usr/share/moonraker/components/webcam.py
    rm -f /usr/share/moonraker/components/webcam.pyc
    # schedule moonraker restart
    add_service moonraker
    printf "${entry_name} installed.\n"
}

install_option_4() {
    entry_name="M191 implementation"
    printf "Installing ${entry_name}...\n"
    mkdir -p /mnt/UDISK/printer_data/config/custom
    cp features/chamber/m191.cfg \
        /mnt/UDISK/printer_data/config/custom/m191.cfg
    ./scripts/ensure_included.py custom/m191.cfg
    printf "${entry_name} installed.\n"
}

install_option_5() {
    entry_name="START_PRINT"
    printf "Installing ${entry_name}...\n"
    mkdir -p /mnt/UDISK/printer_data/config/custom
    cp features/bed_mesh/bed_mesh.cfg \
        /mnt/UDISK/printer_data/config/custom/bed_mesh.cfg
    cp features/start_print/start_print.cfg \
        /mnt/UDISK/printer_data/config/custom/start_print.cfg
    ./scripts/ensure_included.py custom/bed_mesh.cfg
    ./scripts/ensure_included.py custom/start_print.cfg
    printf "${entry_name} installed.\n"
}

# Display menu
show_menu() {
    clear_screen
    printf "%b============================================%b\n" "$BLUE" "$NC"
    printf "%b          System Installation Menu          %b\n" "$YELLOW" "$NC"
    printf "%b============================================%b\n" "$BLUE" "$NC"
    printf "\n"

    # Option 1
    entry_name="Bed Screws - SCREWS_TILT_CALCULATE"
    if is_installed "1"; then
        printf "1) %b[INSTALLED]%b ${entry_name}\n" "$GREEN" "$NC"
    else
        printf "1) ${entry_name}\n"
    fi

    # Option 2
    entry_name="Bed Mesh - allow additional mesh sizes"
    if is_installed "2"; then
        printf "2) %b[INSTALLED]%b ${entry_name}\n" "$GREEN" "$NC"
    else
        printf "2) ${entry_name}\n"
    fi

    # Option 3
    entry_name="Web Cam - update Fluidd and Moonraker"
    if is_installed "3"; then
        printf "3) %b[INSTALLED]%b ${entry_name}\n" "$GREEN" "$NC"
    else
        printf "3) ${entry_name}\n"
    fi

    # Option 4
    entry_name="M191 implementation"
    if is_installed "4"; then
        printf "4) %b[INSTALLED]%b ${entry_name}\n" "$GREEN" "$NC"
    else
        printf "4) ${entry_name}\n"
    fi

    # Option 5
    entry_name="START_PRINT - enhanced start print macro"
    if is_installed "5"; then
        printf "5) %b[INSTALLED]%b ${entry_name}\n" "$GREEN" "$NC"
    else
        printf "5) ${entry_name}\n"
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
    printf "Please enter your choice %b[1-5, a or q]%b: " "$YELLOW" "$NC"
    read choice

    case "$choice" in
        1|2|3|4|5)
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
            for i in $(seq 1 5); do
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
