mod client;
mod config;

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
        /// Display name
        #[arg(long)]
        name: String,
        /// Unique file name
        #[arg(long)]
        file_name: String,
        /// Source project (e.g. AITER)
        #[arg(long)]
        source: String,
        /// Language (HIP, CUDA, Triton, ...)
        #[arg(short, long)]
        language: String,
        /// Algorithm (e.g. attention_mla_decode)
        #[arg(short, long)]
        algorithm: String,
        /// GitHub permalink
        #[arg(long)]
        source_url: Option<String>,
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
            name,
            file_name,
            source,
            language,
            algorithm,
            source_url,
            hardware,
            techniques,
            notes,
        } => cmd_submit(
            &name,
            &file_name,
            &source,
            &language,
            &algorithm,
            source_url.as_deref(),
            hardware,
            techniques,
            notes.as_deref(),
        ),
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
        let tech = k["techniques"]
            .as_array()
            .map(|a| {
                a.iter()
                    .filter_map(|v| v.as_str())
                    .collect::<Vec<_>>()
                    .join(", ")
            })
            .unwrap_or_default();

        println!("  [{}] {}", k["id"], k["name"].as_str().unwrap_or(""));
        println!(
            "       {}  |  {}  |  {}",
            k["file_name"].as_str().unwrap_or(""),
            k["language"].as_str().unwrap_or(""),
            k["source_project"].as_str().unwrap_or("")
        );
        if !hw.is_empty() {
            println!("       hw: {hw}");
        }
        if !tech.is_empty() {
            println!("       techniques: {tech}");
        }
        if let Some(notes) = k["notes"].as_str() {
            println!("       {notes}");
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
    println!("Name:     {}", k["name"].as_str().unwrap_or(""));
    println!("File:     {}", k["file_name"].as_str().unwrap_or(""));
    println!("Source:   {}", k["source_project"].as_str().unwrap_or(""));
    println!("Language: {}", k["language"].as_str().unwrap_or(""));
    println!("Algo:     {}", k["algorithm"].as_str().unwrap_or(""));

    if let Some(hw) = k["hardware"].as_array() {
        let hw: Vec<_> = hw.iter().filter_map(|v| v.as_str()).collect();
        if !hw.is_empty() {
            println!("Hardware: {}", hw.join(", "));
        }
    }
    if let Some(tech) = k["techniques"].as_array() {
        let tech: Vec<_> = tech.iter().filter_map(|v| v.as_str()).collect();
        if !tech.is_empty() {
            println!("Techs:    {}", tech.join(", "));
        }
    }
    if let Some(url) = k["source_url"].as_str() {
        println!("URL:      {url}");
    }
    if let Some(notes) = k["notes"].as_str() {
        println!("Notes:    {notes}");
    }

    Ok(())
}

fn cmd_submit(
    name: &str,
    file_name: &str,
    source: &str,
    language: &str,
    algorithm: &str,
    source_url: Option<&str>,
    hardware: Vec<String>,
    techniques: Vec<String>,
    notes: Option<&str>,
) -> anyhow::Result<()> {
    if config::get_token().is_none() {
        eprintln!("Not authenticated. Run 'kerneldex login' first.");
        process::exit(1);
    }

    let hw = if hardware.is_empty() {
        None
    } else {
        Some(hardware)
    };
    let tech = if techniques.is_empty() {
        None
    } else {
        Some(techniques)
    };

    let result =
        client::submit_kernel(name, file_name, source, language, algorithm, source_url, hw, tech, notes)?;

    let k = &result["data"];
    println!(
        "Kernel created: [{}] {}",
        k["id"],
        k["name"].as_str().unwrap_or("")
    );

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
