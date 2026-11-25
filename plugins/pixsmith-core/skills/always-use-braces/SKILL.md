---
name: always-use-braces
description: Mandatory code style rule — every if, else, else if, for, foreach, while, do, using and lock body is wrapped in braces, even when it is a single statement. Use whenever writing, editing, refactoring or reviewing code in any curly-brace language (C#, Java, JavaScript, TypeScript, C, C++, Go, Rust, PHP, Dart, Kotlin, Swift), and when setting up linters or .editorconfig for a project.
---

# Always use braces

Braces are **never optional**. Every control-flow body gets `{ }`, no matter how short.

## The rule

```csharp
// ❌ Never
if (user is null) return NotFound();

if (user is null)
    return NotFound();

foreach (var item in items) Process(item);

// ✅ Always
if (user is null)
{
    return NotFound();
}

foreach (var item in items)
{
    Process(item);
}
```

It applies to `if`, `else`, `else if`, `for`, `foreach`, `while`, `do`/`while`, and to `using`/`lock`/`fixed` statement bodies. There are no exceptions:
- Guard clauses and early returns get braces too.
- One-line `throw`, `continue`, `break` and `return` get braces too.
- Don't stack `using` statements without braces. Use a `using var x = ...;` declaration or a braced block.
- Use the brace placement the language or repo already uses (Allman for C#, K&R for JS/TS/Java/Go), but never leave the braces out.

Expression-bodied members (`=> expr;`), lambdas, switch expressions and ternaries aren't control-flow statement bodies, so the rule doesn't apply to them.

## When editing existing code

- Any code you write or change must follow the rule.
- If you touch a statement that has no braces, add them.
- Don't reformat whole untouched files just for this unless the user asks. If many violations exist, point them out and offer to fix them in a separate change.
- In code review, report every missing brace in the diff as a finding.

## Enforce it in the project

When setting up or onboarding a project, make the build or linter enforce the rule, not only this skill.

**C# / .NET:** in the repo-root `.editorconfig`:

```ini
[*.cs]
csharp_prefer_braces = true:error
dotnet_diagnostic.IDE0011.severity = error
```

and in `Directory.Build.props` (so the rule fails the build, not just the IDE):

```xml
<PropertyGroup>
  <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
</PropertyGroup>
```

Fix existing violations with `dotnet format style --diagnostics IDE0011`.

**JavaScript / TypeScript (ESLint):** `"curly": ["error", "all"]`. If Prettier is used, keep `eslint-config-prettier`. It doesn't disable `curly` when set to `"all"`.

**Java (Checkstyle):** `NeedBraces` module. **C/C++ (clang-tidy):** `readability-braces-around-statements`. **Go** and **Rust** need braces by syntax.

After adding enforcement, run the build or linter and report how many existing violations it found.
