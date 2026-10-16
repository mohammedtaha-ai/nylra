pub fn show(window: &tauri::WebviewWindow) -> Result<(), String> {
    #[cfg(windows)]
    {
        use windows_sys::Win32::UI::WindowsAndMessaging::{
            IsWindowVisible, ShowWindow, SW_SHOWNOACTIVATE,
        };
        let handle = window.hwnd().map_err(|_| "companion_show_failed")?;
        // ShowWindow returns previous visibility, not success. Never activate this surface.
        unsafe {
            ShowWindow(handle.0 as _, SW_SHOWNOACTIVATE);
        }
        if unsafe { IsWindowVisible(handle.0 as _) } == 0 {
            return Err("companion_show_failed".into());
        }
        Ok(())
    }
    #[cfg(not(windows))]
    {
        let _ = window;
        Err("companion_platform_unavailable".into())
    }
}
