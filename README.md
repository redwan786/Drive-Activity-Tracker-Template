<div align="center">

# 📁 Drive / Folder Activity Tracker

### Auto-generate a folder index + change-log and push it to GitHub

![Auto](https://img.shields.io/badge/AUTO--GENERATED-2188ff?style=for-the-badge) &nbsp; ![PowerShell](https://img.shields.io/badge/PowerShell-Windows-5391FE?style=for-the-badge&logo=powershell&logoColor=white)

<br>

## ➡️ [**📖 Read the Setup Guide → tracker/SETUP.md**](tracker/SETUP.md)

<br>

**[⬇ Download ZIP](https://github.com/redwan786/Drive-Activity-Tracker-Template/archive/refs/heads/master.zip)**

</div>

---

## What is this?

A tiny toolkit that turns **any folder** (a Google Drive folder, `C:\`, `D:\`, anything)
into a self-updating GitHub repo. It records:

- 🌳 **README.md** — the full folder tree, refreshed on demand
- 📜 **CHANGES.md** — a premium change-log: every file/folder **added · deleted · renamed · moved**, with full paths and timestamps

All the machinery lives in one **`tracker/`** folder, so your drive root stays clean.
Only the tracker files are pushed — **none of your actual content leaves your PC.**

---

## Layout

```
<your drive or folder>\     <- tracked root (.git here)
│   README.md               <- auto-generated index
│   .gitignore              <- auto-created
└── tracker\
        #1- INITIAL.cmd          (double-click: first-time setup)
        #2- UPDATE_CHANGES.cmd   (double-click: update + push)
        #3- RESET_CHANGES.cmd    (double-click: reset change-log)
        INITIAL.ps1  UPDATE_CHANGES.ps1  RESET_CHANGES.ps1
        SETUP.md  CHANGES.md
```

---

## Quick Start

**1. Get the files — easiest is the ZIP:**
**[⬇ Download ZIP](https://github.com/redwan786/Drive-Activity-Tracker-Template/archive/refs/heads/master.zip)** →
unzip → copy the **`tracker`** folder into the drive/folder you want to track.



**2.** Open the `tracker` folder → **double-click `#1- INITIAL.cmd`**

**3.** Done — a new **private** repo is created and tracking begins.

Everyday use after that: double-click **`#2- UPDATE_CHANGES.cmd`**.

> `.gitignore` and `README.md` are created automatically at the root — you don't download them.

### Required files

- **Required:** `INITIAL.ps1`, `UPDATE_CHANGES.ps1`
- **Optional:** `RESET_CHANGES.ps1`, the three `#…cmd` launchers, `SETUP.md`
- **Auto-created (never download):** root `.gitignore`, root `README.md`, `tracker\CHANGES.md`

👉 **Full instructions: [tracker/SETUP.md](tracker/SETUP.md)**

---

## The launchers

| Double-click | Purpose |
|------|---------|
| **`#1- INITIAL.cmd`** | First-time setup — creates the repo and pushes |
| **`#2- UPDATE_CHANGES.cmd`** | Refresh README + CHANGES, then push |
| **`#3- RESET_CHANGES.cmd`** | Wipe the change-log for a fresh start |

---

<div align="center">

**Works on every drive — no hardcoded paths.**

[📖 Open the Setup Guide](tracker/SETUP.md)

</div>
