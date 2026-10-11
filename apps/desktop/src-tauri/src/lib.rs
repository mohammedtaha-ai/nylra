pub mod auth;
mod commands;
pub mod native_login;
mod windows;

pub fn run() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            commands::hide_main,
            commands::auth_action,
            commands::cancel_login
        ])
        .plugin(tauri_plugin_single_instance::init(|app, _, _| {
            let _ = windows::open_main(app);
        }))
        .plugin(
            tauri_plugin_global_shortcut::Builder::new()
                .with_handler(|app, _, event| {
                    if event.state() == tauri_plugin_global_shortcut::ShortcutState::Pressed {
                        let _ = windows::open_main(app);
                    }
                })
                .build(),
        )
        .setup(|app| {
            use tauri::Manager;
            let path = app.path().app_data_dir()?.join("auth-v1.dpapi");
            app.manage(auth::AuthController::new(path));
            windows::setup(app)
        })
        .run(tauri::generate_context!())
        .expect("NYLRA native runtime failed");
}
