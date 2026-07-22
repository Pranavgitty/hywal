use std::{
    fs,
    io::{Read, Write},
    os::unix::net::{UnixListener, UnixStream},
    path::PathBuf,
    process::Command,
};

fn socket_path() -> PathBuf {
    let runtime_dir = std::env::var("XDG_RUNTIME_DIR")
        .unwrap_or_else(|_| format!("/tmp/hywal-{}", std::process::id()));
    PathBuf::from(runtime_dir).join("hywal.sock")
}

fn state_file() -> PathBuf {
    let state_dir = std::env::var("XDG_STATE_HOME")
        .unwrap_or_else(|_| format!("{}/.local/state", std::env::var("HOME").unwrap_or_else(|_| "/tmp".to_string())));
    PathBuf::from(state_dir).join("hywal/state")
}

fn reload_file() -> PathBuf {
    let state_dir = std::env::var("XDG_STATE_HOME")
        .unwrap_or_else(|_| format!("{}/.local/state", std::env::var("HOME").unwrap_or_else(|_| "/tmp".to_string())));
    PathBuf::from(state_dir).join("hywal/reload")
}

fn wallpaper_running() -> bool {
    Command::new("pgrep")
        .args(["-f", "qs -c hywal"])
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

fn start_wallpaper_switcher() {
    println!("Starting wallpaper switcher...");

    if let Err(err) = Command::new("qs")
        .args(["-c", "hywal", "-n", "-d"])
        .spawn()
    {
        eprintln!("Failed to start wallpaper switcher: {err}");
    }
}

fn write_state(state: &str) {
    let state_path = state_file();
    if let Some(parent) = state_path.parent() {
        let _ = fs::create_dir_all(parent);
    }
    if let Err(err) = fs::write(&state_path, state) {
        eprintln!("Failed to write state to {}: {err}", state_path.display());
    } else {
        println!("State -> {state}");
    }
}

fn read_state() -> String {
    fs::read_to_string(state_file()).unwrap_or_else(|_| "hide".to_string())
}

fn send_response(socket: &PathBuf, response: &str) {
    if let Ok(mut stream) = UnixStream::connect(socket) {
        let _ = stream.write_all(response.as_bytes());
    }
}

fn main() -> std::io::Result<()> {
    let socket = socket_path();
    let _ = fs::remove_file(&socket);

    if let Some(parent) = socket.parent() {
        fs::create_dir_all(parent)?;
    }

    let listener = UnixListener::bind(&socket)?;
    println!("Listening on {}", socket.display());

    loop {
        let (mut stream, _) = listener.accept()?;

        let mut message = String::new();
        stream.read_to_string(&mut message)?;

        let parts: Vec<&str> = message.split('\t').collect();
        let cmd = parts[0].trim();

        match cmd {
            "toggle" => {
                let current = read_state();
                let next = if current.trim() == "show" { "hide" } else { "show" };
                write_state(next);

                if next == "show" && !wallpaper_running() {
                    start_wallpaper_switcher();
                }
                println!("Toggled to: {next}");
            }

            "show" => {
                write_state("show");
                if !wallpaper_running() {
                    start_wallpaper_switcher();
                }
                println!("Show");
            }

            "hide" => {
                write_state("hide");
                println!("Hide");
            }

            "status" => {
                let state = read_state();
                println!("Status: {state}");
                send_response(&socket, &state);
            }

            "reload" => {
                println!("Reload requested");
                // Signal the UI to reload by writing to reload file
                let reload_path = reload_file();
                if let Some(parent) = reload_path.parent() {
                    let _ = fs::create_dir_all(parent);
                }
                let _ = fs::write(&reload_path, "1");
            }

            "apply" => {
                if parts.len() >= 2 {
                    let path = parts[1];
                    println!("Applying wallpaper: {path}");
                    // Use aww to set wallpaper
                    if let Err(err) = Command::new("awww")
                        .args(["img", path, "--transition-type", "grow", "--transition-duration", "0.8"])
                        .spawn()
                    {
                        eprintln!("Failed to apply wallpaper: {err}");
                    }
                    // Also trigger matugen for color generation
                    if let Err(err) = Command::new("matugen")
                        .args(["image", path, "--source-color-index", "0"])
                        .spawn()
                    {
                        eprintln!("Failed to run matugen: {err}");
                    }
                    // Hide the switcher after applying
                    write_state("hide");
                } else {
                    eprintln!("Apply command missing path");
                }
            }

            cmd => {
                println!("Unknown command: {cmd}");
            }
        }
    }
}