# Cache_Clean
# Windows Deep Cleanup Script

## Overview
This PowerShell script performs a **safe deep cleanup** of Windows systems.  
It targets temporary files, caches, update leftovers, logs, and recycle bins across all user profiles while avoiding critical system files.  
The script is designed to reclaim disk space without harming normal Windows operation.

---

## ✨ Features
- **System-wide cleanup**
  - Windows Temp, Prefetch, and SoftwareDistribution caches  
  - CBS servicing logs  
  - Recycle Bin (all drives)

- **Per-user cleanup**
  - Temp folders  
  - Browser caches (Chrome, Edge, Firefox)  
  - Microsoft Teams and Zoom caches/logs  
  - Installer leftovers (`*.tmp`, `*.log`)  
  - Crash dumps (`*.dmp`)

- **Service handling**
  - Stops Windows Update (`wuauserv`) and BITS (`bits`) temporarily  
  - Restarts services after cleanup  

- **Component Store cleanup**
  - Runs `dism.exe /Online /Cleanup-Image /StartComponentCleanup`  
  - Safely reduces the size of the WinSxS folder  

- **Space reporting**
  - Reports free space before and after  
  - Displays total GB freed  

---

## 🚀 Usage

### 1. Run as Administrator
Open PowerShell **as Administrator**.

### 2. Execute the script
```powershell
.\cache_clean.ps1
