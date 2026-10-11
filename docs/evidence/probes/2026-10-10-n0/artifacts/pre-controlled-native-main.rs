// NON-PRODUCT N0 reproduction. Synthetic state only; no Shadows/network access.
use std::{fs::OpenOptions, io::Write, time::Duration};
use tauri::{LogicalPosition, LogicalSize, Manager, WebviewUrl, WebviewWindowBuilder};
use tauri_plugin_global_shortcut::{GlobalShortcutExt, ShortcutState};
fn log(v: serde_json::Value) {
    let path = std::env::var("N0_LOG").expect("N0_LOG required");
    let mut f = OpenOptions::new()
        .create(true)
        .append(true)
        .open(path)
        .unwrap();
    writeln!(f, "{}", v).unwrap();
}
#[tauri::command]
fn metrics(window: tauri::WebviewWindow, value: serde_json::Value) {
    log(serde_json::json!({"event":"metrics","window":window.label(),"value":value}));
}
fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_single_instance::init(|_, args, _| log(serde_json::json!({"event":"second_instance","args":args}))))
        .plugin(tauri_plugin_global_shortcut::Builder::new().with_handler(|app, _, event| {
            if event.state() == ShortcutState::Pressed {
                log(serde_json::json!({"event":"shortcut_pressed"}));
                let w = app.get_webview_window("main").unwrap(); w.show().unwrap(); w.set_focus().unwrap();
            }
        }).build())
        .invoke_handler(tauri::generate_handler![metrics])
        .setup(|app| {
            let main = WebviewWindowBuilder::new(app, "main", WebviewUrl::App("index.html?main".into()))
                .title("N0 Synthetic Main").inner_size(640.,480.).position(60.,60.).build()?;
            let companion = WebviewWindowBuilder::new(app, "companion", WebviewUrl::App("index.html?companion".into()))
                .title("N0 Synthetic Companion").inner_size(180.,180.).position(760.,200.)
                .transparent(true).decorations(false).always_on_top(true).shadow(false).build()?;
            let rgba = vec![128u8; 16*16*4];
            let tray = tauri::tray::TrayIconBuilder::new().icon(tauri::image::Image::new_owned(rgba,16,16))
                .tooltip("NON-PRODUCT N0 probe").on_tray_icon_event(|_,e| log(serde_json::json!({"event":"tray_input","value":format!("{e:?}")}))).build(app)?;
            log(serde_json::json!({"event":"tray_created","id":tray.id().as_ref()}));
            app.manage(tray);
            app.global_shortcut().register("Ctrl+Alt+Shift+F12")?;
            log(serde_json::json!({"event":"shortcut_registered"}));
            for w in [&main, &companion] {
                let label = w.label().to_owned();
                w.on_window_event(move |e| log(serde_json::json!({"event":"window_event","window":label,"value":format!("{e:?}")})));
                log(serde_json::json!({"event":"window_created","window":w.label(),"scale":w.scale_factor()?,"position":format!("{:?}",w.outer_position()?),"size":format!("{:?}",w.inner_size()?)}));
            }
            log(serde_json::json!({"event":"monitors","value":format!("{:?}",main.available_monitors()?)}));
            let handle=app.handle().clone();
            std::thread::spawn(move || {
                let control = std::env::var("N0_CONTROL").unwrap();
                let mut restricted=false;
                let mut last_ignore=None;
                loop {
                    std::thread::sleep(Duration::from_millis(100));
                    if restricted {
                        let c=handle.get_webview_window("companion").unwrap();
                        if c.is_visible().unwrap_or(false) {
                            let p=handle.cursor_position().unwrap(); let o=c.outer_position().unwrap(); let s=c.inner_size().unwrap();
                            // Independently authored rectangular synthetic target, not Coucou body geometry.
                            let x=p.x-o.x as f64; let y=p.y-o.y as f64;
                            let ignore= !(x>=s.width as f64*0.25 && x<s.width as f64*0.75 && y>=s.height as f64*0.25 && y<s.height as f64*0.75);
                            if last_ignore!=Some(ignore) {c.set_ignore_cursor_events(ignore).unwrap();last_ignore=Some(ignore);log(serde_json::json!({"event":"restricted_hit","ignore":ignore,"local":[x,y]}));}
                        }
                    }
                    let Ok(cmd) = std::fs::read_to_string(&control) else {continue};
                    let _=std::fs::remove_file(&control);
                    let c=handle.get_webview_window("companion").unwrap();
                    let m=handle.get_webview_window("main").unwrap();
                    let result: Result<(),tauri::Error> = match cmd.trim() {
                        "hide" => c.eval("setSurfaceVisible(false)").and_then(|_|c.hide()),
                        "show" => c.show().and_then(|_|c.eval("setSurfaceVisible(true)")),
                        "ignore" => c.set_ignore_cursor_events(true), "capture" => c.set_ignore_cursor_events(false),
                        "focus-main" => m.set_focus(), "focus-companion" => c.set_focus(),
                        "nonfocusable" => c.set_focusable(false),
                        "css" => c.eval("setRenderer('css')"),
                        "canvas" => c.eval("setRenderer('canvas')"),
                        "focusable" => c.set_focusable(true),
                        "drag" => c.start_dragging(),
                        "restricted" => {restricted=true;last_ignore=None;Ok(())},
                        "unrestricted" => {restricted=false;last_ignore=None;c.set_ignore_cursor_events(false)},
                        "board" => {WebviewWindowBuilder::new(&handle,"assets",WebviewUrl::App("compare.html".into())).title("N0 AYLUL Asset Inspection").inner_size(1000.,810.).position(10.,10.).build().map(|_|())},
                        "board-v2" => {WebviewWindowBuilder::new(&handle,"assets",WebviewUrl::App("compare.html?v2".into())).title("N0 AYLUL Asset Inspection").inner_size(1000.,810.).position(10.,10.).build().map(|_|())},
                        "board-close" => handle.get_webview_window("assets").unwrap().close(),
                        "overlap" => c.set_position(LogicalPosition::new(200.,200.)),
                        "size100" => c.set_size(LogicalSize::new(128.,128.)),
                        "size150" => c.set_size(LogicalSize::new(192.,192.)),
                        "size200" => c.set_size(LogicalSize::new(256.,256.)),
                        "offscreen" => c.set_position(LogicalPosition::new(-10000.,-10000.)),
                        "recover" => c.set_position(LogicalPosition::new(760.,200.)),
                        "idle" | "active" | "reduced" => c.eval(&format!("setMode('{}')",cmd.trim())),
                        "tray-rect" => {log(serde_json::json!({"event":"tray_rect","value":format!("{:?}",handle.state::<tauri::tray::TrayIcon>().rect())}));Ok(())},
                        "tray-hide" => handle.state::<tauri::tray::TrayIcon>().set_visible(false),
                        "tray-show" => handle.state::<tauri::tray::TrayIcon>().set_visible(true),
                        "exit" => {handle.exit(0); break;},
                        _ => {log(serde_json::json!({"event":"unknown_control","cmd":cmd})); continue;}
                    };
                    log(serde_json::json!({"event":"control","cmd":cmd.trim(),"result":format!("{result:?}")}));
                }
            });
            Ok(())
        }).run(tauri::generate_context!()).expect("probe runtime failed");
}
