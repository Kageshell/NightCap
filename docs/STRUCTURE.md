# NightCap Project Structure

```text
NightCap/
├── README.md             # Project overview & documentation
├── scripts/              # Bash scripts for Linux system operations
│   ├── notify.sh         # Gentle Mode: Desktop notifications & audio alerts
│   ├── lock.sh           # Moderate Mode: Fullscreen overlay & session locking
│   └── shutdown.sh       # Hardcore Mode: Countdown & system poweroff
├── daemon/               # Background monitoring service logic
│   └── nightcap-daemon.sh# Main background loop/timer manager
├── ui/                   # TypeScript UI application
│   └── src/              # Source code for the desktop control panel
└── docs/                 # Additional documentation & guide specs
```
