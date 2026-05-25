# superman:incremental-impl

**Goal**: Prevent large untraceable code changes by enforcing an incremental implementation strategy, ensuring every commit is the smallest understandable and revertible unit.

**Trigger**: Automatically followed during each task implementation in the EXECUTE phase. Acts as a discipline layer on top of superman:tdd and superman:subagent-dev.

---

## Core Rules

**No single commit should exceed any of the following thresholds:**
- One feature unit (one function, one interface, one config entry)
- Time span: no more than 30 minutes of work
- Lines of code: no more than 100 lines added/modified (excluding purely mechanical code)

Exceeding any threshold → split into smaller steps.

## Implementation Order

**Always implement from the inside out:**

1. Core data structures / type definitions
2. Pure functions / utility functions (no side effects)
3. Core business logic
4. Side effect layer (I/O, network, database)
5. Interface layer (API, UI, CLI)
6. Integration tests

**Order must not be skipped:** Do not write the interface layer without inner-layer implementations.

## Incremental Commit Standards

Each commit must:
1. Compile independently (not depend on uncommitted code)
2. Pass tests (gated by `superman:tdd`)
3. Have a clear description (commit message explains what and why)

Good incremental commit examples:
- `feat: add User.validate() method with email format check`
- `feat: add POST /users endpoint using User.validate()`

Bad large-batch commit example:
- `feat: add complete user management system`

## Large Task Decomposition Method

If a task looks too large, use this decomposition strategy:

1. **List all required data structures** → each data structure is one commit
2. **List all interface/function signatures** → each function is one commit (write stubs first)
3. **Implement functions one by one** → paired with TDD, commit after each function passes its test
4. **Integration** → connect functions, commit integration code

## When Large Commits Are Allowed

The following cases may exceed 100 lines:
- Auto-generated code (e.g., schema migrations, protobuf generation)
- Pure formatting (`prettier`, `gofmt`, etc.)
- Boilerplate that copies an existing pattern (state this in the commit message)
