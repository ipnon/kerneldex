import json
import sys
import webbrowser

import click

from . import client
from .config import get_token, save_token, get_base_url


@click.group()
def cli():
    """KernelDex — search and submit GPU kernel implementations."""
    pass


@cli.command()
@click.argument("query", required=False)
@click.option("--algorithm", "-a", help="Filter by algorithm")
@click.option("--language", "-l", help="Filter by language (HIP, CUDA, Triton, ...)")
@click.option("--hardware", "-hw", help="Filter by hardware target (MI300X, H100, ...)")
@click.option("--source", "-s", help="Filter by source project")
@click.option("--json-output", "--json", "as_json", is_flag=True, help="Output as JSON")
def search(query, algorithm, language, hardware, source, as_json):
    """Search for GPU kernels."""
    try:
        result = client.search_kernels(
            q=query, algorithm=algorithm, language=language,
            hardware=hardware, source=source,
        )
    except Exception as e:
        click.echo(f"Error: {e}", err=True)
        sys.exit(1)

    kernels = result.get("data", [])

    if as_json:
        click.echo(json.dumps(result, indent=2))
        return

    if not kernels:
        click.echo("No kernels found.")
        return

    click.echo(f"{len(kernels)} kernels found:\n")
    for k in kernels:
        hw = ", ".join(k.get("hardware", []))
        tech = ", ".join(k.get("techniques", []))
        click.echo(f"  [{k['id']}] {k['name']}")
        click.echo(f"       {k['file_name']}  |  {k['language']}  |  {k['source_project']}")
        if hw:
            click.echo(f"       hw: {hw}")
        if tech:
            click.echo(f"       techniques: {tech}")
        if k.get("notes"):
            click.echo(f"       {k['notes']}")
        click.echo()


@cli.command()
@click.argument("kernel_id", type=int)
@click.option("--json-output", "--json", "as_json", is_flag=True, help="Output as JSON")
def show(kernel_id, as_json):
    """Show details for a specific kernel."""
    try:
        result = client.get_kernel(kernel_id)
    except Exception as e:
        click.echo(f"Error: {e}", err=True)
        sys.exit(1)

    k = result.get("data", {})

    if as_json:
        click.echo(json.dumps(result, indent=2))
        return

    click.echo(f"Name:     {k['name']}")
    click.echo(f"File:     {k['file_name']}")
    click.echo(f"Source:   {k['source_project']}")
    click.echo(f"Language: {k['language']}")
    click.echo(f"Algo:     {k['algorithm']}")
    if k.get("hardware"):
        click.echo(f"Hardware: {', '.join(k['hardware'])}")
    if k.get("techniques"):
        click.echo(f"Techs:    {', '.join(k['techniques'])}")
    if k.get("source_url"):
        click.echo(f"URL:      {k['source_url']}")
    if k.get("notes"):
        click.echo(f"Notes:    {k['notes']}")


@cli.command()
@click.option("--name", required=True, help="Display name")
@click.option("--file-name", required=True, help="Unique file name")
@click.option("--source", required=True, help="Source project (e.g. AITER)")
@click.option("--language", "-l", required=True, help="Language (HIP, CUDA, Triton, ...)")
@click.option("--algorithm", "-a", required=True, help="Algorithm (e.g. attention_mla_decode)")
@click.option("--source-url", help="GitHub permalink")
@click.option("--hardware", multiple=True, help="Hardware target(s)")
@click.option("--techniques", multiple=True, help="Technique(s)")
@click.option("--notes", help="Free-form notes")
def submit(name, file_name, source, language, algorithm, source_url, hardware, techniques, notes):
    """Submit a new kernel (requires authentication)."""
    if not get_token():
        click.echo("Not authenticated. Run 'kerneldex login' first.", err=True)
        sys.exit(1)

    try:
        result = client.submit_kernel(
            name=name,
            file_name=file_name,
            source_project=source,
            language=language,
            algorithm=algorithm,
            source_url=source_url,
            hardware=list(hardware) if hardware else None,
            techniques=list(techniques) if techniques else None,
            notes=notes,
        )
    except Exception as e:
        click.echo(f"Error: {e}", err=True)
        sys.exit(1)

    k = result.get("data", {})
    click.echo(f"Kernel created: [{k['id']}] {k['name']}")


@cli.command()
def login():
    """Authenticate with KernelDex via GitHub."""
    base = get_base_url()
    url = f"{base}/tokens"
    click.echo(f"Opening {url} in your browser...")
    click.echo("1. Sign in with GitHub")
    click.echo("2. Create an API token")
    click.echo("3. Paste the token below\n")
    webbrowser.open(url)
    token = click.prompt("API token")
    save_token(token)
    click.echo("Token saved.")


@cli.command()
def token():
    """Show current authentication status."""
    t = get_token()
    if t:
        click.echo(f"Token configured: {t[:8]}...{t[-4:]}")
    else:
        click.echo("No token configured. Run 'kerneldex login'.")
