use tauri::{WebviewUrl, WebviewWindowBuilder};

/// Disposable Linux preview: one local webview, without Windows account commands.
pub fn run() {
    tauri::Builder::default()
        .setup(|app| {
            WebviewWindowBuilder::new(app, "main", WebviewUrl::App("index.html".into()))
                .title("NYLRA · Linux probe")
                .inner_size(720., 640.)
                .build()?;
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("NYLRA Linux probe failed");
}
