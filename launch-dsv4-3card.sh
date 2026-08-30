#!/usr/bin/env bash
# allover326/deepseek-v4-cmp170hx best config, adapted to 3 cards per README:
# PP=3, VLLM_PP_LAYER_PARTITION=15,15,13, DSpark speculative on, 180 W caps.
set -euo pipefail
IMG="${DSV4_IMG:-dsv4-a100:full}"
R="/home/ubuntu/repos/dsv4-vllm/vllm"
MODEL="/library/models/deepseek-ai/DeepSeek-V4-Flash-0731"
MAXLEN="${DSV4_MAXLEN:-32768}"
ROW_CHUNK="${DSV4_ROW_CHUNK:-64}"
GPU_UTIL="${DSV4_GPU_UTIL:-0.85}"
SPEC='--speculative-config {"method":"dspark","num_speculative_tokens":5}'

docker stop -t 60 dsv4-a100 >/dev/null 2>&1 || true
docker rm dsv4-a100 >/dev/null 2>&1 || true

MOUNTS=""
for f in config/speculative.py \
         v1/worker/gpu/pp_utils.py \
         v1/worker/gpu/model_runner.py \
         v1/worker/gpu/spec_decode/dspark/utils.py \
         model_executor/layers/sparse_attn_indexer.py; do
  MOUNTS="$MOUNTS -v $R/$f:/vllm/vllm/$f:ro"
done

# 3-card PP partition: last rank carries lm_head + DSpark drafter
docker run -d --name dsv4-a100 --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=0,1,2 \
  -e HF_HUB_OFFLINE=1 -e VLLM_WORKER_MULTIPROC_METHOD=spawn \
  -e VLLM_PP_LAYER_PARTITION=15,15,13 \
  -e DSV4_LOGITS_ROW_CHUNK="$ROW_CHUNK" \
  -v "$MODEL":/model:ro \
  $MOUNTS \
  --shm-size=16g -p 8098:8000 \
  "$IMG" vllm serve /model --served-model-name dsv4s \
  --pipeline-parallel-size 3 --kv-cache-dtype fp8 --block-size 256 \
  --max-model-len "$MAXLEN" --max-num-batched-tokens 2048 --trust-remote-code \
  --gpu-memory-utilization "$GPU_UTIL" --max-num-seqs 8 \
  --no-enable-flashinfer-autotune --tokenizer-mode deepseek_v4 \
  $SPEC
echo "launched dsv4-a100 on :8098 (PP3, partition 15,15,13, maxlen $MAXLEN, spec dspark k=5)"
