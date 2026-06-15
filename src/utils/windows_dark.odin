package utils

import win32 "core:sys/windows"
import rl "vendor:raylib"

foreign import dwmapi "system:dwmapi.lib"

@(default_calling_convention = "stdcall")
foreign dwmapi {
    DwmSetWindowAttribute :: proc(
    hwnd:        win32.HWND,
    dwAttribute: win32.DWORD,
    pvAttribute: rawptr,
    cbAttribute: win32.DWORD,
    ) -> win32.HRESULT ---
}

DWMWA_USE_IMMERSIVE_DARK_MODE :: win32.DWORD(20)

// Sets the title bar of the application window to use a dark theme, if supported by the operating system.
SetDarkTitlebar :: proc() {
    hwnd := cast(win32.HWND)rl.GetWindowHandle()
    dark := win32.BOOL(win32.TRUE)
    DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark, size_of(dark))
}