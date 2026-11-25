---
name: project-onboarding
description: Set up a project to use the PixSmith skills marketplace — detect its stack, enable the matching pixsmith-* plugins in .claude/settings.json, and create or refresh CLAUDE.md. Use when starting work in a new or un-configured repo, or when asked to "set up Claude", "onboard this project", or "enable the PixSmith skills".
---

# Project onboarding

Wire a repository up to the PixSmith marketplace so the right skills load automatically for everyone who opens it.

## 1. Detect the stack

Look at the repo root and one or two levels down (skip `node_modules`, `bin`, `obj`, `.esphome`, `.git`):

| Signal | Plugin |
|---|---|
| always | `pixsmith-core` |
| `*.sln`, `*.slnx`, `*.csproj`, `global.json` | `pixsmith-dotnet` |
| `Dockerfile`, `docker-compose*.yml`, `compose*.yaml`, `Containerfile` | `pixsmith-containers` |
| YAML containing a top-level `esphome:` key, or a `.esphome/` dir | `pixsmith-esphome` |

If a stack is present that no plugin covers yet, mention it — it may deserve a new plugin in the PixSmith.Claude repo (see the `new-skill` skill).

## 2. Write `.claude/settings.json`

Merge (never overwrite) these keys into the project's **shared** `.claude/settings.json` — not `settings.local.json`, which is per-user and usually git-ignored:

```json
{
  "extraKnownMarketplaces": {
    "pixsmith": {
      "source": { "source": "github", "repo": "JothibPixSmith/PixSmith.Claude" }
    }
  },
  "enabledPlugins": {
    "pixsmith-core@pixsmith": true,
    "pixsmith-dotnet@pixsmith": true
  }
}
```

Only list the plugins detected in step 1. If the file already has other keys (permissions, hooks, env), keep them.

## 3. Enforce code style

For the detected languages, apply the "Enforce it in the project" sections of these skills:
- `always-use-braces`: `.editorconfig` + `EnforceCodeStyleInBuild` for .NET, ESLint `curly` for JS/TS.
- `always-await`: typescript-eslint async rules for JS/TS. For .NET, CS1998/CS4014 as errors, with opposing analyzers turned off and test projects exempt.

Merge into any existing config rather than replacing it.

## 4. CLAUDE.md

- If none exists, create one with: **Commands** (build, run, test — verified by reading scripts/project files, not guessed), **Architecture** (layers, key projects, dependency direction), and **Key design points** (the non-obvious rules a newcomer would break).
- If one exists, don't rewrite it. Only suggest additions.
- Keep stack-generic guidance *out* of CLAUDE.md — that belongs in the skills. CLAUDE.md is for what is specific to this repo.

## 5. Report

Tell the user which plugins you enabled and why, and that collaborators will be prompted to trust the `pixsmith` marketplace the first time they open the project.
