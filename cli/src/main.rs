mod client;
mod config;

use std::path::PathBuf;
use std::process;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "kerneldex", about = "KernelDex — search and submit GPU kernel implementations.")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Search for GPU kernels
    Search {
        /// Free-text search query
        query: Option<String>,
        /// Filter by algorithm
        #[arg(short, long)]
        algorithm: Option<String>,
        /// Filter by language (HIP, CUDA, Triton, ...)
        #[arg(short, long)]
        language: Option<String>,
        /// Filter by hardware target (MI300X, H100, ...)
        #[arg(long)]
        hardware: Option<String>,
        /// Filter by source project
        #[arg(short, long)]
        source: Option<String>,
        /// Output as JSON
        #[arg(long = "json")]
        as_json: bool,
    },
    /// Show details for a specific kernel
    Show {
        /// Kernel ID
        id: u64,
        /// Output as JSON
        #[arg(long = "json")]
        as_json: bool,
    },
    /// Submit a new kernel (requires authentication)
    Submit {
        /// Path to source file
        #[arg(long)]
        file: PathBuf,
        /// Origin URL (GitHub permalink, etc.)
        #[arg(long)]
        source_url: String,
        /// Algorithm (e.g. attention_mla_decode)
        #[arg(short, long)]
        algorithm: String,
        /// Language (HIP, CUDA, Triton, ...) — inferred from extension if omitted
        #[arg(short, long)]
        language: Option<String>,
        /// Override file name (defaults to basename of --file)
        #[arg(long)]
        file_name: Option<String>,
        /// Display name (defaults to file name without extension)
        #[arg(long)]
        name: Option<String>,
        /// Source project (e.g. AITER)
        #[arg(long)]
        source: Option<String>,
        /// Hardware target(s)
        #[arg(long)]
        hardware: Vec<String>,
        /// Technique(s)
        #[arg(long)]
        techniques: Vec<String>,
        /// Free-form notes
        #[arg(long)]
        notes: Option<String>,
    },
    /// Authenticate with KernelDex via GitHub
    Login,
    /// Show current authentication status
    Token,
}

fn main() {
    let cli = Cli::parse();
    if let Err(e) = run(cli) {
        eprintln!("Error: {e:#}");
        process::exit(1);
    }
}

fn run(cli: Cli) -> anyhow::Result<()> {
    match cli.command {
        Commands::Search {
            query,
            algorithm,
            language,
            hardware,
            source,
            as_json,
        } => cmd_search(query, algorithm, language, hardware, source, as_json),
        Commands::Show { id, as_json } => cmd_show(id, as_json),
        Commands::Submit {
            file,
            source_url,
            algorithm,
            language,
            file_name,
            name,
            source,
            hardware,
            techniques,
            notes,
        } => cmd_submit(file, &source_url, &algorithm, language, file_name, name, source, hardware, techniques, notes),
        Commands::Login => cmd_login(),
        Commands::Token => cmd_token(),
    }
}

fn cmd_search(
    query: Option<String>,
    algorithm: Option<String>,
    language: Option<String>,
    hardware: Option<String>,
    source: Option<String>,
    as_json: bool,
) -> anyhow::Result<()> {
    let result = client::search_kernels(
        query.as_deref(),
        algorithm.as_deref(),
        language.as_deref(),
        hardware.as_deref(),
        source.as_deref(),
    )?;

    if as_json {
        println!("{}", serde_json::to_string_pretty(&result)?);
        return Ok(());
    }

    let kernels = result["data"].as_array();
    let kernels = match kernels {
        Some(k) if !k.is_empty() => k,
        _ => {
            println!("No kernels found.");
            return Ok(());
        }
    };

    println!("{} kernels found:\n", kernels.len());
    for k in kernels {
        let hw = k["hardware"]
            .as_array()
            .map(|a| {
                a.iter()
                    .filter_map(|v| v.as_str())
                    .collect::<Vec<_>>()
                    .join(", ")
            })
            .unwrap_or_default();

        let display_name = k["name"].as_str()
            .or(k["file_name"].as_str())
            .unwrap_or("");

        println!("  [{}] {}", k["id"], display_name);
        println!(
            "       {}  |  {}  |  {}",
            k["file_name"].as_str().unwrap_or(""),
            k["language"].as_str().unwrap_or(""),
            k["algorithm"].as_str().unwrap_or("")
        );
        if !hw.is_empty() {
            println!("       hw: {hw}");
        }
        println!();
    }

    Ok(())
}

