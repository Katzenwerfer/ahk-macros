#Requires AutoHotkey v2.0
#SingleInstance Force

#Include modules\window.ahk

; ---------------------
; === Configuration ===
; ---------------------

; Hook procedure
hookProc := CallbackCreate(OnForegroundChange, "Fast")

; Event hook
hHook := DllCall(
    "SetWinEventHook",
    "uint", 0x0003,   ; eventMin (EVENT_SYSTEM_FOREGROUND)
    "uint", 0x0003,   ; eventMax (EVENT_SYSTEM_FOREGROUND)
    "ptr", 0,         ; hmodWinEventProc
    "ptr", hookProc,  ; pfnWinEventProc
    "uint", 0,        ; idProcess (all existing threads)
    "uint", 0,        ; idThread (all existing threads)
    "uint", 0x0000,   ; dwFlags (WINEVENT_OUTOFCONTEXT)
    "ptr"
)

; Clean up the hook on exit
OnExit((*) => (DllCall("UnhookWinEvent", "ptr", hHook), CallbackFree(hookProc)))

; ---------------
; === Hotkeys ===
; ---------------

; Hotkey to reload the script
F1 & F2:: Reload()
; Hotkey to exit the script
F1 & ESC:: ExitApp()

; -----------------
; === Functions ===
; -----------------

OnForegroundChange(a, b, hwnd, *) {
    ; Filter out invalid HWNDs and minimized/maximized windows
    if (WinExist(hwnd) && !WinGetMinMax(hwnd)) {
        Window.CenterWindow(hwnd)
    }
}
