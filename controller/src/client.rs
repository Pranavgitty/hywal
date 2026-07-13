use std::{
    env,
    io::Write,
    os::unix::net::UnixStream,
};

const SOCKET: &str = "/tmp/wallpaper-controller.sock";

fn main() -> std::io::Result<()> {
    let command = env::args()
        .nth(1)
        .unwrap_or_else(|| "toggle".to_string());

    let mut stream = UnixStream::connect(SOCKET)?;

    stream.write_all(command.as_bytes())?;

    println!("Sent: {}", command);

    Ok(())
}
