# Checkpoint: deepseek-ai/DeepSeek-V4-Flash-0731

Canonical checkpoint for pixelml#65 prep (four-card CMP 170HX baseline).
All facts verified against the Hub API and local file stats on **2026-08-30**
unless labeled otherwise. Claim labels used throughout: **measured** /
**inferred** / **community-reported** / **untested**.

## Identity

| item | detail |
|---|---|
| repo id | deepseek-ai/DeepSeek-V4-Flash-0731 (official, ungated, public) — measured (Hub API) |
| pinned revision | `7872f01b1d1fe23eabc4c98b48bffcef5a386062` (current main; lastModified 2026-08-01T03:07:41Z) — measured (Hub API) |
| license | MIT (cardData.license, LICENSE file in repo, README badge) — measured (Hub API) |
| architecture family | DeepseekV4ForCausalLM, model_type `deepseek_v4` — measured (config.json) |
| architecture details | vocab 129280; 43 layers + 3 hash layers; 256 routed experts + 1 shared, top-6 routing; hidden 4096; head_dim 512; MoE intermediate 2048; DSpark draft layers 40,41,42 — measured (config.json) |
| parameter total | 304,180,418,494 (~304B total params, HF-reported safetensors total) — measured (Hub API) |
| quantization | fp8 e4m3 dynamic, weight_block_size [128,128], scale_fmt ue8m0; expert_dtype fp4 — measured (config.json) |
| storage bytes | HF usedStorage 166,888,735,421 bytes (includes non-weight repo files); measured local combined total 166,898,516,534 bytes — measured (Hub API + local stat) |
| shard count | 48 safetensors shards, `model-00001-of-00048` .. `model-00048-of-00048` — measured (Hub API + local stat) |
| context length | max_position 1,048,576 via YaRN factor 16 (original 65,536) — measured (config.json) |
| spec-decode block size | dspark_block_size 5 (num_nextn_predict_layers 1) — measured (config.json) |

## File inventory at pinned revision

55 tracked files verified **by size** against the Hub API at the pinned
revision: all match exactly, none missing — measured (Hub API per-file sizes
+ local stat, 2026-08-30). The 48 safetensors shards are
`model-00001-of-00048.safetensors` through `model-00048-of-00048.safetensors`.

The 7 non-shard files (all size-verified at the pinned revision — measured):

| item | detail |
|---|---|
| model.safetensors.index.json | shard index; byte-identical between the two local trees — measured |
| config.json | architecture + quantization config (source of the identity rows above) — measured |
| generation_config.json | generation defaults — measured |
| tokenizer.json | tokenizer data — measured |
| tokenizer_config.json | tokenizer settings — measured |
| LICENSE | MIT license text — measured |
| README.md | model card — measured |

## Hash status

**Untested.** No sha256 (or other digest) verification has been performed on
any local file. Per-file size matching against the Hub API is complete
(measured), but a reuse declaration ("these bytes are the checkpoint") MUST
NOT be made until all 55 files hash-verify. Hash verification is a hard gate
in [DOWNLOAD-LANE.md](DOWNLOAD-LANE.md) and [PREFLIGHT.md](PREFLIGHT.md).

## Local copies

| item | detail |
|---|---|
| tree A | /library/models/deepseek-ai/DeepSeek-V4-Flash-0731 — byte-complete by size at the pinned revision — measured |
| tree B | /library/models/dsv4/DeepSeek-V4-Flash-0731 — byte-complete by size at the pinned revision — measured |
| combined bytes | 166,898,516,534 across both trees; all 55 tracked files match Hub per-file sizes exactly — measured |
| index.json | byte-identical between tree A and tree B — measured |
| hf cache ref | /library/models/dsv4/hf/hub/models--deepseek-ai--DeepSeek-V4-Flash-0731/refs/main resolves to the pinned sha — measured |
| dedup decision | pending pixelml#61 storage receipt (blocked; see DOWNLOAD-LANE.md) — untested |
| hashes | pending; required before any reuse declaration — untested |

Hub reachability probe (feeds the download lane): a safetensors header
range-request probe on shard 1 returned HTTP 302 to the CDN with
`accept-ranges: bytes`, and `x-repo-commit` echoed the pinned sha — measured
(2026-08-30).
