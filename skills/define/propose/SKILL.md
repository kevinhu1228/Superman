# superman:propose

**Goal**: Create a structured change proposal, generating `proposal.md` and a `spec.md` draft under `.superman/phases/define/`.

**Trigger**: Automatically invoked after `superman:brainstorming` confirms requirements (M/L level). M Lite only generates tasks.md and skips spec.md.

---

## Execution Steps

1. Create the directory if it does not exist:

```
mkdir -p .superman/phases/define
```

2. Generate `.superman/phases/define/proposal.md`:

```
# Change Proposal

**Proposed at:** {ISO timestamp}
**Requirement level:** {S/M/L}
**Status:** Draft

## Goal

{one-sentence goal extracted from requirements.md}

## Scope

**In scope:**
- {extracted from requirements confirmation}

**Out of scope:**
- {extracted from requirements confirmation}

## Success Criteria

{extracted from brainstorming Phase 2 Q2}

## Risks

{extracted from brainstorming Phase 2 Q5}
```

3. For L-level requirements, also generate `.superman/phases/define/spec.md` (full technical spec including architecture, interfaces, and data model)

4. Generate `.superman/phases/define/tasks.md` task list (all levels):

```
# Task List

**Source:** proposal.md
**Status:** Pending

- [ ] Task 1: {specific task description}
- [ ] Task 2: {specific task description}
```

5. Show the user proposal.md and proceed to `superman:writing-plans` after confirmation
