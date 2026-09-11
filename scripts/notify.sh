#!/usr/bin/env bash

# NightCap - Gentle Mode Notification Script
# Sends desktop notifications and plays optional audio alert.

set -euo pipefail

TITLE="${1:-"NightCap Reminder 🍷🌙"}"
MESSAGE="${2:-"Time to wind down and take a break!"}"
URGENCY="${3:-"normal"}" # low, normal, critical
SOUND_FILE="${4:-""}"

# Ensure notify-send available
if ! command -v notify-send >/dev/null 2>&1; then
    echo "Warning: notify-send not installed. Falling back to console output." >&2
    echo "[NightCap - ${URGENCY^^}] ${TITLE}: ${MESSAGE}"
    exit 0
fi

# Send notification (fallback to stdout if no active GUI/DBus session)
if ! notify-send \
    --app-name="NightCap" \
    --urgency="${URGENCY}" \
    --icon="preferences-system-time" \
    "${TITLE}" \
    "${MESSAGE}" 2>/dev/null; then
    echo "Warning: DBus notification failed (no active GUI session). Printing to stdout:" >&2
    echo "[NightCap - ${URGENCY^^}] ${TITLE}: ${MESSAGE}"
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
    fi
fi

echo "Notification step completed: [${URGENCY}] ${TITLE} - ${MESSAGE}"
