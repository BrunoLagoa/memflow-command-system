# First 10 minutes with Memflow

> From install to your first real session — no detours.

---

## 1. Install (2 min)

**macOS / Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh | bash -s -- install
```

**Windows (PowerShell)**

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.ps1 -OutFile $env:TEMP\install.ps1; & $env:TEMP\install.ps1 install"
```

The installer asks 3 questions: OS, platform (OpenCode / VSCode / Cursor / Claude Code), and scope (global or local). Answer and it's done.

**Verify:**

```bash
bash scripts/install.sh check
```

---

## 2. Initialize memory in your project (1 min)

Open your project in the AI tool (OpenCode, Cursor, VSCode, or Claude Code). Run:

```text
/memory-init
```

This creates `.agents/memory/` with four files:

| File | Purpose |
|------|---------|
| `memory.md` | Project identity — tech stack, structure, business rules |
| `decisions.md` | Persistent decisions with scores — reused across sessions |
| `session-memory.md` | Temporary state for the current session only |
| `quality-metrics.md` | History of sessions, approval rates, rework trends |

The AI will ask confirmation before writing. Say yes.

---

## 3. Your first session (5 min)

Every session starts with `/context` and `/workflow`. That's the core habit.

### Step 1 — Load context

```text
/context
```

Output tells you what memory was loaded, which decisions exist, and whether the system is ready. On the first run, memory will be minimal — that's expected.

### Step 2 — State your goal and get a decision

```text
/workflow

I want to add a login page with email and password to the app.
```

The `/workflow` will:
- Classify complexity, impact, and risk
- Check if there are existing decisions that apply
- Decide whether exploration (`/brainstorm`) is needed
- Choose the execution path: direct → `/execute`, planned → `/plan` first, or explore → `/brainstorm`

Follow whatever it says next.

### Step 3 — Execute

If `/workflow` routes to **direct execution**:

```text
/execute
```

If it routes to **plan first**:

```text
/plan
/execute
```

If it routes to **exploration**:

```text
/brainstorm
```

Then follow the brainstorm to `/spec` or `/plan`, then `/execute`.

### Step 4 — Validate

```text
/review
```

For code-heavy changes:

```text
/review-code
```

For critical changes (authentication, billing, security):

```text
/review-enforce-rules
```

### Step 5 — Save decisions

At the end of any session worth remembering:

```text
/memory-save
```

This records decisions and updates your quality metrics. The next session will find them in `decisions.md` and apply them automatically.

---

## 4. The mental model (30 sec)

Memflow is not a coding assistant. It's a structured process:

```
Understand → Decide → Plan → Implement → Validate → Remember
/context  /workflow /plan  /execute   /review   /memory-save
```

`/workflow` is the brain. It decides what to do next. Never skip it.

`decisions.md` is the memory. It gets smarter the more you use it.

---

## 5. Common flows by scenario

| Scenario | Commands |
|----------|----------|
| New simple feature | `/context` → `/workflow` → `/execute` → `/review` |
| New medium feature | `/context` → `/workflow` → `/plan` → `/execute` → `/review` → `/memory-save` |
| Complex feature (unclear) | `/context` → `/workflow` → `/brainstorm` → `/spec` → `/plan` → `/execute` → `/review` |
| Bug fix | `/context` → `/workflow` → `/debug` → `/execute` → `/review-code` |
| Refactor | `/context` → `/workflow` → `/plan` → `/refactor` → `/review` |

---

## 6. End-to-end examples

Real scenarios with full command flows and sample outputs:

- [Example 01 — New feature](examples/01-nova-feature.md) — dark mode with active memory
- [Example 02 — Bug fix](examples/02-correcao-bug.md) — silent login failure
- [Example 03 — Complex feature](examples/03-feature-complexa-com-brainstorm.md) — notification system with brainstorm
- [Example 04 — Memory and `/memory-save`](examples/04-memoria-e-memory-save.md) — when to save, reinforce, or skip

---

## Useful commands

```bash
# Check installation status
bash scripts/install.sh check

# Update to latest version
bash scripts/install.sh update

# View all command specs
ls src/*.md
```

---

## What's next

- [`SDLC.md`](SDLC.md) — the full methodology
- [`src/model-policy.md`](../src/model-policy.md) — how models are selected per task
- [`INSTALL.md`](INSTALL.md) — advanced install options (local scope, multi-project)