fn cmd_show(id: u64, as_json: bool) -> anyhow::Result<()> {
    let result = client::get_kernel(id)?;

    if as_json {
        println!("{}", serde_json::to_string_pretty(&result)?);
        return Ok(());
    }

    let k = &result["data"];
    let display_name = k["name"].as_str()
        .or(k["file_name"].as_str())
        .unwrap_or("");
    println!("{display_name}");
    println!("File:     {}", k["file_name"].as_str().unwrap_or(""));
    println!("Algo:     {}", k["algorithm"].as_str().unwrap_or(""));
    println!("Language: {}", k["language"].as_str().unwrap_or(""));
    println!("URL:      {}", k["source_url"].as_str().unwrap_or(""));

    if let Some(hw) = k["hardware"].as_array() {
        let hw: Vec<_> = hw.iter().filter_map(|v| v.as_str()).collect();
        if !hw.is_empty() {
            println!("Hardware: {}", hw.join(", "));
        }
    }
    if let Some(src) = k["source_project"].as_str() {
        if !src.is_empty() {
            println!("Source:   {src}");
        }
    }
    if let Some(notes) = k["notes"].as_str() {
        if !notes.is_empty() {
            println!("Notes:    {notes}");
        }
    }

    Ok(())
}

fn infer_language(path: &std::path::Path) -> Option<String> {
    match path.extension()?.to_str()? {
        "cu" | "cuh" => Some("HIP".to_string()),
        "cpp" | "hpp" => Some("HIP".to_string()),
        "py" => Some("Python".to_string()),
        "md" => Some("docs".to_string()),
        _ => None,
    }
}

fn cmd_submit(
    file: PathBuf,
    source_url: &str,
    algorithm: &str,
    language: Option<String>,
    file_name: Option<String>,
    name: Option<String>,
    source: Option<String>,
    hardware: Vec<String>,
    techniques: Vec<String>,
    notes: Option<String>,
) -> anyhow::Result<()> {
    if config::get_token().is_none() {
        eprintln!("Not authenticated. Run 'kerneldex login' first.");
        process::exit(1);
    }

    // Verify source URL is reachable
    let http = reqwest::blocking::Client::builder()
        .timeout(std::time::Duration::from_secs(10))
        .build()?;
    let resp = http.head(source_url).send()
        .map_err(|e| anyhow::anyhow!("checking source URL: {e}"))?;
    if !resp.status().is_success() {
        anyhow::bail!("source URL returned {}: {}", resp.status(), source_url);
    }

    let source_code = std::fs::read_to_string(&file)
        .map_err(|e| anyhow::anyhow!("reading {}: {e}", file.display()))?;

    let fname = file_name.unwrap_or_else(|| {
        file.file_name()
            .unwrap_or_default()
            .to_string_lossy()
            .to_string()
    });

    let lang = language.unwrap_or_else(|| {
        infer_language(&file).unwrap_or_else(|| "unknown".to_string())
    });

    let hw = if hardware.is_empty() { None } else { Some(hardware) };
    let tech = if techniques.is_empty() { None } else { Some(techniques) };

    let result = client::submit_kernel(
        &source_code,
        source_url,
        &fname,
        &lang,
        algorithm,
        name.as_deref(),
        source.as_deref(),
        hw,
        tech,
        notes.as_deref(),
    )?;

    let k = &result["data"];
    let display_name = k["name"].as_str()
        .or(k["file_name"].as_str())
        .unwrap_or("");
    println!("Kernel created: [{}] {}", k["id"], display_name);

    Ok(())
}

fn cmd_login() -> anyhow::Result<()> {
    let base = config::get_base_url();
    let url = format!("{base}/tokens");
    println!("Opening {url} in your browser...");
    println!("1. Sign in with GitHub");
    println!("2. Create an API token");
    println!("3. Paste the token below\n");
    let _ = open::that(&url);

    print!("API token: ");
    use std::io::{self, Write};
    io::stdout().flush()?;
    let mut token = String::new();
    io::stdin().read_line(&mut token)?;
    let token = token.trim();

    if token.is_empty() {
        anyhow::bail!("no token provided");
    }

    config::save_token(token)?;
    println!("Token saved.");

    Ok(())
}

fn cmd_token() -> anyhow::Result<()> {
    match config::get_token() {
        Some(t) if t.len() >= 12 => {
            println!("Token configured: {}...{}", &t[..8], &t[t.len() - 4..]);
        }
        Some(t) => {
            println!("Token configured: {t}");
        }
        None => {
            println!("No token configured. Run 'kerneldex login'.");
        }
    }
    Ok(())
}
