---
globs: ["**/*.py", "**/*.md"]
alwaysApply: true
description: Performance Benchmarking Policy
---

## Benchmark Policy

When asked to **benchmark** something (a function, module, pipeline, etc.), follow a simple, end-to-end improvement loop.

### Core Loop
1. **Correctness first**
   - Run the existing tests.
   - Do not optimize failing or broken code.

2. **Establish a baseline**
   - Write and run a benchmark that represents real usage.
   - Record baseline performance.

3. **Profile and reason**
   - Identify where time or resources are actually spent.
   - Form a concrete hypothesis for improvement.

4. **Improve**
   - Implement focused changes.
   - Keep behavior identical unless explicitly agreed otherwise.
   - Keep code clean and readable.

5. **Re-benchmark**
   - Run the same benchmark again.
   - Verify that performance improved beyond noise.

6. **Validate**
   - Ensure tests still pass.
   - Run `ruff check .` and `pytest` before finishing.

7. **Document**
   - Write a short Markdown report describing:
     - What was benchmarked
     - What was changed
     - What improved (or didn’t), with numbers

### Principles
- Measure before optimizing.
- Prefer small, reversible diffs.
- Never sacrifice correctness for speed.
- Optimize for clarity as well as performance.
- If performance doesn’t improve, revert and explain why.
