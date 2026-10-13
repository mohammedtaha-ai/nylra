use std::io::Read;

fn main() {
    let mut input = String::new();
    if std::io::stdin().read_to_string(&mut input).is_err() {
        return;
    }
    let endpoint = std::env::var_os("LOCALAPPDATA")
        .map(|dir| {
            std::path::PathBuf::from(dir)
                .join("AYLUL")
                .join("hook.json")
        })
        .and_then(|path| aylul_hook::read_endpoint(&path));
    let project_dir = std::env::var("CLAUDE_PROJECT_DIR")
        .ok()
        .filter(|dir| !dir.is_empty());
    let open = |pipe: &str| {
        let pipe = pipe.to_owned();
        aylul_hook::connect_retrying(
            || {
                std::fs::OpenOptions::new()
                    .read(true)
                    .write(true)
                    .open(&pipe)
            },
            50,
            std::time::Duration::from_millis(20),
        )
    };
    if let Some(output) = aylul_hook::run(&input, endpoint, project_dir, open) {
        print!("{output}");
    }
}
