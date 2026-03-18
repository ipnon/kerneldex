use std::fs;
use std::path::PathBuf;

use anyhow::{Context, Result};

const DEFAULT_BASE_URL: &str = "https://kerneldex.fly.dev";

fn config_dir() -> PathBuf {
    dirs::config_dir()
        .unwrap_or_else(|| PathBuf::from("."))
        .join("kerneldex")
}

fn token_path() -> PathBuf {
    config_dir().join("token")
}

pub fn get_token() -> Option<String> {
    fs::read_to_string(token_path())
        .ok()
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty())
}

pub fn save_token(token: &str) -> Result<()> {
    let dir = config_dir();
    fs::create_dir_all(&dir).context("creating config dir")?;
    let path = dir.join("token");
    fs::write(&path, format!("{token}\n")).context("writing token")?;
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        fs::set_permissions(&path, fs::Permissions::from_mode(0o600))?;
    }
    Ok(())
}

pub fn get_base_url() -> String {
    std::env::var("KERNELDEX_URL").unwrap_or_else(|_| DEFAULT_BASE_URL.to_string())
}
