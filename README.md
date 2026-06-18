# claude-delivery-pipeline

A set of [Claude Code](https://claude.com/claude-code) skills that take a feature
from **idea → plan → hardened plan → build → verified build**, on one prompt.

```
specs/<name>.md ─▶ writing-plans ─▶ plan-optimizer ─▶ executing-plans ─▶ spec-review
                                                            ▲                  │
                                                            └──FAIL: fixes─────┘   PASS ─▶ done
```

The `autopilot` skill orchestrates the whole chain and loops the build↔review
step until the spec gate passes (or a round cap is hit). Its hard rules:
**spec-review PASS is the only successful exit — it never fakes a pass and never
auto-merges.**

## Skills in this repo

| Skill | What it does | Author |
|-------|--------------|--------|
| **autopilot** | Orchestrates `writing-plans → plan-optimizer → executing-plans → spec-review`, looping build↔review until the gate passes. | this repo (MIT) |
| **spec-review** | Binary merge gate: checks the build against `specs/<name>.md` requirement-by-requirement **and runs real scenarios on a running build** (Preview/Chrome MCP for web, Android emulator; on macOS also computer-use for native apps + iOS simulator). PASS only when every requirement is met with zero bugs; emits a "Fixes for /build" handoff on FAIL. | this repo (MIT) |
| **plan-optimizer** | Iteratively scores a plan against a rubric, critiques it, and rewrites until the score plateaus. | [Sean Geng](https://github.com/seangeng/skills) (MIT) — idea by [@goodalexander](https://x.com/goodalexander) |

## Requirements

These skills are instructions, not code — they're cross-platform (Windows /
macOS / Linux). But the pipeline depends on a few things being present on the
machine you install them on:

- **Claude Code.**
- **The `superpowers` plugin** — `autopilot` invokes its `writing-plans` and
  `executing-plans` skills. Without it, those phases of the chain won't run.
  See [obra/superpowers](https://github.com/obra/superpowers).
- **Runtime tooling for `spec-review`**, since it *runs* the build: Node and/or
  the relevant toolchain for your project, a browser or the Claude Preview MCP
  for web apps, the Android emulator for Android, etc.
- **macOS bonus:** `spec-review` automatically unlocks the computer-use MCP
  (native desktop apps) and the iOS Simulator (`xcrun simctl`) — drivers not
  available on Windows.

## Install

Clone the repo, then run the installer for your OS. It copies each skill into
your Claude Code skills directory (`~/.claude/skills/` on macOS/Linux,
`%USERPROFILE%\.claude\skills\` on Windows).

**macOS / Linux:**
```bash
git clone https://github.com/allesandroya/claude-delivery-pipeline.git
cd claude-delivery-pipeline
./install.sh
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/allesandroya/claude-delivery-pipeline.git
cd claude-delivery-pipeline
./install.ps1
```

Or just copy the folders in `skills/` into your `~/.claude/skills/` directory by
hand. **Restart Claude Code afterward** so it loads the new skills.

## Usage

- `/autopilot <feature request>` — run the whole pipeline end to end.
- `/spec-review <name>` — gate an existing build against `specs/<name>.md`.
- `/plan-optimizer` — harden any plan on its own.

`autopilot` writes a `specs/<name>.md` first if one doesn't exist — that file is
the source of truth the gate checks against.

## License

This repo is MIT licensed (see [LICENSE](LICENSE)) for the skills authored here
(`autopilot`, `spec-review`). The bundled `plan-optimizer` skill is © Sean Geng,
also MIT — its original license is preserved at
[`skills/plan-optimizer/LICENSE`](skills/plan-optimizer/LICENSE). All credit for
`plan-optimizer` goes to [Sean Geng](https://github.com/seangeng/skills) and the
original idea to [@goodalexander](https://x.com/goodalexander).
