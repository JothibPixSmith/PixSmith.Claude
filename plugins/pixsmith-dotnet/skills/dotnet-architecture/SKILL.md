---
name: dotnet-architecture
description: PixSmith .NET solution conventions — onion architecture layering, project naming and src/tests layout, Result<T> error handling, nullable and implicit usings. Use when creating a new .NET solution or project, adding a class or service and deciding which layer it belongs in, or reviewing .NET code for layering violations.
---

# .NET architecture conventions

## Layout and naming

```
<Repo>/
├── <Product>.sln | .slnx
├── src/
│   ├── PixSmith.<Product>.Domain/
│   ├── PixSmith.<Product>.Application/      (optional, use cases)
│   ├── PixSmith.<Product>.Infrastructure/
│   ├── PixSmith.<Product>.DataContext/
│   ├── PixSmith.<Product>.Repositories/
│   ├── PixSmith.<Product>.Services/
│   └── PixSmith.<Product>.API | .Web | .Cli/
└── tests/
    ├── PixSmith.<Product>.UnitTests/
    └── PixSmith.<Product>.IntegrationTests/
```

- Every project lives under `src/` or `tests/`; nothing but solution, Docker and docs files at the root.
- Project and root namespace: `PixSmith.<Product>.<Layer>`. If a folder name differs from the project name, note it in the repo's CLAUDE.md.
- Target the current LTS/STS `net*` used by the rest of the solution; don't mix target frameworks without a reason.
- Every project: `<Nullable>enable</Nullable>` and `<ImplicitUsings>enable</ImplicitUsings>`. Treat nullable warnings as bugs; don't silence them with `!` without a comment explaining why it's safe.

## Dependency direction (strictly inward)

```
Domain ← Application ← Infrastructure ← API/Web/Cli
                    ← DataContext ← Repositories ← Services
```

- **Domain** has zero package references (no EF, no ASP.NET, no Identity). Aggregates, value objects, domain events, `Result<T>`.
- **DataContext** owns the `DbContext` and entity configuration. Migrations live in separate per-provider projects (see `ef-core-migrations`).
- **Repositories** implement interfaces declared closer to the domain; they return domain types, not `IQueryable` or EF entities.
- **Services** orchestrate repositories and domain logic.
- **API/Web** is the composition root: DI registration, middleware, controllers. Controllers are thin — map request → service call → HTTP result.

When asked where something goes, answer by this direction: if it needs a framework type, it can't be in Domain.

## Errors: `Result<T>`, not exceptions

- Domain and service methods that can fail for expected reasons (validation, not found, conflict, forbidden) return `Result<T>` / `Result`.
- Exceptions are for the unexpected (bugs, infrastructure failure).
- Controllers map failures to HTTP status centrally (an extension like `ToActionResult()`), not with ad-hoc `if` chains per action.

## Time, config, and DI

- Inject `TimeProvider` instead of calling `DateTime.UtcNow`, so tests can use `FakeTimeProvider`.
- Bind configuration to options classes (`IOptions<T>`) with validation on start (`ValidateDataAnnotations().ValidateOnStart()`).
- Dangerous development switches must make the app **refuse to start** in Production, not just default to off.

## Commands

```bash
dotnet restore
dotnet build <Solution>.sln
dotnet test
dotnet list package --outdated
dotnet list package --vulnerable --include-transitive
```
