# Runtime stacks for DeepSeek-V4-Flash-0731 on CMP 170HX (SM80)

Status as of **2026-08-30**. Target hardware: NVIDIA CMP 170HX — GA100
silicon, SM80, 64 GB HBM2e per card, PCIe Gen2 x4, no P2P, no FP4 tensor
cores; power-capped at 180 W in our baseline (matches README hardware
section, nvidia-smi verified). Labels: **measured** / **inferred** /
**community-reported** / **untested**.

## Status

| stack | status on CMP 170HX (SM80) | evidence label | source |
|---|---|---|---|
| vLLM main | DeepseekV4ForCausalLM registered; PP column "supported"; SM80 serving needs patches (both SM80 PRs still open) | inferred from registry/docs; PR states measured via API | vLLM main: model registry, supported_models.md; PRs #38476, #46994 |
| vLLM + allover326 stack | working on SM80: 3-card measured in this repo (master); 4-card config community-reported, our 4-card run untested | measured (3-card, this repo) / community-reported (4-card) | this repo RESULTS.md + launch-dsv4-3card.sh; allover326/deepseek-v4-cmp170hx |
| SGLang main | DeepseekV4ForCausalLM registered; no SM80 evidence; DSPARK spec-decode crash issue open | inferred from registry/docs; issue community-reported | SGLang main: python/sglang/srt/models/deepseek_v4{,_dspark,_nextn}.py; issue #35324 |
| Transformers | registered | no local serve evidence; SM80 untested | upstream repo docs — inferred; local status untested |

## vLLM on SM80

**Registration (vLLM main).** `DeepseekV4ForCausalLM` is in the model
registry and listed in supported_models.md with PP marked supported; the
implementation lives under `vllm/models/deepseek_v4/` with `nvidia/`,
`amd/`, and `xpu/` subpackages [inferred from registry/docs]. Header comments
on several `deepseek_v4` kernels in vLLM main reference `cmp170hx` kernel
targets [community-reported via upstream code comments; not local-verified].

**The two SM80 blockers.** Both PRs are still open, NOT merged, as of
2026-08-30 [measured via API]:

- [vllm-project/vllm#38476](https://github.com/vllm-project/vllm/pull/38476) —
  TRITON_MLA_SPARSE backend for SM8x
- [vllm-project/vllm#46994](https://github.com/vllm-project/vllm/pull/46994) —
  MTP (DSpark) speculative decoding under pipeline parallelism

DSPARK spec decode under PP is not supported in stock vLLM; the patches are
required [community-reported].

**The working stack** [community-reported; allover326/deepseek-v4-cmp170hx]:

- vLLM from haosdent/vllm branch `dsv4-flash-a100` at commit `c3046d1`
  (recoverable from upstream after force-push via tarball; see
  patches/README.md in that repo), plus the repo's 5 patches
- full source build with `TORCH_CUDA_ARCH_LIST=8.0`
- recommended over the older `f8ea5bb` pin: it works but is superseded, with
  +7% decode measured by the maintainer
- note: the "vLLM 0.26.0 + PRs 38476 + 46994 + 16 skew fixes
  (vllm-dsa-mtp-sm80)" compose is the GLM-family variant; the DSV4 patches
  live on the haosdent branch — use the allover326
  deepseek-v4-cmp170hx path for DSV4

**3-card baseline, measured in this repo (master).** PP=3
(`VLLM_PP_LAYER_PARTITION=15,15,13`), DSpark k=5, kv cache fp8, block-size
256, gpu-memory-utilization 0.95, maxlen 16384 → **83.3 tok/s aggregate
decode** and **2965 tok/s prefill** at 5.4k context; boot is ~22 min shard
load from NFS plus ~7 min CUDA graph capture [measured]. Config:
[launch-dsv4-3card.sh](../launch-dsv4-3card.sh); numbers:
[RESULTS.md](../RESULTS.md).

**4-card reference config** [community-reported; allover326]. PP=4, kv fp8,
block-size 256, maxlen 32768, gpu-memory-utilization 0.85,
max-num-batched-tokens 2048, max-num-seqs 8, DSpark k=5 exactly (k<5
garbles output; k=7 is worse), `LOGITS_ROW_CHUNK=64` for long accumulating
chat (128 OK for one-shot; 128 crashed around 718–733k accumulated
context), `--tokenizer-mode deepseek_v4`,
`--no-enable-flashinfer-autotune`, `--trust-remote-code`. Maintainer
numbers: 98.1 tok/s plain decode, DSpark 1.93x speedup → claimed ~98 tok/s
aggregate decode with DSpark, ~5300 tok/s prefill, and 1,047,736 verified
one-shot context (retrieval degrades before the crash).

**Four-card status on our four-card node: UNTESTED** — no four-card run has
been executed under this effort yet [untested].

**Known traps**

- Full source build REQUIRED — a precompiled vLLM image
  (`VLLM_USE_PRECOMPILED`) silently ships without `vllm._C` and fails at
  graph capture (`fused_deepseek_v4_qnorm_rope_kv_rope_quant_insert_out`)
  [measured; this repo master]
- DSpark k MUST be exactly 5 (>= dspark_block_size 5): k<5 garbles, k=7 is
  worse [community-reported]
- `LOGITS_ROW_CHUNK=64` for accumulating chat; 128 only for one-shot
  [community-reported]
- block-size 256 in both the measured 3-card config and the community
  4-card config [measured / community-reported]
- PP over TP on PCIe Gen2 x4 with no P2P (rationale below)

## SGLang on SM80

`DeepseekV4ForCausalLM` is registered in SGLang main
(`python/sglang/srt/models/deepseek_v4.py`, plus `deepseek_v4_dspark.py`
and `deepseek_v4_nextn.py`); the official README shows an SGLang serve
example (fp8 checkpoint, `flashinfer_mxfp4` runner, DSPARK spec) and
DeepSeek-V4 is listed in the SGLang docs [inferred from registry/docs].
There is NO SM80 / CMP 170HX evidence for SGLang, and
[SGLang issue #35324](https://github.com/sgl-project/sglang/issues/35324)
(opened 2026-08-18) reports intermittent CUDA device-side crashes with
DSPARK speculative decoding on DeepSeek-V4-Flash-0731
[community-reported]. **Treat SGLang as untested on this hardware**
[untested].

## Why PP, not TP, on CMP 170HX

The card sits on PCIe Gen2 x4 with no P2P, so tensor parallelism pays the
interconnect on every layer; the community numbers for this hardware show
pipeline parallel beating TP by ~6.6x on prefill and ~2x on decode
[community-reported]. Our own measured 3-card baseline also uses PP=3 with
an explicit layer partition [measured]. PP is therefore the default for any
new run; deviations MUST be documented as variants with their own evidence
labels.
