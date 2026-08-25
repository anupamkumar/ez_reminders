#### *ez_reminders - nag-yourself to timebox the things you want to be reminded of*

# EZ-Reminders

A lightweight, native macOS menu-bar utility designed to keep you on track. EZ-Reminders allows you to set multiple named timers and recurring reminders that display live countdowns directly in your Mac's menu bar. 

When a timer hits zero, it triggers a highly visible, always-on-top flashing alert to ensure you never miss a reminder. 

## Features
* **Menu-Bar Native:** Runs quietly in the background as an accessory app with live, human-readable countdowns in the drop-down menu.
* **Persistent State:** Timers automatically save to disk and survive app quits or system restarts.
* **Aggressive Alerts:** Custom pop-up windows float above all other applications (even full-screen apps) with a delayed dismissal button to force acknowledgment.
* **Native Settings UI:** Fully customizable alert colors, flash frequencies, and button delays using modern macOS form styling.
* **Launch on Login:** Seamlessly registers to auto-start when you turn on your Mac without requiring root or admin privileges.

## Tech Stack
* **Language:** Swift 
* **UI Framework:** SwiftUI 
* **Window Management & Dock Integration:** AppKit 
* **Background Startups:** ServiceManagement (`SMAppService`)

## Getting Started

To run or modify this project on your own macOS machine:

1. **Clone the repository:** Ensure you have Git Large File Storage (LFS) enabled on your system before cloning, so that any high-resolution graphical assets (like the 1024x1024 `.app` icon) download correctly.
   ```bash
   git clone [https://github.com/yourusername/ez-reminders.git](https://github.com/yourusername/ez-reminders.git)

