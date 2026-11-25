# CLAUDE.md

This repo is a Claude Code **plugin marketplace** (`pixsmith`) of shared skills used across PixSmith projects. It contains no application code.

## Commands

```bash
./scripts/validate.sh        # JSON manifests, marketplace ↔ plugin names, skill frontmatter, `claude plugin validate`
```

Run it after every change.

## Structure

- `.claude-plugin/marketplace.json` lists every plugin. Each `source` is `./plugins/<name>`.
- `plugins/pixsmith-core` holds the skills that apply to any stack. Every other `plugins/pixsmith-<stack>` holds one stack's skills.
- Skills live at `plugins/<plugin>/skills/<skill-name>/SKILL.md`. The frontmatter `name` must equal the folder name.

## Rules

- Follow `plugins/pixsmith-core/skills/new-skill/SKILL.md` when adding or changing skills or plugins.
- Skills must be generic. Repo-specific details (class names, ports, hosts) belong in that repo's CLAUDE.md.
- Never put secrets, hostnames, or personal data in a skill. This repo is consumed from GitHub.
- When a plugin changes, bump its `version` in `plugin.json`.
- A new stack plugin also needs a row in `project-onboarding`'s detection table and in the README's plugin table.
