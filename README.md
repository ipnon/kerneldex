# KernelDex

A community-curated index of GPU kernel implementations.

There's no single place to find GPU kernels. They're scattered across framework repos (vLLM, SGLang, TRT-LLM), vendor libraries (CUTLASS, CK, AITER), competition submissions, personal repos, and blog posts. If you want to find "every MLA decode kernel" or "every FP8 GEMM on MI300X," you're doing archaeology.

KernelDex fixes that. Every kernel has source code and a link to where it came from. Search by algorithm, hardware, language, and source project.

**Live at [kerneldex.fly.dev](https://kerneldex.fly.dev)**

## Install CLI

```sh
curl -sSf https://raw.githubusercontent.com/ipnon/kerneldex/main/install.sh | sh
```

Requires [Rust](https://rustup.rs).

## Usage

```sh
# Search
kerneldex search --algorithm attention_mla_decode
kerneldex search --hardware MI300X --language HIP
kerneldex search mla

# View a kernel
kerneldex show 37

# Submit a kernel (requires login)
kerneldex login
kerneldex submit \
  --file ./my_kernel.cu \
  --source-url "https://github.com/org/repo/blob/main/path/to/kernel.cu" \
  -a attention_mla_decode \
  --hardware MI300X
```

Every submission requires a source file and a valid URL to its origin. The CLI validates the URL is reachable before uploading.

## Contributing

We need help cataloging kernels across all hardware targets. If you know where good kernels live, submit them via the CLI or open an issue.

Born from the [GPU MODE](https://discord.gg/gpumode) community.
