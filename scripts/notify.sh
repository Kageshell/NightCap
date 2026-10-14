#!/usr/bin/env bash

# NightCap - Gentle Mode Notification Script
# Sends desktop notifications and plays optional audio alert.

set -euo pipefail

TITLE="${1:-"NightCap Reminder 🍷🌙"}"
MESSAGE="${2:-"Time to wind down and take a break!"}"
URGENCY="${3:-"normal"}" # low, normal, critical
SOUND_FILE="${4:-""}"

# Validate urgency before doing any work
case "${URGENCY}" in
    low|normal|critical) ;;
    *)
        echo "Error: invalid URGENCY '${URGENCY}'. Expected one of: low, normal, critical" >&2
        exit 2
        ;;
esac

# Ensure notify-send available
if ! command -v notify-send >/dev/null 2>&1; then
    echo "Warning: notify-send not installed. Falling back to console output." >&2
    echo "[NightCap - ${URGENCY^^}] ${TITLE}: ${MESSAGE}"
    exit 0
fi

# Send notification (fallback to stdout if no active GUI/DBus session)
NOTIFY_OK=0
if ! notify-send \
    --app-name="NightCap" \
    --urgency="${URGENCY}" \
    --icon="preferences-system-time" \
    "${TITLE}" \
    "${MESSAGE}" 2>/dev/null; then
    echo "Warning: DBus notification failed (no active GUI session). Printing to stdout:" >&2
    echo "[NightCap - ${URGENCY^^}] ${TITLE}: ${MESSAGE}"
    NOTIFY_OK=1
fi

# Play sound if specified and sound player exists
if [[ -n "${SOUND_FILE}" && -f "${SOUND_FILE}" ]]; then
    if command -v paplay >/dev/null 2>&1; then
        paplay "${SOUND_FILE}" &
    elif command -v pw-play >/dev/null 2>&1; then
        pw-play "${SOUND_FILE}" &
    elif command -v canberra-gtk-play >/dev/null 2>&1; then
        canberra-gtk-play -f "${SOUND_FILE}" &
    elif command -v aplay >/dev/null 2>&1; then
        aplay -q "${SOUND_FILE}" &
    else
        echo "Warning: SOUND_FILE set to '${SOUND_FILE}' but no supported audio player was found." >&2
    fi
fi

# Report actual outcome: success only if the notification was delivered
if [[ "${NOTIFY_OK}" -eq 0 ]]; then
    echo "Notification sent successfully: [${URGENCY}] ${TITLE} - ${MESSAGE}"
else
    echo "Notification step completed with fallback: [${URGENCY}] ${TITLE} - ${MESSAGE}"
    exit 1
fi
