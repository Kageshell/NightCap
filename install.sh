#!/usr/bin/env bash

# NightCap - Installation & Schedule Setup Script
# Supports non-root cron setup or systemd service setup.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOTIFY_SCRIPT="${SCRIPT_DIR}/scripts/notify.sh"
SYSTEMD_USER_DIR="${HOME}/.config/systemd/user"

usage() {
    cat <<EOF
Usage: ./install.sh [OPTION]

Install options:
  --cron          Install user cron job (No root required)
  --user-systemd  Install user systemd service & timer (No root required)
  --systemd       Install system-wide systemd service (Requires root/sudo)
  --help          Show this help message
EOF
}

install_cron() {
    echo "Installing NightCap user cron job..."
    
    # Ensure notify.sh exists and is executable
    chmod +x "${NOTIFY_SCRIPT}"

    # Prepare cron entry with required GUI env vars
    # Default: Run break reminder every hour between 20:00 and 23:00
    CRON_SCHEDULE="${CRON_SCHEDULE:-"0 20-23 * * *"}"
    
    # Export current DISPLAY and DBUS_SESSION_BUS_ADDRESS for GUI notification support in cron
    USER_ENV="DISPLAY=${DISPLAY:-:0} DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-"unix:path=/run/user/$(id -u)/bus"}"
    CRON_CMD="${USER_ENV} ${NOTIFY_SCRIPT} 'NightCap Wind Down 🍷' 'Time to step away from the screen!' 'normal' >> ${HOME}/.nightcap.log 2>&1"
    CRON_JOB="${CRON_SCHEDULE} ${CRON_CMD}"

    # Append to current user crontab without duplicating
    CURRENT_CRONTAB="$(crontab -l 2>/dev/null || true)"
    if echo "${CURRENT_CRONTAB}" | grep -q "NightCap Wind Down"; then
        echo "Updating existing NightCap cron entry..."
        NEW_CRONTAB="$(echo "${CURRENT_CRONTAB}" | grep -v "NightCap Wind Down")"
        if [[ -n "${NEW_CRONTAB}" ]]; then
            echo -e "${NEW_CRONTAB}\n${CRON_JOB}" | crontab -
        else
            echo "${CRON_JOB}" | crontab -
        fi
    else
        if [[ -n "${CURRENT_CRONTAB}" ]]; then
            echo -e "${CURRENT_CRONTAB}\n${CRON_JOB}" | crontab -
        else
            echo "${CRON_JOB}" | crontab -
        fi
    fi

    echo "Cron installation complete!"
    echo "Current crontab entry:"
    crontab -l | grep "NightCap"
}

install_user_systemd() {
    echo "Installing NightCap user systemd service and timer..."
    
    chmod +x "${NOTIFY_SCRIPT}"
    mkdir -p "${SYSTEMD_USER_DIR}"

    # Create service file
    cat <<EOF > "${SYSTEMD_USER_DIR}/nightcap-notify.service"
[Unit]
Description=NightCap Gentle Reminder Notification
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=${NOTIFY_SCRIPT} "NightCap Wind Down 🍷" "Time to step away from the screen!" "normal"
Environment=DISPLAY=${DISPLAY:-:0}
Environment=DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-"unix:path=/run/user/%U/bus"}
EOF

    # Create timer file (runs hourly in the evening)
    cat <<EOF > "${SYSTEMD_USER_DIR}/nightcap-notify.timer"
[Unit]
Description=NightCap Hourly Reminder Timer

[Timer]
OnCalendar=*-*-* 20..23:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Reload and enable systemd user timer
    systemctl --user daemon-reload
    systemctl --user enable --now nightcap-notify.timer
    
    echo "User systemd timer installed and activated!"
    systemctl --user status nightcap-notify.timer --no-pager || true
}

install_systemd_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo "Error: --systemd requires root permissions. Run with sudo." >&2
        exit 1
    fi

    echo "Installing NightCap system-wide systemd service..."
    chmod +x "${NOTIFY_SCRIPT}"

    cat <<EOF > /etc/systemd/system/nightcap-notify.service
[Unit]
Description=NightCap System Reminder Service

[Service]
Type=oneshot
ExecStart=${NOTIFY_SCRIPT} "NightCap System Reminder 🍷" "Scheduled system break reminder!" "critical"
EOF

    cat <<EOF > /etc/systemd/system/nightcap-notify.timer
[Unit]
Description=NightCap System Reminder Timer

[Timer]
OnCalendar=*-*-* 21:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable --now nightcap-notify.timer
    echo "System-wide systemd timer installed and activated!"
}

# Main execution logic
MODE="${1:-""}"

if [[ -z "${MODE}" ]]; then
    echo "Select NightCap Installation Mode:"
    echo "1) User Cron Job (No root required)"
    echo "2) User Systemd Timer (No root required)"
    echo "3) System-wide Systemd Timer (Requires root/sudo)"
    read -rp "Choice [1-3]: " CHOICE
    case "${CHOICE}" in
        1) MODE="--cron" ;;
        2) MODE="--user-systemd" ;;
        3) MODE="--systemd" ;;
        *) echo "Invalid choice"; exit 1 ;;
    esac
fi

case "${MODE}" in
    --cron)
        install_cron
        ;;
    --user-systemd)
        install_user_systemd
        ;;
    --systemd)
        install_systemd_root
        ;;
    --help|-h)
        usage
        ;;
    *)
        echo "Unknown option: ${MODE}"
        usage
        exit 1
        ;;
esac
