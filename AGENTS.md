# AI Agent Guidelines: AutoHotkey v2 Macros & Modules

This repository contains custom automation scripts, window management utilities, timing modules, and macros for Windows, written exclusively in **AutoHotkey v2**.

---

## 1. Runtime & Language Standard

* **AutoHotkey v2 ONLY**: All scripts must target AutoHotkey v2 (`#Requires AutoHotkey v2.0`).
* **Never use legacy AutoHotkey v1 syntax**:
  * No unquoted string literals in expressions or commands.
  * No `%var%` syntax for variable evaluation (use plain variable names; `%expr%` is reserved for dynamic variable names/function calls).
  * No deprecated v1 commands (e.g., `SetBatchLines`, `StringReplace`, `IfEqual`, `Gui, Add`, `SubStr` with 1-based indexing differences).
  * Function calls require parentheses (e.g., `Sleep(50)`, `MsgBox("Done")`, `WinExist("A")`).
  * ByRef parameters require `&` prefix on both definition and call site (e.g., `WinGetPos(&x, &y, &w, &h, hwnd)`).
  * Multi-line hotkey bodies must be enclosed in braces `{ ... }`.

---

## 2. Repository Layout & Manifest

* **Manifest File**: The full repository directory tree, file purposes, and component descriptions are maintained in [`LAYOUT.md`](LAYOUT.md).
* **Maintenance Requirement**: Whenever you add, delete, rename, or reorganize files in this repository, you **must** update [`LAYOUT.md`](LAYOUT.md) to keep it synchronized.
* **Lightweight Delegation**: Updating [`LAYOUT.md`](LAYOUT.md) can be handled directly or delegated to a lightweight subagent.

---

## 3. Script Structure & Standards

### Standard Script Header
Standalone scripts must start with:
```autohotkey
#Requires AutoHotkey v2.0
#SingleInstance Force

#Include modules\<module>.ahk ; Include necessary modules with relative paths (e.g. modules\window.ahk)
```

### Standard Safety Hotkeys
Every standalone runner or hotkey script **must** provide standard reload and exit hotkeys to prevent runaway hooks or unclosable processes:
```autohotkey
; Hotkey to reload the script
F1 & F2:: Reload()

; Hotkey to exit the script
F1 & ESC:: ExitApp()
```

### Code Style Conventions
* **Brace Style**: Allman style (opening and closing braces on their own lines).
* **Indentation**: 4 spaces.
* **Naming**:
  * **Classes**: PascalCase (`Window`, `Stopwatch`, `QPC`)
  * **Methods & Functions**: PascalCase (`GetMonitorArea()`, `BusyWait()`, `TimeInMs()`)
  * **Variables & Properties**: camelCase or PascalCase (`targetHwnd`, `isBackdropVisible`, `SleepMs`)
  * **Constants / Globals**: Clear naming with explicit declaration when scoped within functions (`global targetHwnd`)
* **Section Banners**: Use commented visual dividers for major sections:
  ```autohotkey
  ; ------------------------
  ; === Global variables ===
  ; ------------------------

  ; ---------------
  ; === Hotkeys ===
  ; ---------------
  ```

---

## 4. Architecture & Module Design

* **Modularity**: General-purpose logic (Win32 API wrappers, math, timing, data manipulation) belongs in [`modules/`](modules/). Keep root scripts focused on hotkeys and orchestration.
* **Encapsulation**: Prefer static classes for namespaces (e.g. `class Window { static Center(...) { ... } }`) or instantiable classes for stateful objects (e.g. `Stopwatch()`).
* **Win32 API Calls**: When using `DllCall`, always specify explicit argument and return types rather than relying on defaults:
  ```autohotkey
  ; Generic pattern: DllCall("[DllFile\]Function", "Type1", Arg1, "Type2", Arg2, "ReturnType")
  result := DllCall("DllName\FunctionName",
      "ptr", handle,
      "uint", flags,
      "int", value,
      "uint" ; Return type
  )
  ```

---

## 5. Development & Testing Safety

* **Verification**: Whenever editing or adding AHK files, check for syntax errors before finishing your task. Use the workspace validation helper script:
  ```powershell
  # Validate all workspace scripts:
  pwsh scripts/Test-AhkSyntax.ps1

  # Or validate a specific script:
  pwsh scripts/Test-AhkSyntax.ps1 -Path "centered-borderless.ahk"
  ```
  Alternatively, you can call AutoHotkey directly:
  ```powershell
  & "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe" /validate "<script-path>.ahk"
  ```
* **Hotkeys**: Do not remap essential Windows system keys or overwrite existing application key bindings without explicit instruction.
* **Process Spawning**: Avoid spawning persistent background AHK processes during unattended agent runs unless specifically requested. If testing a script, prefer scripts that exit automatically or provide explicit termination logic.

---

## 6. Official Documentation & Reference

* **Offline Manual**: The complete official AutoHotkey v2 documentation is available locally at [`docs/AutoHotkey.pdf`](docs/AutoHotkey.pdf).
* **Reference Directive**: Whenever you are uncertain about AutoHotkey v2 language built-ins, standard library methods, object/Gui models, or Win32 interop specifics, consult [`docs/AutoHotkey.pdf`](docs/AutoHotkey.pdf) rather than guessing or assuming legacy v1 conventions.
