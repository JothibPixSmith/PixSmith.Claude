# PixSmith.Claude

Shared [Claude Code](https://claude.com/claude-code) skills for PixSmith projects, published as a **plugin marketplace**. Each project turns on only the plugins for its stack.

## Plugins

| Plugin | Use in | Skills |
|---|---|---|
| `pixsmith-core` | every project | `project-onboarding`, `security-review-checklist`, `new-skill`, `always-use-braces`, `always-await` |
| `pixsmith-dotnet` | .NET / ASP.NET Core / EF Core | `dotnet-architecture`, `ef-core-migrations`, `dotnet-testing` |
| `pixsmith-containers` | Docker / Podman | `container-stacks` |
| `pixsmith-esphome` | ESPHome devices | `esphome-device` |

Claude loads a skill on its own when the task matches the skill's description. You can also call one directly, e.g. `/pixsmith-dotnet:ef-core-migrations`.

## Using it in a project

### Option A: commit it to the project (recommended)

Add this to the project's `.claude/settings.json`, listing only the plugins that project needs:

```json
{
  "extraKnownMarketplaces": {
    "pixsmith": {
      "source": { "source": "github", "repo": "JothibPixSmith/PixSmith.Claude" }
    }
  },
  "enabledPlugins": {
    "pixsmith-core@pixsmith": true,
    "pixsmith-dotnet@pixsmith": true,
    "pixsmith-containers@pixsmith": true
  }
}
```

The first time someone opens the project, Claude Code asks them to trust the marketplace. After that the plugins install automatically.

If `pixsmith-core` is already installed, you can also ask Claude to *"onboard this project"*. The `project-onboarding` skill detects the stack and writes this file for you.

### Option B: install it for yourself

```
/plugin marketplace add JothibPixSmith/PixSmith.Claude
/plugin install pixsmith-core@pixsmith
/plugin install pixsmith-dotnet@pixsmith
```

### Getting updates

```
/plugin marketplace update pixsmith
```

### Working on the skills locally

Point a project at your local checkout instead of GitHub so you can try edits before pushing:

```
/plugin marketplace add ~/Repos/PixSmith.Claude
```

## Layout

```
.claude-plugin/marketplace.json     the plugin catalogue
plugins/<plugin>/
  .claude-plugin/plugin.json        plugin name, version, description
  skills/<skill>/SKILL.md           one folder per skill
templates/skill/SKILL.md            starting point for new skills
scripts/validate.sh                 checks manifests and skill frontmatter
```

## Adding a skill or a stack

See [plugins/pixsmith-core/skills/new-skill/SKILL.md](plugins/pixsmith-core/skills/new-skill/SKILL.md). In short:

- If it applies to any stack, put it in `pixsmith-core`. If it's for one stack, put it in that stack's plugin.
- For a new stack, add a `plugins/pixsmith-<stack>/` folder, add it to `marketplace.json`, add its detection rule to `project-onboarding`, and add it to the table above.
- Bump the plugin's `version`, then run `./scripts/validate.sh`.

Anything that only applies to a single repository belongs in that repository's `CLAUDE.md`, not here.
