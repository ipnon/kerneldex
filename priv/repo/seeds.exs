alias Kerneldex.Repo
alias Kerneldex.Catalog.Kernel

kernels = [
  # === Attention / MLA Decode ===
  %{name: "AITER FP8 MLA Decode (MI300)", file_name: "aiter_mla_mi300_fp8_decode.cuh", source_project: "AITER", language: "HIP", algorithm: "attention_mla_decode", hardware: ["MI300X"], techniques: ["FP8", "MFMA"], notes: "Key file. MI300 FP8 decode, 37KB, 17x speedup"},
  %{name: "AITER ASM MLA Decode", file_name: "aiter_asm_mla_decode.cpp", source_project: "AITER", language: "HIP/ASM", algorithm: "attention_mla_decode", hardware: ["MI300X"], techniques: ["assembly"], notes: "Hand-written assembly MLA decode"},
  %{name: "AITER MLA Decode (Triton)", file_name: "aiter_mla_decode_triton.py", source_project: "AITER", language: "Triton", algorithm: "attention_mla_decode", hardware: ["MI300X"], techniques: ["fused_RoPE"], notes: "MLA decode with fused RoPE"},
  %{name: "AITER MLA Decode (HIP)", file_name: "aiter_mla_decode_hip.cu", source_project: "AITER", language: "HIP", algorithm: "attention_mla_decode", hardware: ["MI300X"], notes: "Main HIP decode dispatch"},
  %{name: "AITER MLA HK Decode FP8", file_name: "aiter_mla_hk_mi3xx_v32_fwd_decode_h128_fp8_fp8.cuh", source_project: "AITER", language: "HIP", algorithm: "attention_mla_decode", hardware: ["MI300X"], techniques: ["FP8"], notes: "FP8 decode variant"},
  %{name: "AITER MLA HK Decode Fwd", file_name: "aiter_mla_hk_decode_fwd.cu", source_project: "AITER", language: "HIP", algorithm: "attention_mla_decode", hardware: ["MI300X"], notes: "Decode forward"},
  %{name: "AITER Triton MLA Decode+RoPE", file_name: "aiter_triton_mla_decode_rope.py", source_project: "AITER", language: "Triton", algorithm: "attention_mla_decode", hardware: ["MI300X"], techniques: ["fused_RoPE"], notes: "Triton MLA decode+RoPE"},
  %{name: "AITER Triton Sparse MLA", file_name: "aiter_triton_unified_attention_sparse_mla.py", source_project: "AITER", language: "Triton", algorithm: "attention_mla_decode", hardware: ["MI300X"], techniques: ["sparse_attention"], notes: "Sparse MLA"},
  %{name: "AITER Triton MHA", file_name: "aiter_triton_mha.py", source_project: "AITER", language: "Triton", algorithm: "attention", hardware: ["MI300X"], notes: "Multi-head attention"},
  %{name: "AITER Attention", file_name: "aiter_attention.cu", source_project: "AITER", language: "HIP", algorithm: "attention", hardware: ["MI300X"], notes: "General attention"},
  %{name: "RadeonFlow MLA", file_name: "radeonflow_mla.cpp", source_project: "RadeonFlow", language: "HIP", algorithm: "attention_mla_decode", hardware: ["MI300X"], notes: "Competition winner"},
  %{name: "RadeonFlow MLA (mi300x)", file_name: "radeonflow_mla_mla.cpp", source_project: "RadeonFlow", language: "HIP", algorithm: "attention_mla_decode", hardware: ["MI300X"], notes: "Same kernel, mi300x collection"},
  %{name: "FlashMLA SM90 Decode Dense", file_name: "flashmla_sm90_decode_dense.cuh", source_project: "FlashMLA", language: "CUDA", algorithm: "attention_mla_decode", hardware: ["H100"], techniques: ["split_KV"], notes: "Split-KV Hopper decode"},
  %{name: "FlashMLA SM90 Decode Sparse FP8", file_name: "flashmla_sm90_decode_sparse_fp8.cuh", source_project: "FlashMLA", language: "CUDA", algorithm: "attention_mla_decode", hardware: ["H100"], techniques: ["FP8", "sparse_attention"], notes: "Sparse FP8 decode"},
  %{name: "FlashMLA SM100 Decode Head64", file_name: "flashmla_sm100_decode_head64.cuh", source_project: "FlashMLA", language: "CUDA", algorithm: "attention_mla_decode", hardware: ["B200"], notes: "Blackwell head64"},
  %{name: "FlashInfer MLA Decode CuTe SM80", file_name: "flashinfer_mla_decode_cute_sm80.cuh", source_project: "FlashInfer", language: "CUDA", algorithm: "attention_mla_decode", hardware: ["A100"], notes: "CuTe SM80 decode"},
  %{name: "FlashInfer CUTLASS MLA", file_name: "flashinfer_cutlass_mla.cuh", source_project: "FlashInfer", language: "CUDA", algorithm: "attention_mla_decode", hardware: ["H100"], techniques: ["CUTLASS"], notes: "CUTLASS MLA"},
  %{name: "FlashInfer MLA SM120", file_name: "flashinfer_mla_sm120.cu", source_project: "FlashInfer", language: "CUDA", algorithm: "attention_mla_decode", hardware: ["B200"], notes: "Blackwell XQA MLA"},
  %{name: "SGLang CUTLASS MLA Decode", file_name: "sglang_cutlass_mla_kernel.cu", source_project: "SGLang", language: "CUDA", algorithm: "attention_mla_decode", hardware: ["H100"], techniques: ["CUTLASS"], notes: "SM90 CUTLASS decode"},
  %{name: "SGLang ROCm MLA Decode (Triton)", file_name: "sglang_rocm_mla_decode_triton.py", source_project: "SGLang", language: "Triton", algorithm: "attention_mla_decode", hardware: ["MI300X"], techniques: ["fused_RoPE"], notes: "ROCm Triton MLA+RoPE"},
  %{name: "vLLM CUTLASS MLA SM100", file_name: "vllm_cutlass_mla_sm100.cu", source_project: "vLLM", language: "CUDA", algorithm: "attention_mla_decode", hardware: ["B200"], techniques: ["CUTLASS"], notes: "Blackwell CUTLASS"},
  %{name: "vLLM MLA Decode CPU", file_name: "vllm_mla_decode_cpu.cpp", source_project: "vLLM", language: "C++", algorithm: "attention_mla_decode", hardware: ["CPU"], techniques: ["NEON", "SSE"], notes: "NEON/SSE reference"},
  %{name: "TRT-LLM FlashMLA Kernel", file_name: "trtllm_flashmla_kernel.h", source_project: "TRT-LLM", language: "CUDA", algorithm: "attention_mla_decode", hardware: ["H100"], notes: "SM90 FlashMLA"},
  %{name: "TRT-LLM MLA SM120", file_name: "trtllm_mla_sm120.cu", source_project: "TRT-LLM", language: "CUDA", algorithm: "attention_mla_decode", hardware: ["B200"], notes: "Blackwell XQA"},
  %{name: "Flash Attn Triton AMD Fwd Decode", file_name: "flash_attn_triton_amd_fwd_decode.py", source_project: "Flash Attn", language: "Triton", algorithm: "attention_decode", hardware: ["MI300X"], notes: "AMD Triton decode"},
  %{name: "Flash Attn Triton AMD Fwd Prefill", file_name: "flash_attn_triton_amd_fwd_prefill.py", source_project: "Flash Attn", language: "Triton", algorithm: "attention_prefill", hardware: ["MI300X"], notes: "AMD Triton prefill"},
  %{name: "Flash Attn Triton AMD Bwd", file_name: "flash_attn_triton_amd_bwd.py", source_project: "Flash Attn", language: "Triton", algorithm: "attention_backward", hardware: ["MI300X"], notes: "AMD Triton backward"},
  %{name: "AITER Triton Paged Attention Decode", file_name: "aiter_triton_pa_decode.py", source_project: "AITER", language: "Triton", algorithm: "attention_decode", hardware: ["MI300X"], techniques: ["paged_attention"], notes: "Paged attention decode"},
  %{name: "HIPKittens GQA Attention", file_name: "hipkittens_attn_gqa_kernel.cpp", source_project: "HIPKittens", language: "HIP", algorithm: "attention_gqa", hardware: ["MI300X"], notes: "GQA attention"},
  %{name: "HIPKittens GQA Backward", file_name: "hipkittens_attn_gqa_backwards_attn_bkwd_non_causal.cpp", source_project: "HIPKittens", language: "HIP", algorithm: "attention_gqa_backward", hardware: ["MI300X"], notes: "GQA backward"},
  %{name: "HIPKittens GQA Fwd Non-Causal", file_name: "hipkittens_attn_gqa_backwards_attn_fwd_non_causal.cpp", source_project: "HIPKittens", language: "HIP", algorithm: "attention_gqa", hardware: ["MI300X"], notes: "GQA forward non-causal"},
  %{name: "CK Tile FMHA Forward", file_name: "ck_tile_fmha_fmha_fwd.hpp", source_project: "CK Tile", language: "HIP", algorithm: "attention_fmha", hardware: ["MI300X"], notes: "FMHA forward"},
  %{name: "CK Tile FMHA Backward", file_name: "ck_tile_fmha_fmha_bwd.hpp", source_project: "CK Tile", language: "HIP", algorithm: "attention_fmha_backward", hardware: ["MI300X"], notes: "FMHA backward"},
  %{name: "CK Tile FMHA Fwd Example", file_name: "ck_tile_01_fmha_fmha_fwd.cpp", source_project: "CK Tile", language: "HIP", algorithm: "attention_fmha", hardware: ["MI300X"], notes: "FMHA forward example"},
  %{name: "CK Tile FMHA Example Fwd", file_name: "ck_tile_fmha_example_fmha_fwd.cpp", source_project: "CK Tile", language: "HIP", algorithm: "attention_fmha", hardware: ["MI300X"], notes: "FMHA example"},
  %{name: "AOTriton Flash Attn Fwd", file_name: "aotriton_fwd_kernel.py", source_project: "AOTriton", language: "Triton", algorithm: "attention", hardware: ["MI300X"], notes: "Flash attention fwd"},
  %{name: "AOTriton Fwd Inner Loop", file_name: "aotriton_fwd_kernel_inner.py", source_project: "AOTriton", language: "Triton", algorithm: "attention", hardware: ["MI300X"], notes: "Inner loop"},
  %{name: "AOTriton Fused Backward", file_name: "aotriton_bwd_kernel_fuse.py", source_project: "AOTriton", language: "Triton", algorithm: "attention_backward", hardware: ["MI300X"], notes: "Fused backward"},

  # === Attention Prefill ===
  %{name: "FlashMLA SM90 Prefill Sparse", file_name: "flashmla_sm90_prefill_sparse.cuh", source_project: "FlashMLA", language: "CUDA", algorithm: "attention_prefill", hardware: ["H100"], techniques: ["sparse_attention"], notes: "Sparse prefill"},
  %{name: "FlashMLA SM100 Prefill Dense", file_name: "flashmla_sm100_prefill_dense.cuh", source_project: "FlashMLA", language: "CUDA", algorithm: "attention_prefill", hardware: ["B200"], notes: "Blackwell dense prefill"},
  %{name: "FlashMLA SM100 MLA Mainloop", file_name: "flashmla_sm100_mla_mainloop.hpp", source_project: "FlashMLA", language: "CUDA", algorithm: "attention_prefill", hardware: ["B200"], techniques: ["warp_specialization", "TMA"], notes: "TMA warp-specialized mainloop"},
  %{name: "TRT-LLM MLA Chunked Prefill", file_name: "trtllm_mla_chunked_prefill.cu", source_project: "TRT-LLM", language: "CUDA", algorithm: "attention_prefill", hardware: ["H100"], notes: "Chunked prefill"},
  %{name: "SGLang CUTLASS SM100 MLA Device", file_name: "sglang_cutlass_sm100_mla_device.hpp", source_project: "SGLang", language: "CUDA", algorithm: "attention_prefill", hardware: ["B200"], techniques: ["CUTLASS"], notes: "SM100 device API"},
  %{name: "SGLang CUTLASS SM100 MLA Kernel", file_name: "sglang_cutlass_sm100_mla_kernel.hpp", source_project: "SGLang", language: "CUDA", algorithm: "attention_prefill", hardware: ["B200"], techniques: ["warp_specialization", "TMA", "CUTLASS"], notes: "TMA warp-specialized"},

  # === GEMM ===
  %{name: "HIPKittens FP8 GEMM 4-Wave", file_name: "hipkittens_gemm_fp8_4wave.cu", source_project: "HIPKittens", language: "HIP", algorithm: "gemm", hardware: ["MI300X"], techniques: ["FP8", "MFMA"], notes: "FP8 GEMM, 4-wave"},
  %{name: "HIPKittens FP8 GEMM 8-Wave", file_name: "hipkittens_gemm_fp8_8wave.cu", source_project: "HIPKittens", language: "HIP", algorithm: "gemm", hardware: ["MI300X"], techniques: ["FP8", "MFMA"], notes: "FP8 GEMM, 8-wave"},
  %{name: "HIPKittens BF16 GEMM", file_name: "hipkittens_gemm_bf16fp32_256_256_64_32_with16x32.cpp", source_project: "HIPKittens", language: "HIP", algorithm: "gemm", hardware: ["MI300X"], techniques: ["MFMA"], notes: "BF16 GEMM"},
  %{name: "RadeonFlow GEMM Kernel", file_name: "radeonflow_gemm_gemm_kernel.cpp", source_project: "RadeonFlow", language: "HIP", algorithm: "gemm", hardware: ["MI300X"], notes: "GEMM kernel"},
  %{name: "RadeonFlow GEMM Launcher", file_name: "radeonflow_gemm_gemm_launcher.cpp", source_project: "RadeonFlow", language: "HIP", algorithm: "gemm", hardware: ["MI300X"], notes: "GEMM launcher"},
  %{name: "RadeonFlow Transpose GEMM", file_name: "radeonflow_gemm_transpose_kernel.cpp", source_project: "RadeonFlow", language: "HIP", algorithm: "gemm", hardware: ["MI300X"], notes: "Transpose GEMM"},
  %{name: "CK Tile Basic GEMM", file_name: "ck_tile_03_gemm_gemm_basic.cpp", source_project: "CK Tile", language: "HIP", algorithm: "gemm", hardware: ["MI300X"], notes: "Basic GEMM"},
  %{name: "CK Tile Universal GEMM", file_name: "ck_tile_03_gemm_universal_gemm.cpp", source_project: "CK Tile", language: "HIP", algorithm: "gemm", hardware: ["MI300X"], notes: "Universal GEMM"},
  %{name: "HF ROCm Skinny GEMM Core", file_name: "hf_rocm_skinny_gemm_core.cu", source_project: "HF ROCm", language: "HIP", algorithm: "gemm", hardware: ["MI300X"], notes: "Skinny GEMM core"},
  %{name: "HF ROCm Skinny GEMM Kernel", file_name: "hf_rocm_skinny_gemm_skinny_gemm_kernel.cu", source_project: "HF ROCm", language: "HIP", algorithm: "gemm", hardware: ["MI300X"], notes: "Skinny GEMM kernel"},
  %{name: "llama.cpp MMA GEMM", file_name: "llamacpp_mma.cuh", source_project: "llama.cpp", language: "HIP", algorithm: "gemm", hardware: ["MI300X"], techniques: ["MFMA"], notes: "MMA GEMM"},
  %{name: "llama.cpp Quantized GEMM", file_name: "llamacpp_mmq.cuh", source_project: "llama.cpp", language: "HIP", algorithm: "gemm", hardware: ["MI300X"], notes: "Quantized GEMM"},

  # === MoE ===
  %{name: "AITER Triton MoE", file_name: "aiter_triton_moe_op.py", source_project: "AITER", language: "Triton", algorithm: "moe", hardware: ["MI300X"], notes: "MoE operator"},
  %{name: "AITER Triton MoE MXFP4", file_name: "aiter_triton_moe_op_mxfp4.py", source_project: "AITER", language: "Triton", algorithm: "moe", hardware: ["MI300X"], techniques: ["MXFP4"], notes: "MoE with MXFP4"},
  %{name: "RadeonFlow MoE GEMM Pipeline", file_name: "radeonflow_moe_moe_gemm_pipeline_kernel.cpp", source_project: "RadeonFlow", language: "HIP", algorithm: "moe", hardware: ["MI300X"], notes: "MoE GEMM pipeline"},
  %{name: "RadeonFlow MoE Top-K", file_name: "radeonflow_moe_moe_topk_kernel.cpp", source_project: "RadeonFlow", language: "HIP", algorithm: "moe", hardware: ["MI300X"], notes: "MoE top-k routing"},
  %{name: "GPUMode MoE Reference", file_name: "gpumode_amd_moe_reference.py", source_project: "GPUMode", language: "Python", algorithm: "moe", hardware: ["MI300X"], notes: "Competition reference"},
  %{name: "GPUMode MoE MXFP4 Reference", file_name: "gpumode_amd202602_moe-mxfp4_reference.py", source_project: "GPUMode", language: "Python", algorithm: "moe", hardware: ["MI300X"], techniques: ["MXFP4"], notes: "MXFP4 MoE reference"},

  # === Normalization ===
  %{name: "AITER RMSNorm", file_name: "aiter_rmsnorm_kernels.cu", source_project: "AITER", language: "HIP", algorithm: "rmsnorm", hardware: ["MI300X"], notes: "RMSNorm"},
  %{name: "AITER RMSNorm + Quantize", file_name: "aiter_rmsnorm_quant_kernels.cu", source_project: "AITER", language: "HIP", algorithm: "rmsnorm", hardware: ["MI300X"], techniques: ["fused_quantize"], notes: "RMSNorm + quantize fused"},
  %{name: "AITER Triton RMSNorm", file_name: "aiter_triton_rmsnorm.py", source_project: "AITER", language: "Triton", algorithm: "rmsnorm", hardware: ["MI300X"], notes: "RMSNorm Triton"},
  %{name: "HF ROCm Residual RMSNorm", file_name: "hf_rocm_residual_rms_residual_rms_vectorized.cu", source_project: "HF ROCm", language: "HIP", algorithm: "rmsnorm", hardware: ["MI300X"], techniques: ["vectorized_loads"], notes: "Residual + RMSNorm vectorized"},
  %{name: "HIPKittens LayerNorm", file_name: "hipkittens_layernorm_kernel.cpp", source_project: "HIPKittens", language: "HIP", algorithm: "layernorm", hardware: ["MI300X"], notes: "LayerNorm"},

  # === Activation / Misc ===
  %{name: "HF ROCm SwiGLU", file_name: "hf_rocm_swiglu_swiglu_vectorized.cu", source_project: "HF ROCm", language: "HIP", algorithm: "swiglu", hardware: ["MI300X"], techniques: ["vectorized_loads"], notes: "SwiGLU vectorized"},
  %{name: "HIPKittens Rotary Embedding", file_name: "hipkittens_rotary_kernel.cpp", source_project: "HIPKittens", language: "HIP", algorithm: "rotary_embedding", hardware: ["MI300X"], notes: "Rotary embedding"},
  %{name: "AITER Fused Misc Kernels", file_name: "aiter_fused_kernels.cu", source_project: "AITER", language: "HIP", algorithm: "misc_fused", hardware: ["MI300X"], notes: "Fused misc kernels"},

  # === Distributed / Communication ===
  %{name: "GPUMode All-Gather GEMM", file_name: "gpumode_amd_dist_ag-gemm_reference.py", source_project: "GPUMode", language: "Python", algorithm: "distributed_ag_gemm", hardware: ["MI300X"], notes: "All-gather GEMM"},
  %{name: "GPUMode All-to-All", file_name: "gpumode_amd_dist_all2all_reference.py", source_project: "GPUMode", language: "Python", algorithm: "distributed_all2all", hardware: ["MI300X"], notes: "All-to-all"},
  %{name: "GPUMode GEMM Reduce-Scatter", file_name: "gpumode_amd_dist_gemm-rs_reference.py", source_project: "GPUMode", language: "Python", algorithm: "distributed_gemm_rs", hardware: ["MI300X"], notes: "GEMM reduce-scatter"},
  %{name: "gaunernst All-to-All v9", file_name: "gaunernst_all2all_v9.py", source_project: "gaunernst", language: "Python", algorithm: "distributed_all2all", hardware: ["MI300X"], notes: "All-to-all v9"},

  # === FP8 / MXFP4 Matmul ===
  %{name: "GPUMode FP8 Matmul Reference", file_name: "gpumode_amd_fp8-mm_reference.py", source_project: "GPUMode", language: "Python", algorithm: "fp8_matmul", hardware: ["MI300X"], techniques: ["FP8"], notes: "FP8 matmul reference"},
  %{name: "GPUMode FP8 Matmul Template", file_name: "gpumode_amd_fp8-mm_template.py", source_project: "GPUMode", language: "Python", algorithm: "fp8_matmul", hardware: ["MI300X"], techniques: ["FP8"], notes: "FP8 matmul template"},
  %{name: "GPUMode FP8 Matmul HIP Template", file_name: "gpumode_amd_fp8-mm_template-hip.py", source_project: "GPUMode", language: "Python", algorithm: "fp8_matmul", hardware: ["MI300X"], techniques: ["FP8"], notes: "FP8 matmul HIP template"},
  %{name: "GPUMode MXFP4 Matmul Reference", file_name: "gpumode_amd202602_mxfp4-mm_reference.py", source_project: "GPUMode", language: "Python", algorithm: "mxfp4_matmul", hardware: ["MI300X"], techniques: ["MXFP4"], notes: "MXFP4 matmul reference"},
  %{name: "GPUMode MXFP4 Matmul Template", file_name: "gpumode_amd202602_mxfp4-mm_template.py", source_project: "GPUMode", language: "Python", algorithm: "mxfp4_matmul", hardware: ["MI300X"], techniques: ["MXFP4"], notes: "MXFP4 matmul template"},

  # === Documentation / Guides ===
  %{name: "AMDGPU Kernel Optimization Guide", file_name: "nodai_amdgpu_kernel_optimization_guide.md", source_project: "NODAI", language: "docs", algorithm: "optimization_guide", hardware: ["MI300X"], notes: "AMDGPU kernel optimization guide"},
  %{name: "FlashMLA Kernel Deep Dive", file_name: "flashmla_kernel_deep_dive.md", source_project: "FlashMLA", language: "docs", algorithm: "attention_mla_decode", notes: "FlashMLA kernel scheduling deep dive"},
  %{name: "FlashMLA FP8 Sparse Deep Dive", file_name: "flashmla_fp8_sparse_deep_dive.md", source_project: "FlashMLA", language: "docs", algorithm: "attention_mla_decode", techniques: ["FP8", "sparse_attention"], notes: "FP8 sparse kernel details"},
  %{name: "GPUMode MLA Decode README", file_name: "gpumode_amd_mla-decode_README.md", source_project: "GPUMode", language: "docs", algorithm: "attention_mla_decode", hardware: ["MI300X"], notes: "MLA decode competition problem spec"},

  # === Additional kernels from technique cross-references ===
  %{name: "Salykova MFMA Intrinsics Tutorial", file_name: "salykova_mfma_intrinsics.hip", source_project: "salykova", language: "HIP", algorithm: "mfma_tutorial", hardware: ["MI300X", "MI250X"], techniques: ["MFMA"], notes: "MFMA intrinsics tutorial for CDNA3/CDNA4"},
  %{name: "AITER MLA Reduce", file_name: "aiter_mla_reduce.cu", source_project: "AITER", language: "HIP", algorithm: "attention_mla_decode", hardware: ["MI300X"], techniques: ["split_KV"], notes: "Split-KV reduction for MI300X"},
  %{name: "AITER MLA Softmax", file_name: "aiter_mla_softmax.cuh", source_project: "AITER", language: "HIP", algorithm: "attention_mla_decode", hardware: ["MI300X"], techniques: ["online_softmax"], notes: "Online softmax implementation"},
  %{name: "AITER MLA HK Softmax", file_name: "aiter_mla_hk_hk_mla_softmax.cuh", source_project: "AITER", language: "HIP", algorithm: "attention_mla_decode", hardware: ["MI300X"], techniques: ["online_softmax"], notes: "HK online softmax"},
  %{name: "SGLang MLA Forward", file_name: "sglang_forward_mla.py", source_project: "SGLang", language: "Python", algorithm: "attention_mla_decode", techniques: ["weight_absorption"], notes: "Weight absorption reference"},
  %{name: "FlashMLA Reference", file_name: "flashmla_reference.py", source_project: "FlashMLA", language: "Python", algorithm: "attention_mla_decode", techniques: ["weight_absorption"], notes: "MLA algorithm reference"},
  %{name: "AITER Sparse MLA (Triton)", file_name: "aiter_sparse_mla_triton.py", source_project: "AITER", language: "Triton", algorithm: "attention_mla_decode", hardware: ["MI300X"], techniques: ["sparse_attention"], notes: "Sparse attention Triton"},
  %{name: "GPUMode Mixed-MLA Reference", file_name: "gpumode_amd202602_mixed-mla_reference.py", source_project: "GPUMode", language: "Python", algorithm: "attention_mla_decode", hardware: ["MI300X"], notes: "Mixed-MLA competition reference"},
]

for attrs <- kernels do
  %Kernel{}
  |> Kernel.changeset(attrs)
  |> Repo.insert!(on_conflict: :nothing)
end

IO.puts("Seeded #{length(kernels)} kernels")
