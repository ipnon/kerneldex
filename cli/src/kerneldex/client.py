import httpx
from .config import get_token, get_base_url


def _client() -> httpx.Client:
    headers = {}
    token = get_token()
    if token:
        headers["Authorization"] = f"Bearer {token}"
    return httpx.Client(base_url=get_base_url(), headers=headers, timeout=30)


def search_kernels(
    q: str | None = None,
    algorithm: str | None = None,
    language: str | None = None,
    hardware: str | None = None,
    source: str | None = None,
) -> dict:
    params = {}
    if q:
        params["q"] = q
    if algorithm:
        params["algorithm"] = algorithm
    if language:
        params["language"] = language
    if hardware:
        params["hardware"] = hardware
    if source:
        params["source"] = source

    with _client() as c:
        r = c.get("/api/kernels", params=params)
        r.raise_for_status()
        return r.json()


def get_kernel(kernel_id: int) -> dict:
    with _client() as c:
        r = c.get(f"/api/kernels/{kernel_id}")
        r.raise_for_status()
        return r.json()


def submit_kernel(
    name: str,
    file_name: str,
    source_project: str,
    language: str,
    algorithm: str,
    source_url: str | None = None,
    hardware: list[str] | None = None,
    techniques: list[str] | None = None,
    notes: str | None = None,
) -> dict:
    payload = {
        "kernel": {
            "name": name,
            "file_name": file_name,
            "source_project": source_project,
            "language": language,
            "algorithm": algorithm,
        }
    }
    if source_url:
        payload["kernel"]["source_url"] = source_url
    if hardware:
        payload["kernel"]["hardware"] = hardware
    if techniques:
        payload["kernel"]["techniques"] = techniques
    if notes:
        payload["kernel"]["notes"] = notes

    with _client() as c:
        r = c.post("/api/kernels", json=payload)
        r.raise_for_status()
        return r.json()
