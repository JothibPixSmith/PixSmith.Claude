---
name: dotnet-testing
description: Write and run .NET tests the PixSmith way — xUnit with FluentAssertions and Moq for unit tests, WebApplicationFactory for integration tests, Reqnroll for BDD feature specs, Selenium for UI tests, FakeTimeProvider for time. Use when adding or fixing tests in a .NET solution, or when asked to cover a change with tests.
---

# .NET testing

## Projects

| Project | Purpose | Key packages |
|---|---|---|
| `*.UnitTests` | Domain and service logic in isolation | xunit, FluentAssertions, Moq, Microsoft.Extensions.TimeProvider.Testing |
| `*.IntegrationTests` | Real HTTP pipeline + database | Microsoft.AspNetCore.Mvc.Testing, Microsoft.EntityFrameworkCore.Sqlite, Reqnroll.xUnit |
| `*.UITests` | Browser flows | Selenium.WebDriver, Selenium.Support |

Match the packages and versions already in the solution before adding new ones.

## Unit tests

- One test class per class under test; method names `Method_Scenario_ExpectedResult`.
- Arrange / Act / Assert, separated by blank lines.
- Assert with FluentAssertions (`result.IsSuccess.Should().BeTrue()`, `.Should().BeEquivalentTo(...)`), not `Assert.*`.
- Mock only across a boundary you own an interface for (repositories, clock, email). Don't mock the type under test or simple value objects.
- Time: inject `TimeProvider`; in tests use `FakeTimeProvider` and `Advance(...)`. Never `Thread.Sleep` / `Task.Delay` to wait for time to pass.
- For `Result<T>` APIs, test both the success and each failure path.

## Integration tests

- Use a shared `WebApplicationFactory<Program>` subclass (fixture via `IClassFixture<>` or a collection). Override configuration and services there, not in each test.
- Prefer driving real flows over shortcuts. If a helper bypasses production code (e.g. writes directly to a store instead of calling the API), document that in the helper and make sure that production path has its own coverage.
- SQLite in-memory needs an open connection held for the factory's lifetime, or the database disappears.
- Each test creates the data it needs; don't depend on test order.
- Assert on status code **and** body; for security-sensitive endpoints also assert that what *shouldn't* differ doesn't (e.g. identical responses for existing vs. non-existing accounts).

## Reqnroll (BDD)

- `.feature` files describe behaviour in domain language; step definitions stay thin and call shared drivers/helpers.
- Reuse steps; search existing step bindings before adding a new one with similar wording.
- `reqnroll.json` holds config; the MSBuild generator produces code-behind, so don't hand-edit generated files.

## Running

```bash
dotnet test                                         # everything
dotnet test tests/<Project>                         # one project
dotnet test --filter "FullyQualifiedName~UserService"
dotnet test --collect:"XPlat Code Coverage"         # coverlet
```

UI tests need a running app and a browser/driver; skip them unless asked, and say you skipped them.

When reporting, state exactly which test projects ran and their pass/fail counts.
