---
globs: ["*.ts", "*.tsx", "*.js", "*.jsx", "*.py", "*.html", "*.go", "*css", "*.scss""]
alwaysApply: true
description: Comment policy
---

## Comment Policy

### Unacceptable Comments
- Comments that repeat what code does
- Commented-out code (delete it)
- Obvious comments ("increment counter")
- Comments instead of good naming

### Principle
Code should be self-documenting. If you need a comment to explain WHAT the code does, consider refactoring to make it clearer.

You should not remove any unrelated comments in existing code. Only add comments when modifying code or adding new code.
