---
name: spec-review
description: >-
  Use when the user runs /spec-review (or /review), or asks to verify the
  current build against its written specification before merging, shipping, or
  marking a feature "done". Triggers on "review against the spec", "does the
  build meet the spec", "is this ready to merge", "check the requirements",
  "find the bugs", or any spec-compliance gate before integration. Scope:
  compares the implementation against specs/<name>.md, exercises it with real
  user scenarios on a running build, and blocks merge until every requirement is
  met with no bugs.
---

# /spec-review — Spec Compliance + Live Bug Gate

## Overview

**A build PASSES only when every requirement in its spec is fully met AND every
real-world scenario runs without bugs. There is no partial pass.** This is a
binary merge gate, not a code-quality opinion. You verify against
`specs/<name>.md` two ways — by reading the implementation AND by running the
build and driving it like a user — then either block it with reproducible fixes
or pass it clean.

**Violating the letter of a requirement is violating the spec.** "Mostly works"
is FAIL. A scenario that throws a console error, crashes, or deviates visually
from the spec is a bug, and a bug is FAIL.

## Step 1 — Locate the spec

- Argument form: `/spec-review <name>` → read `specs/<name>.md`.
- No argument: look in `specs/`. One spec → use it. Several → match to the
  current feature/branch/recent changes; if ambiguous, ask which one.
- Never invent requirements the spec doesn't state, nor drop ones it does.

## Step 2 — Extract requirements

Read the whole spec. Turn it into a numbered checklist of atomic, testable
requirements — functional behavior, edge cases, UI/UX details, acceptance
criteria, constraints, and non-functional requirements. Cite the exact spec
location (heading or line) for each item.

## Step 3 — Derive real-world scenarios

Static reading misses runtime bugs. For each requirement, write concrete
scenarios to actually execute, not just inspect:

- **Happy path** — the intended flow, end to end.
- **Edge / boundary** — empty, max, min, long input, duplicates, zero results.
- **Invalid / error** — bad input, network failure, unauthorized, missing data.
- **State** — loading, empty, error, and success UI states each render correctly.
- **Sequence** — back/refresh/double-submit/rapid clicks; unexpected ordering.

Acceptance criteria in the spec become scripted steps with expected results.

## Step 4 — Run the build and exercise it (don't guess)

Start the build using the project's run method (see the **run** skill) — find
the command in `package.json` scripts, README, or a project run skill — then
drive each scenario through the best available driver. **A requirement is PASS
only with live evidence; "the code looks correct" is not evidence.** (See
superpowers:verification-before-completion.)

Pick the driver by build type and platform:

| Build type | Driver (preferred → fallback) |
|------------|-------------------------------|
| Web app | Claude Preview MCP (`mcp__Claude_Preview__*`: start, click, fill, screenshot, console, network) → Claude-in-Chrome MCP for a real browser → Playwright (`npx playwright`) for scripted repro |
| Mobile — Android | Android emulator (`emulator` + `adb install`/`adb shell input`) to install and drive the app |
| Mobile — iOS (macOS only) | iOS Simulator (`xcrun simctl`) |
| Native desktop (macOS only) | computer-use MCP (`mcp__computer-use__*`); call `request_access` first |
| CLI / API / library | run commands / hit endpoints directly and assert outputs, exit codes, responses |

**Platform awareness — check the OS first.** This matters because drivers
differ:
- **Windows / Linux:** use Preview MCP or Chrome MCP for web, emulator + `adb`
  for Android, direct execution for CLI/API. `computer-use` (Mac desktop
  control) and the iOS Simulator are **not** available — do not rely on them.
- **macOS:** all of the above, **plus** computer-use MCP for native desktop apps
  and `xcrun simctl` for iOS. Prefer computer-use for native/cross-app flows the
  browser tools can't reach.

For every scenario capture evidence: **screenshot, console errors, network
failures, server logs, and exit codes.** Any crash, uncaught error, failed
request, broken flow, or visual deviation from the spec is a logged bug — even
if the static code "looks right".

## Step 5 — Judge each requirement

Mark each: **PASS / FAIL / MISSING / PARTIAL**. MISSING and PARTIAL count as
FAIL. A requirement with a live bug in any of its scenarios is FAIL. For every
non-PASS item record:

- the **exact spec item** it fails,
- expected vs. actual (what the spec requires vs. what the build did),
- **reproduction steps** + evidence (screenshot path, console/network excerpt),
- the **specific fix** needed — concrete enough that `/build` can act on it
  without re-deriving intent.

## Step 6 — Verdict + output

Output, in this order:

1. **VERDICT: PASS or FAIL** — FAIL if even one requirement is non-PASS or any
   scenario surfaced a bug.
2. **Requirement table** — every requirement, spec citation, status, evidence note.
3. **Bugs found** — each with repro steps + captured evidence, tagged to the
   spec item it breaks.
4. **Fixes for /build** (only when FAIL) — a prioritized, numbered list of
   specific fixes, each tagged with the spec item it satisfies. This is the
   handoff `/build` consumes.
5. **One-line summary** (e.g. "12/15 met — 3 bugs, 4 fixes required").

Emit PASS only when 100% of requirements are PASS and zero bugs remain.

## Do not

- Pass with any open FAIL / PARTIAL / MISSING item or unfixed bug "to unblock".
- Judge from code reading alone when the build is runnable — run it.
- Invent requirements the spec doesn't state, or silently drop ones it does.
- Accept "I'll fix it after merge" — this gate runs **before** merge.
- Soften a real deviation or runtime error into a "nit".

## Red flags — STOP, you're about to wrongly PASS

- "It's basically done." / "Close enough." / "Only a small gap."
- "The spec probably didn't mean that literally."
- "I didn't run it, but the code looks correct."
- "That console error is probably harmless."

All mean: **FAIL until the requirement is met and the scenario runs clean.**

| Excuse | Reality |
|--------|---------|
| "Edge case, unlikely" | If the spec lists it, it's a requirement. FAIL until met. |
| "Code looks correct" | Not evidence. Run the scenario, then judge. |
| "Couldn't run it easily" | Find the run command or emulator. Skipping = unverified = FAIL. |
| "Minor cosmetic diff" | Spec'd UI details are requirements, not nits. |
| "Harmless console error" | Uncaught errors are bugs until proven otherwise. |
| "Pass now, fix later" | This gate exists to prevent exactly that. |
