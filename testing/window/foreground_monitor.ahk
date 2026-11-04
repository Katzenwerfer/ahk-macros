#Requires AutoHotkey v2.0
#SingleInstance Force

; ---------------
; === Hotkeys ===
; ---------------

; Hotkey to exit the script
F1 & ESC:: ExitApp()

; ------------------------
; === Global variables ===
; ------------------------

recordedData := []

; ---------------------
; === WinEvent Hook ===
; ---------------------

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

OnExit(CleanupAndSave)

; ----------------------
; === Event Handlers ===
; ----------------------

OnForegroundChange(a, b, hwnd, *)
{
    global recordedData

    if (WinExist(hwnd))
    {
        title := WinGetTitle(hwnd)
        class := WinGetClass(hwnd)
        exe := WinGetProcessName(hwnd)
        pid := WinGetPID(hwnd)
        id := WinGetID(hwnd)

        record := {
            timestamp: FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"),
            hwnd: id,
            title: title,
            class: class,
            exe: exe,
            pid: pid
        }
        recordedData.Push(record)

        ToolTip(
            title . "`n" .
            "ahk_class: " . class . "`n" .
            "ahk_exe " . exe . "`n" .
            "ahk_pid " . pid . "`n" .
            "ahk_id " . id,
            0, 0
        )

        SetTimer(() => ToolTip(), -2000)
    }
}

; ---------------------
; === Exit & Export ===
; ---------------------

CleanupAndSave(ExitReason, ExitCode)
{
    global hHook, hookProc

    if (hHook)
    {
        DllCall("UnhookWinEvent", "ptr", hHook)
        hHook := 0
    }
    if (hookProc)
    {
        CallbackFree(hookProc)
        hookProc := 0
    }

    SaveDataToCsv()
}

SaveDataToCsv(csvPath := "foreground_monitor.csv")
{
    global recordedData

    fileDir := A_ScriptDir
    fullPath := (SubStr(csvPath, 2, 1) == ":" || SubStr(csvPath, 1, 2) == "\\") ? csvPath : fileDir . "\" . csvPath

    fileObj := FileOpen(fullPath, "w", "UTF-8")
    if (!fileObj)
    {
        return
    }

    ; CSV Header
    fileObj.WriteLine("timestamp,hwnd,title,class,exe,pid")

    for record in recordedData
    {
        escapedTitle := '"' . StrReplace(record.title, '"', '""') . '"'
        escapedClass := '"' . StrReplace(record.class, '"', '""') . '"'
        escapedExe := '"' . StrReplace(record.exe, '"', '""') . '"'

        line := record.timestamp . "," . record.hwnd . "," . escapedTitle . "," . escapedClass . "," . escapedExe . "," . record.pid
        fileObj.WriteLine(line)
    }

    fileObj.Close()
}
