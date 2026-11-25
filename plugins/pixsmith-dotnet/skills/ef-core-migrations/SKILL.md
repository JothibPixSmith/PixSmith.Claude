---
name: ef-core-migrations
description: Create, apply and review EF Core migrations, including solutions that support several database providers (e.g. SQLite and PostgreSQL) with one migrations project per provider. Use whenever an entity, DbContext configuration, or model changes, or when asked to add/remove/fix a migration.
---

# EF Core migrations

## Multi-provider layout

When a solution supports more than one database provider, each provider has its own migrations assembly:

```
src/PixSmith.<Product>.DataContext/                         DbContext + configuration
src/PixSmith.<Product>.DataContext.Migrations.Sqlite/
src/PixSmith.<Product>.DataContext.Migrations.Postgres/
```

The provider is chosen at runtime from configuration (e.g. `Database:Provider`) and registered with `MigrationsAssembly(...)` pointing at the matching project.

**Every model change needs a migration in *every* provider project.** Generating only one compiles fine and then fails at runtime on the other provider. Always generate both in the same change, with the same migration name.

## Generating

Find the startup project (the API/Web project) and the migrations projects first; read how the provider is selected so you pass the right setting.

```bash
dotnet tool restore            # or: dotnet tool install --global dotnet-ef

dotnet ef migrations add <Name> \
  --project src/PixSmith.<Product>.DataContext.Migrations.Sqlite \
  --startup-project <path/to/API> \
  -- --Database:Provider=Sqlite

dotnet ef migrations add <Name> \
  --project src/PixSmith.<Product>.DataContext.Migrations.Postgres \
  --startup-project <path/to/API> \
  -- --Database:Provider=Postgres
```

(The args after `--` are passed to the app's configuration. If the repo uses an env var or a design-time factory instead, follow that.)

Name migrations in PascalCase describing the change: `AddAuditLogTable`, `MakeEmailUnique`.

## Review every generated migration

- Read the `Up` *and* `Down`. Look for unintended drops — a rename often scaffolds as drop + add and loses data; rewrite it with `RenameColumn`/`RenameTable`.
- Adding a non-nullable column to a populated table needs a default or a data backfill step.
- Compare the two providers' migrations: they should express the same change, differing only in types.
- Check the model snapshot changed as expected and nothing unrelated slipped in (a sign the snapshot was stale).

## Removing / fixing

- Not yet applied anywhere shared: `dotnet ef migrations remove` in **each** provider project.
- Already applied in a shared environment: never edit it; add a new corrective migration.

## Applying

Many PixSmith services call `Database.MigrateAsync()` on startup. If so, there's no manual step — but test it by running the app against each provider (e.g. SQLite locally, Postgres via the compose debug stack). For production-shaped deploys, prefer `dotnet ef migrations bundle` or a script (`dotnet ef migrations script --idempotent`) when startup migration isn't wanted.

## Tests

Integration tests often run on SQLite in-memory. That does not prove the Postgres migration works; say so when reporting, or run against the Postgres container.
