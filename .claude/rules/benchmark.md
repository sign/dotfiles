---
alwaysApply: true
description: Benchmark policy — hypothesis-driven performance optimization
---

## Benchmark Policy

When asked to benchmark, follow a scientific optimization loop.

### The Loop

1. **Verify correctness.** Run existing tests. Never optimize broken code.
2. **Establish baseline.** Write a benchmark representing real usage. Record numbers.
3. **Hypothesize.** Identify where time/resources are spent. Form a concrete prediction: "Changing X should improve Y because Z."
4. **Change one thing.** Implement a focused change. Keep behavior identical.
5. **Re-measure.** Run the same benchmark. Did it improve beyond noise?
6. **Keep or revert.** Improvement confirmed → keep. No improvement → revert and explain why.
7. **Validate.** Tests still pass. `ruff check .` and `pytest` clean.
8. **Report.** Short summary: what was benchmarked, what changed, what improved (with numbers).

### Principles
- Measure before optimizing. Always.
- One variable at a time. Otherwise you can’t attribute the result.
- Never sacrifice correctness for speed.
- If performance doesn’t improve, the honest answer is to revert — not to keep the change "just in case."
