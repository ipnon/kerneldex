from pathlib import Path

CONFIG_DIR = Path.home() / ".config" / "kerneldex"
TOKEN_FILE = CONFIG_DIR / "token"
DEFAULT_BASE_URL = "http://localhost:4000"


def get_token() -> str | None:
    if TOKEN_FILE.exists():
        return TOKEN_FILE.read_text().strip()
    return None


def save_token(token: str) -> None:
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    TOKEN_FILE.write_text(token + "\n")
    TOKEN_FILE.chmod(0o600)


def get_base_url() -> str:
    import os
    return os.environ.get("KERNELDEX_URL", DEFAULT_BASE_URL)
