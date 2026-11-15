class Window
{
    ; Blacklisted window classes
    static BlacklistedClasses := [
        "ForegroundStaging",
        "Shell_TrayWnd",
        "TopLevelWindowForOverflowXamlIsland",
        "Windows.UI.Core.CoreWindow",
        "XamlExplorerHostIslandWindow"
    ]

    ; Check if an hwnd should be ignored based on class
    static IsBlacklistedClass(hwnd)
    {
        if (!WinExist(hwnd))
        {
            return true
        }

        winClass := WinGetClass(hwnd)
        for item in this.BlacklistedClasses
        {
            if (winClass = item)
            {
                return true
            }
        }
        return false
    }

    ; Retrieve the monitor area
    static GetMonitorArea()
    {
        MonitorGet(MonitorGetPrimary(), &left, &top, &right, &bottom)
        return {
            x: left,
            y: top,
            w: right - left,
            h: bottom - top
        }
    }

    ; Retrieve the desktop work area (excluding taskbar)
    static GetWorkArea()
    {
        MonitorGetWorkArea(MonitorGetPrimary(), &left, &top, &right, &bottom)
        return {
            x: left,
            y: top,
            w: right - left,
            h: bottom - top
        }
    }

    ; Get the window area
    static GetWindowArea(hwnd)
    {
        WinGetPos(&outX, &outY, &outWidth, &outHeight, hwnd)
        return {
            x: outX,
            y: outY,
            w: outWidth,
            h: outHeight
        }
    }

    ; Get the window client area
    static GetClientArea(hwnd)
    {
        WinGetClientPos(&outX, &outY, &outWidth, &outHeight, hwnd)
        return {
            x: outX,
            y: outY,
            w: outWidth,
            h: outHeight
        }
    }

    ; Remove the title bar and border
    static SetWindowBorderless(hwnd, borderless := true)
    {
        try WinSetStyle((borderless ? "-" : "+") . "0xC40000", hwnd)
        WinRedraw(hwnd)
    }

    ; Position at the center of the work area
    static CenterWindow(hwnd, customSize := [], monitorArea := false, clientArea := false)
    {
        if (monitorArea)
        {
            bounds := Window.GetMonitorArea()
        }
        else
        {
            bounds := Window.GetWorkArea()
        }
        if (clientArea)
        {
            size := Window.GetClientArea(hwnd)
        }
        else
        {
            size := Window.GetWindowArea(hwnd)
        }
        if (customSize.Length)
        {
            size.w := customSize[1]
            size.h := customSize[2]
        }
        x := Round(bounds.x + (bounds.w - size.w) / 2)
        y := Round(bounds.y + (bounds.h - size.h) / 2)
        try WinMove(x, y, size.w, size.h, hwnd)
        WinRedraw(hwnd)
    }
}
