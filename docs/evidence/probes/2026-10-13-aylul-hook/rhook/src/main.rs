// THROWAWAY probe: read stdin, send one line over the pipe, print the reply.
use std::io::{BufRead, BufReader, Read, Write};
fn main() {
    let mut input = String::new();
    std::io::stdin().read_to_string(&mut input).ok();
    let Ok(mut pipe) = std::fs::OpenOptions::new()
        .read(true)
        .write(true)
        .open(r"\\.\pipe\aylul-probe")
    else {
        return;
    };
    let _ = pipe.write_all(format!("{}\n", input.replace('\n', " ")).as_bytes());
    let mut line = String::new();
    let _ = BufReader::new(pipe).read_line(&mut line);
    print!("{line}");
}
