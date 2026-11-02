=====================================================================
  AION 2 WINGMAN 1.0                                        by VaLeTecK
  QoL companion for AION 2: fast Teleport assistant + HUD overlay
=====================================================================

WHAT IT IS
  An AutoHotkey v2 program that runs next to AION 2 and adds:
  - HUD overlay: crosshair, bars and LOOT / COMBAT icons that
    light up with the signals sent by your macros (F9 / F10).
  - Hidden Cube: when the Hidden Cube window opens it moves the mouse
    onto "Open with Key" and keeps it there.
  - Fast Teleport assistant (Field Boss): with the map open it shows a
    panel with every boss (A-Z, grades, active / inactive).
    ULTRA-FAST MODE (default): click the boss, Wingman finds and scrolls
    to its Teleport in the Kibelisk list by itself, you click it and
    press F twice. Then an arrow shows the flight direction.
    NORMAL MODE: full guided route to the nearest Teleport.
  - Full Settings window, resolution presets, performance profiles,
    12 interface languages and 22 themes (8 class, 7 holiday)
    plus your own saved themes.

  The script does NOT click or press keys in the game for you:
  it only moves the cursor and shows you what to do. You do the clicks.

PACKAGE CONTENTS
  FIRST RUN QUICK-SETUP.bat  first-run setup (dependencies)
  AION 2 Wingman.ahk         the program
  OCR.ahk                    OCR library (used by the Field Boss tool)
  README\                    these instructions in several languages

REQUIREMENTS
  - Windows 10 or 11
  - AutoHotkey v2 (installed by the FIRST RUN QUICK-SETUP)
  - Windows OCR for English (installed by the FIRST RUN QUICK-SETUP)
  - AION 2 client in English (Field Boss reads the English names)

INSTALLATION
  1. Before extracting: right-click the zip > Properties > tick
     "Unblock" > OK. (Avoids Windows warnings.)
  2. Extract the zip to a permanent folder, e.g. Documents\AION 2 Wingman.
     Do NOT run the files from inside the zip.
  3. Double-click "FIRST RUN QUICK-SETUP.bat" and accept the administrator
     prompt. The FIRST RUN QUICK-SETUP checks and installs everything, and at the end
     can create a desktop shortcut and start Wingman.
     If "Windows protected your PC" appears: "More info" > "Run anyway".
     During the FIRST RUN QUICK-SETUP a guided configuration sets language,
     resolution, performance and ON/OFF features.
  4. Next times, start "AION 2 Wingman.ahk" (or the shortcut). It asks
     for administrator rights by itself: they are needed to read keys
     while the game is in the foreground.

FIRST LAUNCH: DO THIS FIRST
  - Open the Settings: Ctrl+Shift+F12 (or double-click the green "H"
    icon in the Windows taskbar).
  - The language is chosen in the FIRST RUN QUICK-SETUP (change it in ⚙️ General > Language).
  - 📦 Preset: apply FullHD (1080p), 2K (1440p) or 4K (2160p) to match
    your screen, so the HUD has the right size.
  - "Save and restart" to confirm. With "LIVE PREVIEW" you see changes
    in real time even without the game running.

DEFAULT KEYS (change them in Settings > ⌨️ Keys)
  Ctrl+Shift+\      HUD overlay ON/OFF
  Ctrl+Shift+1      Hidden Cube ON/OFF
  Ctrl+Shift+2      Field Boss ON/OFF
  Ctrl+Shift+F12    Settings (works outside the game too)
  Esc               cancel the running Field Boss guide
  M / F             game Map and Travel keys (the script "listens")
  F9 / F10          your macro signals for the HUD (see below)
  Ctrl+F11, Ctrl+Shift+F6/F7/F8   diagnostics (only if something fails)
  (\ = the key left of 1 on an Italian keyboard; on other layouts set
   your own key in Settings.)

HOW TO CONNECT YOUR MACROS TO THE HUD
  - Combat macro: put F9 on spam for the whole macro.
  - Loot macro: insert F10 with a 1350 ms wait.
  The keys still reach the game.

HOW TO USE FIELD BOSS
  1. Open the map (M). The key legend appears at the top, the boss
     panel on the right (grade/state filters, ▲/▼ to collapse it).
  2. Click a boss in the panel. The step guide starts: the mouse is
     moved (and locked) onto the right spot and a big "STEP n"
     instruction appears at the bottom. You click.
  3. After clicking the Teleport press F twice (Travel). The mouse is
     unlocked and an arrow with the boss direction appears at the top.
  Esc cancels at any time.

TROUBLESHOOTING
  - Nothing happens in game: the script only works while AION2.exe is
    the foreground window. Check the "H" icon in the taskbar.
  - Field Boss "not available": OCR.ahk missing from the folder or no
    English Windows OCR. Run the FIRST RUN QUICK-SETUP again.
  - HUD too big/small or misplaced: apply the right preset.
  - Antivirus blocking the script: a common false positive for
    AutoHotkey; add the folder to the exclusions.
  - If something breaks after a change: next to the script there is a
    backup copy "AION 2 Wingman.ahk.bak".

UPDATES AND PERSONAL SETTINGS
  To update, just overwrite the script with the new one: your settings
  (boss list and presets too) are stored in %AppData%\AION 2 Wingman
  and are restored automatically on the first launch.
  To start from scratch, delete that folder.

MAINTENANCE AND QUITTING
  Settings > 🛠️ Maintenance: runs the guided setup again and opens the
  Wingman folder and the personal settings folder.
  The red "⏻ Quit Wingman" button at the top closes the whole program,
  not just the settings window.
  The 🔍 box above the menu searches all settings.

UNINSTALL
  Close Wingman ("⏻ Quit Wingman" or "H" icon > Exit), delete the folder and the desktop
  shortcut. AutoHotkey is removed from Windows Settings > Apps.

CREDITS AND DISCLAIMER
  AION 2 Wingman - by VaLeTecK.
  OCR.ahk - by Descolada (github.com/Descolada/OCR)
  AION 2 is a trademark of its respective owners; this project is not
  affiliated with or endorsed by them. It is a third-party tool: use it
  at your own risk and within the game's terms of service.
