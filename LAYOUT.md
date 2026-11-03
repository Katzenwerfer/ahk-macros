# Workspace Layout & File Manifest

This document tracks the layout and file manifest of the repository. It must be kept up-to-date whenever files are created, renamed, moved, or deleted.

---

## Directory Tree

```
.
├── AGENTS.md                     # Agent system instructions, conventions & standards
├── LAYOUT.md                     # Workspace file manifest & directory structure (this file)
├── centered-borderless.ahk       # Utility: centers active window with a dark backdrop
├── maximized-borderless.ahk      # Utility: maximizes active window borderless
├── resize-center.ahk             # Utility: resizes active window to preset size & centers
│
├── modules/                      # Reusable library modules and classes
│   ├── csleep.ahk                # Custom sleep routine using spin loops & QPC
│   ├── hsleep.ahk                # Hybrid sleep balancing CPU yield and precision
│   ├── qpc.ahk                   # High-precision QueryPerformanceCounter wrapper
│   ├── stats.ahk                 # Statistical helper class (Avg, Min, Max, etc.)
│   ├── stopwatch.ahk             # Stopwatch class for elapsed time benchmarking
│   ├── timer.ahk                 # Windows NT timer resolution control (NtSetTimerResolution)
│   ├── wait.ahk                  # Precise wait routines using Sleep(-1) yield
│   └── window.ahk                # Window geometry, monitor bounds, and borderless styling
│
├── testing/                      # Test suites and precision benchmarks
│   └── wait/                     # Sleep accuracy and timing jitter benchmarks
│       ├── busy_wait.ahk         # Sleep(0) busy loop precision benchmark
│       ├── custom_sleep.ahk      # CSleep accuracy & jitter benchmark
│       ├── heuristic_hybrid_sleep.ahk # Adaptive heuristic hybrid sleep test
│       └── hybrid_sleep.ahk      # Standard hybrid sleep accuracy benchmark
│
├── vidya/                        # Game-specific automation scripts and macros
│   ├── arc.ahk                   # Arc thrower weapon timing automation
│   ├── fire.ahk                  # Configurable rapid-fire automation
│   ├── rail.ahk                  # Railgun timed charge shot macro
│   └── walk.ahk                  # Continuous auto-walk / sprint toggle
│
├── docs/                         # Reference documentation
│   └── AutoHotkey.pdf            # Official AutoHotkey v2 offline reference manual
│
└── temp/                         # Ephemeral scripts and scratch experiments (git-ignored)
```

---

## Detailed Component Directory

### 1. Root Utilities (Window Management)
* **[`centered-borderless.ahk`](centered-borderless.ahk)**: Strips window borders and title bars, centers the target window on the primary monitor, and draws a black backdrop GUI behind it.
* **[`maximized-borderless.ahk`](maximized-borderless.ahk)**: Strips decorations and maximizes the target window to cover the full primary monitor.
* **[`resize-center.ahk`](resize-center.ahk)**: Resizes the active window to specified dimensions (default: 1920x1080) and centers it.

### 2. Modules (`modules/`)
* **[`window.ahk`](modules/window.ahk)**: `Window` class providing static methods for screen geometry (`GetMonitorArea`, `GetWorkArea`), window rects (`GetWindowArea`, `GetClientArea`), positioning (`Center`), and borderless styling (`SetBorderless`).
* **[`qpc.ahk`](modules/qpc.ahk)**: `QPC` class wrapping Win32 `QueryPerformanceCounter` and `QueryPerformanceFrequency` for sub-millisecond precision.
* **[`stopwatch.ahk`](modules/stopwatch.ahk)**: Instantiable `Stopwatch` class for measuring elapsed durations with `.Start()`, `.Stop()`, `.TimeInMs()`, and `.TimeInSec()`.
* **[`timer.ahk`](modules/timer.ahk)**: `TimerResolution` class adjusting system interrupt timer resolution via `ntdll\NtSetTimerResolution` (down to 0.5 ms).
* **[`stats.ahk`](modules/stats.ahk)**: `Stats` class providing basic statistical calculations (`Average`, `Minimum`, `Maximum`).
* **[`wait.ahk`](modules/wait.ahk)**: Tight waiting loops (`Wait`, `WaitMs`) utilizing QPC polling with `Sleep(-1)` thread yielding.
* **[`csleep.ahk`](modules/csleep.ahk)**: Custom sleep routine for high accuracy delays.
* **[`hsleep.ahk`](modules/hsleep.ahk)**: Hybrid sleep combining coarse OS sleep with fine spin-wait.

### 3. Testing (`testing/`)
* **[`testing/wait/`](testing/wait/)**: Scripts evaluating sleep accuracy, overhead, and jitter across Windows scheduler slices. Each script runs repeated iterations and outputs summary statistics in a `MsgBox`.

### 4. Game Automation (`vidya/`)
* Automation macros with key bindings for gaming actions (e.g., charge weapons, rapid fire, and movement toggles).

### 5. Documentation (`docs/`)
* **[`docs/AutoHotkey.pdf`](docs/AutoHotkey.pdf)**: Complete offline documentation for AutoHotkey v2. Serves as the primary reference manual for agents inspecting syntax, object methods, and built-ins.

---

## Maintenance Guidelines
* **Agent Responsibility**: Any agent adding, deleting, renaming, or moving files in this repository **must** update this file in the same turn or delegate the update to a lightweight subagent.
