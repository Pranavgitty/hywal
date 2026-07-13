use std::{
    fs,
    io::Read,
    os::unix::net::UnixListener,
    process::Command,
};

const SOCKET: &str = "/tmp/hywal.sock";
const STATE_FILE: &str = "/tmp/hywal.state";

fn wallpaper_running() -> bool {
    Command::new("pgrep")
        .args(["-f", "qs -c wallpaper-switcher"])
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

fn start_wallpaper_switcher() {
    println!("Starting wallpaper switcher...");

    if let Err(err) = Command::new("qs")
        .args(["-c", "wallpaper-switcher", "-n", "-d"])
        .spawn()
    {
        eprintln!("Failed to start wallpaper switcher: {err}");
    }
}

fn write_state(state: &str) {
    if let Err(err) = fs::write(STATE_FILE, state) {
        eprintln!("Failed to write state: {err}");
    } else {
        println!("State -> {state}");
    }
}

fn main() -> std::io::Result<()> {
    let _ = fs::remove_file(SOCKET);

    let listener = UnixListener::bind(SOCKET)?;

    println!("Listening on {}", SOCKET);

    loop {
        let (mut stream, _) = listener.accept()?;

        let mut message = String::new();
        stream.read_to_string(&mut message)?;

        match message.trim() {
            "toggle" => {
                let current = fs::read_to_string(STATE_FILE)
                    .unwrap_or_else(|_| "hide".to_string());

                let next = if current.trim() == "show" {
                    "hide"
                } else {
                    "show"
                };

                write_state(next);

                if next == "show" && !wallpaper_running() {
                    start_wallpaper_switcher();
                }
            }

            "show" => {
                write_state("show");

                if !wallpaper_running() {
                    start_wallpaper_switcher();
                }
            }

            "hide" => {
                write_state("hide");
            }

            "reload" => {
                println!("Reload requested");
                // TODO: Implement wallpaper reload
            }

            cmd => {
                println!("Unknown command: {cmd}");
            }
        }
    }
}
