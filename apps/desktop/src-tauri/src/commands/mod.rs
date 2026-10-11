#[tauri::command]
pub fn hide_main(window: tauri::WebviewWindow) -> Result<(), String> {
    if window.label() != "main" {
        return Err("main surface required".into());
    }
    window.hide().map_err(|_| "unable to hide panel".into())
}
