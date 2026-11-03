<#
.SYNOPSIS
    Validates AutoHotkey v2 scripts for syntax and parsing errors without launching them.

.DESCRIPTION
    Discovers the local AutoHotkey v2 installation and runs the `/validate` switch
    against specified or all `.ahk` scripts in the workspace. Exits with 0 on success,
    or 1 if any script fails validation.

.PARAMETER Path
    Optional path to a single `.ahk` file or a directory. Defaults to the repository root.

.EXAMPLE
    pwsh scripts/Test-AhkSyntax.ps1
    Validates all .ahk files in the workspace (excluding temp/).

.EXAMPLE
    pwsh scripts/Test-AhkSyntax.ps1 -Path "centered-borderless.ahk"
    Validates a single script.
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0, ValueFromPipeline = $true)]
    [string]$Path = $PSScriptRoot + "\.."
)

$ErrorActionPreference = "Stop"

# 1. Locate AutoHotkey v2 executable
$ahkCandidates = @(
    "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe",
    "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
    "$env:ProgramFiles(x86)\AutoHotkey\v2\AutoHotkey64.exe",
    (Get-Command AutoHotkey64.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source),
    (Get-Command autohotkey.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)
)

$ahkExe = $ahkCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1

if (-not $ahkExe) {
    Write-Error "AutoHotkey v2 executable could not be found. Please ensure AHK v2 is installed."
    exit 1
}

Write-Host "Using AHK Engine: $ahkExe" -ForegroundColor Cyan

# 2. Gather target files
$targetFiles = @()

if (Test-Path -Path $Path -PathType Leaf) {
    if ($Path -like "*.ahk") {
        $targetFiles += (Get-Item $Path).FullName
    } else {
        Write-Error "Provided path is not an .ahk file: $Path"
        exit 1
    }
} elseif (Test-Path -Path $Path -PathType Container) {
    $resolvedRoot = (Get-Item $Path).FullName
    $targetFiles = Get-ChildItem -Path $resolvedRoot -Filter "*.ahk" -Recurse -File |
        Where-Object { $_.FullName -notmatch '[\\/]temp[\\/]' -and $_.FullName -notmatch '[\\/]\.git[\\/]' } |
        Select-Object -ExpandProperty FullName
} else {
    Write-Error "Target path not found: $Path"
    exit 1
}

if ($targetFiles.Count -eq 0) {
    Write-Warning "No .ahk files found to validate."
    exit 0
}

Write-Host "Validating $($targetFiles.Count) script(s)...`n"

# 3. Validate each script
$failed = 0
$passed = 0

foreach ($file in $targetFiles) {
    $relPath = Resolve-Path -Relative $file
    $process = Start-Process -FilePath $ahkExe -ArgumentList @("/validate", "`"$file`"") -NoNewWindow -PassThru -Wait
    
    if ($process.ExitCode -eq 0) {
        Write-Host " [PASS] $relPath" -ForegroundColor Green
        $passed++
    } else {
        Write-Host " [FAIL] $relPath (Exit code: $($process.ExitCode))" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`nSummary: $passed passed, $failed failed."

if ($failed -gt 0) {
    exit 1
} else {
    exit 0
}
