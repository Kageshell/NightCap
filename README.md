# NightCap 🍷🌙

**NightCap** is a customizable Linux desktop application designed to help you wind down, take regular breaks, and enforce healthy bedtime boundaries. Named after the traditional drink taken right before bed, NightCap helps you close out your evening session and step away from your screen.

Whether you just need a friendly nudge to log off or a strict, non-bypassable shutdown sequence at night, NightCap lets you configure the exact level of enforcement that works for you.

---

## ✨ Features

- ⏰ **Scheduled Shutdowns**: Set your target bedtime or maximum continuous screen duration.
- 🔔 **Break Reminders**: Configurable interval warnings prompting you to stretch, hydrate, and rest your eyes.
- 🎚️ **Customizable Enforcement Modes**:
  - **Gentle Mode**: Friendly desktop notifications and subtle audio chimes.
  - **Moderate Mode**: Screen overlays, dimming, and session locking (`loginctl lock-session`).
  - **Hardcore Mode**: Strict countdown leading to automated system shutdown (`poweroff`).
- 🔐 **Password Protection (Planned)**: Require a PIN/password or timed delay to prevent disabling active limits.
- 🤝 **Accountability Partner (Planned)**: Optional integrations to notify a friend when limits are changed or bypassed.

---

## 🛠️ Architecture & Tech Stack

- **Frontend UI**: Built with **TypeScript** for a modern, responsive user interface.
- **Backend Core**: Powered by **Linux Bash scripts** for native integration with system utilities (`systemctl`, `notify-send`, `loginctl`).
- **Background Daemon**: A lightweight service running in the background to track timers and execute scheduled rules.

---

## 🚀 Getting Started

### Prerequisites

Ensure your Linux distribution has the necessary system tools installed:

- `bash`
- `libnotify` (`notify-send`)
- `systemd` (for locking and power operations)
- `Node.js` & `npm` (for the TypeScript frontend)

### Quick Start

```bash
# Clone the repository
git clone https://github.com/your-username/nightcap.git
cd nightcap

# Install UI dependencies
npm install

# Run development mode
npm run dev
```

---

## 🗺️ Roadmap

- [ ] Core Bash scripts for notifications, session locking, and power management
- [ ] Background monitoring daemon
- [ ] TypeScript Desktop UI for schedule configuration and mode selection
- [ ] Settings locking via password/delay mechanism
- [ ] Webhook / Buddy notifications

---

## 📄 License

[MIT](LICENSE)
