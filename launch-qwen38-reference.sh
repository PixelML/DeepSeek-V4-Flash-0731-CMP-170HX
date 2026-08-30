#!/usr/bin/env bash
# v9-equivalent launch: lued/Qwen3.8-27B-INT8-W8A16-MTP + DFlash2, GPU 0 only.
set -euo pipefail
cd ~/repos/qwen-serving
export HF_HOME=/models/hf
export VLLM_NO_USAGE_STATS=1 DO_NOT_TRACK=1 FLASHINFER_DISABLE_VERSION_CHECK=1
export VLLM_API_KEY=qwen38-bench-20260829
export CUDA_VISIBLE_DEVICES=0
SPEC=dflash2 CTX=fast MAX_SEQS=1 DFLASH_TOKENS=7 PORT=18020 \
  VLLM_V2_CUDAGRAPH_MEM_MIB=1400 KV_MEM=5583457484 \
  MODEL=/library/models/qwen38/bench-2026-08-29/Qwen3.8-27B-INT8-W8A16-MTP \
  DRAFT=/library/models/qwen38/bench-2026-08-29/Qwen3.8-27B-DFlash2-W4A16 \
  bash single-user/start_qwen.sh
