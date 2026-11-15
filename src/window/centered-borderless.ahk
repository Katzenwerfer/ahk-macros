#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\..\modules\window.ahk

; ------------------------
; === Global variables ===
; ------------------------

bgGui := ""
targetHwnd := 0
targetHwndWidth := 0
targetHwndHeight := 0
isBackdropVisible := false
hHook := 0
hookProc := 0

; Clean up hook and backdrop GUI on script exit or reload
OnExit((*) => CleanupRuntime())

; ---------------
; === Hotkeys ===
; ---------------

; Hotkey to reload the script
F1 & F2:: Reload()
; Hotkey to exit the script
F1 & ESC:: ExitApp()

; Hotkey: Press Alt + F12 while the target window is focused to center, remove decorations, and add a dark background behind it
!F12::
{
    global bgGui, targetHwnd, targetHwndWidth, targetHwndHeight, isBackdropVisible, hHook, hookProc

    ; Skip if already tracking an active window; reset if closed
    if (targetHwnd)
    {
        if (WinExist(targetHwnd))
        {
            return
        }
        CleanupRuntime()
    }

    ; Target the active window ("A")
    if (!targetHwnd := WinExist("A"))
    {
        return
    }

    ; If the window is maximized or minimized, restore it first
    if WinGetMinMax(targetHwnd)
    {
        WinRestore(targetHwnd)
    }

    ; Retrieve the current size of the active window
    WinGetPos(, , &targetHwndWidth, &targetHwndHeight, targetHwnd)

    ; Position at center and resize to client area
    Window.CenterWindow(targetHwnd, , , true)

    ; Remove the title bar and border
    Window.SetWindowBorderless(targetHwnd, true)

    ; Create a dark background
    CreateBackground()
    isBackdropVisible := true

    ; Hook procedure
    hookProc := CallbackCreate(OnForegroundChange, "Fast")

    ; Event hook: monitor foreground changes
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
}

; Hotkey: Press Shift + F12 to restore the original title bar
+F12::
{
    global targetHwnd, targetHwndWidth, targetHwndHeight

    ; Return if not tracking anything
    if (!targetHwnd)
    {
        return
    }

    ; Restore only if target window exists
    if (WinExist(targetHwnd))
    {
        ; Restore the title bar and border
        Window.SetWindowBorderless(targetHwnd, false)

        ; Position at center and resize
        Window.CenterWindow(targetHwnd, [targetHwndWidth, targetHwndHeight])
    }

    ; Cleanup global variables
    CleanupRuntime()
}

; -----------------
; === Functions ===
; -----------------

CreateBackground()
{
    global bgGui, targetHwnd

    ; Create a borderless, non-clickable black background
    bgGui := Gui("-Caption +ToolWindow +Disabled")
    bgGui.BackColor := "000000"

    ; Cover the virtual screen (all monitors)
    area := Window.GetMonitorArea()
    bgGui.Show(Format("x{} y{} w{} h{} NoActivate", area.x, area.y, area.w, area.h))

    ; Place directly behind the target window in Z-order
    ; 0x53 = SWP_NOSIZE | SWP_NOMOVE | SWP_NOACTIVATE | SWP_SHOWWINDOW
    DllCall("SetWindowPos", "ptr", bgGui.Hwnd, "ptr", targetHwnd, "int", 0, "int", 0, "int", 0, "int", 0, "uint", 0x53)
}

OnForegroundChange(a, b, hwnd, *)
{
    global bgGui, targetHwnd, isBackdropVisible

    ; 1. If the recorded window was closed or killed, clean up completely
    if (!WinExist(targetHwnd))
    {
        CleanupRuntime()
        return
    }

    ; 2. Ignore invalid HWNDs and events from the backdrop itself
    if (!hwnd || hwnd = bgGui.Hwnd)
    {
        return
    }

    ; 3. If target window gained focus
    if (hwnd = targetHwnd)
    {
        ; Restore the backdrop without stealing focus
        bgGui.Show("NoActivate")

        ; Re-insert directly beneath the active window in the Z-order
        DllCall("SetWindowPos", "ptr", bgGui.Hwnd, "ptr", targetHwnd, "int", 0, "int", 0, "int", 0, "int", 0, "uint", 0x53)

        isBackdropVisible := true
    }
    ; 4. If focus shifted elsewhere and backdrop is visible
    else if (isBackdropVisible)
    {
        bgGui.Hide()
        isBackdropVisible := false
    }
}

CleanupRuntime()
{
    global bgGui, targetHwnd, targetHwndWidth, targetHwndHeight, isBackdropVisible, hHook, hookProc

    ; Unhook the WinEvent hook
    if (hHook)
    {
        DllCall("UnhookWinEvent", "ptr", hHook)
        CallbackFree(hookProc)
        hHook := 0
        hookProc := 0
    }

    ; Destroy the GUI and reset variables
    if (bgGui is Gui)
    {
        bgGui.Destroy()
        bgGui := ""
    }

    targetHwnd := 0
    targetHwndWidth := 0
    targetHwndHeight := 0
    isBackdropVisible := false
}
