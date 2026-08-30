# Download lane — DeepSeek-V4-Flash-0731 weights

Status: **BLOCKED on pixelml#61** — no stable writable/capacity receipt has
posted yet. Downloads remain FORBIDDEN until that receipt lands.
(as of 2026-08-30, lane creation date)

Trigger condition: this lane opens ONLY when the pixelml#61 receipt posts a
stable writable target with confirmed capacity. On trigger: edit the status
line above, then rerun [PREFLIGHT.md](PREFLIGHT.md).

## Contract

- **Single lane.** One resumable transfer at a time; no parallel mirror
  jobs. MUST NOT start a second lane while one is active.
- **Target scope.** Writes MUST go to /library/models ONLY. NEVER the guest
  root; NEVER /home/ubuntu/WIP.
- **Reuse complete bytes first.** Both local trees
  (/library/models/deepseek-ai/DeepSeek-V4-Flash-0731 and
  /library/models/dsv4/DeepSeek-V4-Flash-0731) are byte-complete by size at
  the pinned revision [measured; see CHECKPOINT.md]. If hashes pass, the
  expected download is zero bytes [inferred].
- **Hash-verify all 55 files** before declaring any tree reusable: per-file
  size + sha256 (the Hub exposes sha256 for LFS/xet objects via metadata).
  Size match alone is NOT sufficient for a reuse declaration [untested
  until done].
- **Deduplicate the two trees.** They are identical by size inventory
  [measured]. Pick ONE canonical directory; keep the other, or remove it
  only after validation and per storage policy. The dedup decision MUST be
  recorded before any four-card run.
- **Root free-space gate.** Check root free space before AND after model
  work; MUST NOT begin if <=10% free.
- **Pause rule.** Pause the lane immediately if storage I/O affects an
  active benchmark on the /library mount; resume only after the benchmark
  completes.
- **Pinned revision.** Any fetch MUST pin
  `7872f01b1d1fe23eabc4c98b48bffcef5a386062` [measured]. Do not fetch a
  moving main.

Hub reachability for resume: a range-request probe on shard 1 returned HTTP
302 to the CDN with `accept-ranges: bytes` and `x-repo-commit` echoing the
pinned sha [measured, 2026-08-30], so resumable range transfer is supported.

## Resume commands sketch

```bash
REV=7872f01b1d1fe23eabc4c98b48bffcef5a386062

# (a) fill ONLY missing bytes, into the canonical tree under /library/models
#     (single lane; both paths below resume partial files — pick ONE)
#     option 1: enable hf_transfer for the client (fast resumable lane)
#     option 2: plain resume, no extra tooling
huggingface-cli download deepseek-ai/DeepSeek-V4-Flash-0731 --revision "$REV"

# (b) verify all 55 tracked files: per-file size + sha256
#     (Hub exposes sha256 for LFS/xet objects via metadata)

# (c) update this lane's status line, record the dedup decision,
#     rerun docs/PREFLIGHT.md
```

## Post-receipt update step

When the pixelml#61 receipt posts: edit the status line at the top of this
document, rerun [PREFLIGHT.md](PREFLIGHT.md), and only then start the lane
under the contract above.
