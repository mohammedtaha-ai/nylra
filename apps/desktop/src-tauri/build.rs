fn main() {
    tauri_build::try_build(tauri_build::Attributes::new().app_manifest(
        tauri_build::AppManifest::new().commands(&[
            "hide_main",
            "auth_action",
            "cancel_login",
            "companion_state",
            "companion_ready",
            "set_companion_visible",
            "set_companion_paused",
            "drag_companion",
            "open_main_from_companion",
        ]),
    ))
    .expect("native build configuration")
}
