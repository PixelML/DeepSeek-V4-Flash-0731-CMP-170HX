# Preflight — four-card DeepSeek-V4-Flash-0731 run (pixelml#65)

Every item MUST pass before a four-card run starts. Check each box only
when its condition is verifiably true; a failed item blocks the run.

1. [ ] MUST — pixelml#61 receipt posted (stable writable target + capacity confirmed).
2. [ ] MUST — pixelml#65 is not superseded by another issue or decision.
3. [ ] MUST — branch is current with master (rebased/merged, no drift).
4. [ ] MUST — docs/CHECKPOINT.md reviewed against the Hub API (repo id, pinned revision `7872f01b1d1fe23eabc4c98b48bffcef5a386062`, license, storage bytes).
5. [ ] MUST — local bytes hash-verified 55/55 at the pinned revision (size match alone is not enough; see docs/DOWNLOAD-LANE.md).
6. [ ] MUST — dedup decision recorded: one canonical tree chosen under /library/models; the other kept or removed only after validation per storage policy.
7. [ ] MUST — runtime stack decided: allover326 4-card config or a documented variant (see docs/RUNTIME.md).
8. [ ] MUST — runtime commit/image receipt captured (branch, commit, patches, image id).
9. [ ] MUST — four-card lease granted in pixelml#52.
10. [ ] MUST — power caps set to 180 W on all four cards (nvidia-smi verified before the run).
11. [ ] MUST — cards VRAM-unlocked: 65536 MiB visible per card.
12. [ ] MUST — storage lane status = ready (docs/DOWNLOAD-LANE.md status line no longer BLOCKED).
13. [ ] MUST — no other workloads running on the /library mount.
14. [ ] MUST — benchmarks use the repo harness conventions (bench_decode/bench_prefill as in RESULTS.md; greedy, single-stream, fixed token counts).
15. [ ] MUST — results land in RESULTS.md per evidence rules (labels: measured / inferred / community-reported / untested; no unsupported claims).
