---
name: new-skill
description: Add a new skill (or a new stack plugin) to the PixSmith.Claude skills repo. Use when the user says "make this a skill", "remember how we do X across projects", "add a skill for <stack>", or when a convention keeps being re-explained in several repos.
---

# Adding a skill to PixSmith.Claude

The marketplace lives at `github.com/JothibPixSmith/PixSmith.Claude`. Skills are added **there**, not in the project you're currently working in. If that repo isn't checked out locally, ask the user where it is (commonly a sibling folder, `../PixSmith.Claude`).

## Decide where it goes

- Applies to any stack → `plugins/pixsmith-core/skills/<skill-name>/`
- Specific to an existing stack → `plugins/pixsmith-<stack>/skills/<skill-name>/`
- A new stack → create a new plugin:
  1. `plugins/pixsmith-<stack>/.claude-plugin/plugin.json` (copy an existing one, change `name` and `description`)
  2. Add an entry to `.claude-plugin/marketplace.json` → `plugins`
  3. Add a detection row to `plugins/pixsmith-core/skills/project-onboarding/SKILL.md`
  4. Add it to the plugin table in `README.md`

## Write the skill

Start from `templates/skill/SKILL.md`. Rules:

- `name` is kebab-case and matches the folder name.
- `description` says **what it does and when to use it**, including the trigger phrases a user would actually type. Claude decides whether to load the skill from this line alone.
- The body is instructions for Claude, not docs for humans: imperative, specific, short. Put long reference material in sibling files (`reference.md`, `examples/…`) and link them from SKILL.md so they're only read when needed.
- Capture the *non-obvious* — the rule someone would break, and why. Skip what Claude already knows about the language or framework.
- Nothing project-specific (names of one repo's classes, ports, hosts). That belongs in that repo's CLAUDE.md.
- No secrets, hostnames, or personal data.

## Ship it

1. Bump `version` in the plugin's `plugin.json` (patch for edits, minor for new skills).
2. Run `./scripts/validate.sh`.
3. Commit and push. Projects pick the change up on `/plugin marketplace update pixsmith`.
