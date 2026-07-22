use std::{
    io::Write,
    os::unix::net::UnixStream,
    path::PathBuf,
};

use anyhow::{Context, Result};
use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "hywalctl", version, about = "Control the HyWal wallpaper switcher daemon")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Toggle the wallpaper switcher visibility
    Toggle,
    /// Show the wallpaper switcher
    Show,
    /// Hide the wallpaper switcher
    Hide,
    /// Reload wallpaper list
    Reload,
    /// Print current status
    Status,
    /// Apply a specific wallpaper by path
    Apply { path: String },
}

fn socket_path() -> PathBuf {
    let runtime_dir = std::env::var("XDG_RUNTIME_DIR")
        .unwrap_or_else(|_| format!("/tmp/hywal-{}", std::process::id()));
    PathBuf::from(runtime_dir).join("hywal.sock")
}

fn send_command(cmd: &str) -> Result<()> {
    let socket = socket_path();
    let mut stream = UnixStream::connect(&socket)
        .with_context(|| format!("Failed to connect to daemon at {}", socket.display()))?;
    stream.write_all(cmd.as_bytes())
        .context("Failed to send command")?;
    Ok(())
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    let cmd = match cli.command {
        Commands::Toggle => "toggle",
        Commands::Show => "show",
        Commands::Hide => "hide",
        Commands::Reload => "reload",
        Commands::Status => "status",
        Commands::Apply { path } => {
            // Send apply command with path
            let socket = socket_path();
            let mut stream = UnixStream::connect(&socket)
                .with_context(|| format!("Failed to connect to daemon at {}", socket.display()))?;
            let full_cmd = format!("apply\t{}", path);
            stream.write_all(full_cmd.as_bytes())
                .context("Failed to send apply command")?;
            println!("Applied wallpaper: {}", path);
            return Ok(());
        }
    };

    send_command(cmd)?;
    println!("Sent: {}", cmd);
    Ok(())
}