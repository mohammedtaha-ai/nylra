mod commands;
pub mod native_login;
mod windows;

pub fn run() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![commands::hide_main])
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
        .setup(windows::setup)
        .run(tauri::generate_context!())
        .expect("NYLRA native runtime failed");
}
