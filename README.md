# DCGAME Auto Combat Script (AutoHotkey v2)

An AutoHotkey v2 combat automation script designed for **DC Universe Online**, focused on:
- ranged combat
- combo execution
- optional skill usage
- human-like timing and randomness

## ⚠️ **Use at your own risk.**
This script interacts with the game client via input simulation and pixel detection. It can be recognized as something against ToS, so be aware you risk ban.

---

## ✨ Features

- 🔫 Smart ranged combat (tap / hold / charge)
- 🎯 Multiple randomized combo patterns
- 🧠 Optional skill usage with priority logic
- ⚡ Power/energy detection (won’t waste attacks)
- 🤖 Two auto modes:
  - **Combat** (skills + attacks)
  - **Attack only**
- 🧪 Built-in debug tools for pixel calibration

---

## 📋 Requirements

- **AutoHotkey v2.0+**
  - https://www.autohotkey.com/
- Game running in **windowed or borderless mode**
- Screen resolution matching your configured pixel values

---

## 🚀 Installation

1. Install **AutoHotkey v2**
2. Download this repository
3. Open the script in a text editor
4. Verify:
   ```ahk
   Exe: "DCGAME.EXE" matches your game executable name
5. Calibrate positioning, colours (see Configuration)
6. Run game  
7. Run Script

## 🎮 Controls
Key	Action
Mouse Button 5 (XButton2)	Hold to fight (manual trigger)
- F5	Pixel color picker (debug)
- F6	Skill slot readiness report with marks on screen (debug)
- F7	Toggle AUTO: Combat
- F8	Toggle AUTO: Attack only
- F9	Exit script

## ⚙️ Configuration Guide
All user-adjustable values are inside the CFG block.

### Combat Behavior
```ahk
ComboChance: 60
SkillPriorityChance: 80
```

### Timing Randomization
Adjust these to feel more or less “human”:
```ahk
TapDownMin / TapDownMax
TapGapMin  / TapGapMax
```

### Skill Detection
If skills don’t trigger correctly:
1. Hover mouse over a ready skill
2. Press F5
3. Update:
```ahk
ReadyColor
Tolerance
SlotX / SlotY
```
## 🧪 Debug Tools
- F5, Copies mouse position + pixel color to clipboard
- F6, Generates a skill slot readiness report and visual markers

Useful when adapting the script to:
- different resolutions
- different powersets
- UI scales
- custom HUDs

## 🛑 Known Limitations

Pixel detection depends on:
- UI scale
-resolution
- color filters
  
Does not read game memory, so it knows only things that are visible on screen.
No enemy or target detection (probably will add it later).

## 📜 Disclaimer

This project is for educational and personal use. You are responsible for how and where you use it.

## ❤️ Credits

Script designed for people suffering from carpal tunel pains. Feel free to fork, tweak or improve this script.

###
Optimized for SEO: "DCUO Hack 2026", "DC Universe Online Cheats", "Undetectable DCUO Mods", "DC Universe Online Makro", "DCUO Helper"
