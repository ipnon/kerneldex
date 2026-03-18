use anyhow::{Context, Result};
use reqwest::blocking::Client;
use serde::Serialize;

use crate::config;

fn build_client() -> Result<Client> {
    let mut builder = Client::builder().timeout(std::time::Duration::from_secs(30));
    if let Some(token) = config::get_token() {
        let mut headers = reqwest::header::HeaderMap::new();
        headers.insert(
            reqwest::header::AUTHORIZATION,
            format!("Bearer {token}").parse()?,
        );
        builder = builder.default_headers(headers);
    }
    builder.build().context("building HTTP client")
}

fn base_url() -> String {
    config::get_base_url()
}

pub fn search_kernels(
    q: Option<&str>,
    algorithm: Option<&str>,
    language: Option<&str>,
    hardware: Option<&str>,
    source: Option<&str>,
) -> Result<serde_json::Value> {
    let client = build_client()?;
    let mut params = Vec::new();
    if let Some(v) = q {
        params.push(("q", v));
    }
    if let Some(v) = algorithm {
        params.push(("algorithm", v));
    }
    if let Some(v) = language {
        params.push(("language", v));
    }
    if let Some(v) = hardware {
        params.push(("hardware", v));
    }
    if let Some(v) = source {
        params.push(("source", v));
    }

    let resp = client
        .get(format!("{}/api/kernels", base_url()))
        .query(&params)
        .send()
        .context("search request failed")?
        .error_for_status()
        .context("search returned error")?;

    resp.json().context("parsing search response")
}

pub fn get_kernel(id: u64) -> Result<serde_json::Value> {
    let client = build_client()?;
    let resp = client
        .get(format!("{}/api/kernels/{id}", base_url()))
        .send()
        .context("show request failed")?
        .error_for_status()
        .context("show returned error")?;

    resp.json().context("parsing show response")
}

#[derive(Serialize)]
struct SubmitPayload {
    kernel: SubmitKernel,
}

#[derive(Serialize)]
struct SubmitKernel {
    source_code: String,
    source_url: String,
    file_name: String,
    language: String,
    algorithm: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    name: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    source_project: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    hardware: Option<Vec<String>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    techniques: Option<Vec<String>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    notes: Option<String>,
}

pub fn submit_kernel(
    source_code: &str,
    source_url: &str,
    file_name: &str,
    language: &str,
    algorithm: &str,
    name: Option<&str>,
    source_project: Option<&str>,
    hardware: Option<Vec<String>>,
    techniques: Option<Vec<String>>,
    notes: Option<&str>,
) -> Result<serde_json::Value> {
    let client = build_client()?;
    let payload = SubmitPayload {
        kernel: SubmitKernel {
            source_code: source_code.to_string(),
            source_url: source_url.to_string(),
            file_name: file_name.to_string(),
            language: language.to_string(),
            algorithm: algorithm.to_string(),
            name: name.map(String::from),
            source_project: source_project.map(String::from),
            hardware,
            techniques,
            notes: notes.map(String::from),
        },
    };

    let resp = client
        .post(format!("{}/api/kernels", base_url()))
        .json(&payload)
        .send()
        .context("submit request failed")?
        .error_for_status()
        .context("submit returned error")?;

    resp.json().context("parsing submit response")
}
