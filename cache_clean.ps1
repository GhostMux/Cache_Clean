# === Windows Deep Cleanup (safe targets only) ===
# Run in an elevated PowerShell window (Administrator)

# Fail fast on critical errors but keep going on deletes
$ErrorActionPreference = 'Continue'

# Helper: delete contents of a path if it exists
function Clear-Path {
    param([string]$Path)
    if (Test-Path $Path) {
        Write-Host "Clearing: $Path"
        try {
            Get-ChildItem -LiteralPath $Path -Force -Recurse -ErrorAction SilentlyContinue |
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        } catch {
            Write-Host "  Skipped (in use or protected): $Path"
        }
    }
}

# Measure space before
$drive = 'C'
$before = (Get-PSDrive $drive).Free

# Stop services that can lock caches
$svc = 'wuauserv','bits'
foreach ($s in $svc) {
    if ((Get-Service $s -ErrorAction SilentlyContinue).Status -eq 'Running') {
        try { Stop-Service $s -Force -ErrorAction SilentlyContinue } catch {}
    }
}

# --- System-wide temp + update cache ---
Clear-Path "C:\Windows\Temp"
Clear-Path "C:\Windows\Prefetch"          # harmless to clear; Windows will rebuild
Clear-Path "C:\Windows\SoftwareDistribution\Download"  # Windows Update download cache
Clear-Path "C:\Windows\Logs\CBS\Logs"     # verbose servicing logs
Clear-Path "C:\$Recycle.Bin"

# --- Per-user caches (all profiles under C:\Users) ---
$profiles = Get-ChildItem 'C:\Users' -Directory -Force |
            Where-Object { $_.Name -notmatch '^(Default|All Users|Default User|Public)$' }

foreach ($p in $profiles) {
    $u = $p.FullName

    # User temp
    Clear-Path "$u\AppData\Local\Temp"

    # Browsers
    # Chrome
    Clear-Path "$u\AppData\Local\Google\Chrome\User Data\*\Cache"
    Clear-Path "$u\AppData\Local\Google\Chrome\User Data\*\Code Cache"
    Clear-Path "$u\AppData\Local\Google\Chrome\User Data\*\GPUCache"
    # Edge
    Clear-Path "$u\AppData\Local\Microsoft\Edge\User Data\*\Cache"
    Clear-Path "$u\AppData\Local\Microsoft\Edge\User Data\*\Code Cache"
    Clear-Path "$u\AppData\Local\Microsoft\Edge\User Data\*\GPUCache"
    # Firefox
    Clear-Path "$u\AppData\Local\Mozilla\Firefox\Profiles\*\cache2"

    # Teams / Zoom
    Clear-Path "$u\AppData\Roaming\Microsoft\Teams\Cache"
    Clear-Path "$u\AppData\Roaming\Microsoft\Teams\Code Cache"
    Clear-Path "$u\AppData\Roaming\Microsoft\Teams\GPUCache"
    Clear-Path "$u\AppData\Roaming\Zoom\data"
    Clear-Path "$u\AppData\Roaming\Zoom\bin\cef\Cache"
    Clear-Path "$u\AppData\Roaming\Zoom\logs"

    # Common app installers & leftover crash dumps
    Clear-Path "$u\Downloads\*.tmp"
    Clear-Path "$u\Downloads\*.log"
    Clear-Path "$u\Documents\*.dmp"
}

# Empty Recycle Bin (all drives)
try { Clear-RecycleBin -Force -ErrorAction SilentlyContinue } catch {}

# Restart services we stopped
foreach ($s in $svc) {
    try { Start-Service $s -ErrorAction SilentlyContinue } catch {}
}

# Component Store cleanup (safe)
Start-Process -FilePath "dism.exe" -ArgumentList "/Online","/Cleanup-Image","/StartComponentCleanup","/Quiet" -Wait

# Measure space after
$after = (Get-PSDrive $drive).Free
$freed = [math]::Round(($after - $before) / 1GB, 2)

Write-Host ""
Write-Host "Cleanup complete."
Write-Host "Freed approximately: $freed GB"
Write-Host "Free space now: $([math]::Round($after/1GB,2)) GB on $drive`:"