# superman:brainstorming

**Goal**: Clarify requirements through structured dialogue, produce a user-confirmed understanding of requirements, and write it to `.superman/context/requirements.md`.

**Trigger**: After size-classify completes for an L/M requirement, invoke first in the DEFINE phase.

---

## Execution Flow

This skill combines the Superpowers brainstorming framework with Agent Skills idea-refine (5 questions) and interview-me (interview) modes.

### Phase 1: Context Capture (write immediately)

After the user describes the requirement, **immediately** append the raw text to `.superman/context/requirements.md`:

```
## Requirement Record [{ISO timestamp}]

**User's words:**
> {exact user description, verbatim, no paraphrasing}

**AI understanding summary:** {one sentence}
```

### Phase 2: 5-Question Deep Dive (Agent Skills idea-refine)

Ask one question at a time, wait for the answer before asking the next.

**WRITE-FIRST protocol (mandatory for each Q&A round):**
1. Receive user's answer.
2. **IMMEDIATELY call Write/Edit to append the answer to `requirements.md` — this MUST be the first tool call of the response turn.**
3. Only after the Write succeeds, ask the next question.

Never batch-write multiple answers at the end of Phase 2. Each answer must be on disk before the next question is asked, so session compression cannot lose it.

Questions:
1. **Goal**: After this change is done, whose problem gets solved and how?
2. **Success criteria**: How do we know it's done well? What can be tested or measured?
3. **Constraints**: What must not be done (technical limits, timeline, compatibility)?
4. **Scope**: What is included this time, and what is explicitly excluded?
5. **Risks**: What is most likely to go wrong?

### Phase 3: Requirements Confirmation

Show the user a cleaned-up summary of the requirements and ask for confirmation. If confirmed, continue; if not, return to Phase 2.

### Phase 4: Hand Off

Invoke `superman:propose` to create the change proposal directory and spec draft.
