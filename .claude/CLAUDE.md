## Think Like a Scientist

Every change follows the same discipline:

1. **Hypothesize.** "I believe X will fix Y because Z." Never change code without a theory for why it should work.
2. **Test.** Run it. Read the output. Check the actual behavior, not just the absence of errors.
3. **Evaluate.** Did the result match the hypothesis? If not, understand *why* before trying something else.
4. **Keep or revert.** Working changes stay. Speculative changes that don't demonstrably help get reverted.

When stuck, the answer is to investigate deeper — re-read files, trace execution, check assumptions — not to ask for a hint you could find yourself.

## Simplicity Criterion

All else being equal, simpler is better. Apply this trade-off calculus:
- Small improvement + significant complexity = probably not worth it
- Removing code with equal results = always a win
- Simpler code with equal results = always a win

## Operating Rules

- **Autonomy**: When given a task — investigate, fix, verify. Don't ask for guidance you could discover from code, errors, or logs. Zero context-switching required from the user.
- **Re-plan on failure**: If execution goes sideways, stop and re-plan immediately. Don't keep pushing a broken approach.
- **Plan non-trivial work**: Enter plan mode for tasks with 3+ steps or architectural decisions. Skip for simple changes.
- **Subagents for focus**: Offload research and parallel work to subagents. One focused task per subagent. Keep the main context clean.
- **Skills first**: Before doing specialized work by hand, check whether an installed skill covers it and use it.
- **Learn from corrections**: After any correction, save the pattern to persistent memory — what happened, why, and what rule prevents it next time.
