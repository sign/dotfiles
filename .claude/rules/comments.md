---
alwaysApply: true
description: Comment policy — prefer self-documenting code
---

## Comment Policy

Comments explain *why*, never *what*. If code needs a comment to explain what it does, refactor the code instead.

### Delete on Sight
- Comments that restate the code
- Commented-out code
- Obvious observations ("increment counter", "return result")

### Leave Alone
- Existing comments in code you're not modifying

### The Only Good Comment
Explains *why* a non-obvious decision was made — a constraint, a workaround reason, a "this looks wrong but is intentional because..."
