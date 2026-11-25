---
name: always-await
description: Mandatory async rule. Never return a Task/ValueTask (C#) or Promise (JS/TS) directly. Every method that returns one is marked async and awaits its work, including `return await`. Test code is exempt. Use whenever writing, editing, refactoring or reviewing asynchronous code in C#, JavaScript or TypeScript, and when setting up analyzers or ESLint for a project.
---

# Always async/await

A task or promise is never passed back unawaited. If a method returns `Task`, `Task<T>`, `ValueTask`, `ValueTask<T>` (C#) or `Promise<T>` (JS/TS), it is `async` and it `await`s. This rule is **not optional**, even where eliding `async` would save an allocation.

## The rule

```csharp
// ❌ Never: returning the task directly
public Task<User?> GetUserAsync(Guid id) => _repository.GetByIdAsync(id);

public Task<User?> GetUserAsync(Guid id)
{
    return _repository.GetByIdAsync(id);
}

// ✅ Always
public async Task<User?> GetUserAsync(Guid id)
{
    return await _repository.GetByIdAsync(id);
}
```

```ts
// ❌ Never
function getUser(id: string): Promise<User> {
  return api.get(`/users/${id}`);
}

// ✅ Always
async function getUser(id: string): Promise<User> {
  return await api.get(`/users/${id}`);
}
```

Details:
- **`return await` is required.** Never write `return SomethingAsync();` inside an async method.
- **A method with a Task/Promise return type is `async` and contains `await`.** Never hand back `Task.FromResult`, `Task.CompletedTask`, `Promise.resolve` or `.then(...)` chains as the return value.
- **Prefer `await` over `.then()`/`.catch()`/`ContinueWith`.** Use `try`/`catch` around the `await` instead.
- **Never block on async code.** No `.Result`, `.Wait()` or `.GetAwaiter().GetResult()`.
- **No `async void`**, except for UI/event handlers whose signature requires it.
- **Concurrency is fine, but await it.** `return await Task.WhenAll(tasks);` and `return await Promise.all(promises);`.
- **Pass `CancellationToken`s through** when the caller has one.

## When there is no asynchronous work

A method that has a Task/Promise return type but nothing to await **becomes synchronous**. Change its return type to the plain value (`Task<T>` → `T`, `Task` → `void`, `Promise<T>` → `T`), drop `async`, drop the `Async` suffix, and update every caller.

**Exception: other implementations of the same contract are really async.** For example, `IUserStore` has a database implementation that awaits and an in-memory one that doesn't. Don't force the sync implementation to fake async, and don't force the async ones to go sync. Give the contract **both versions**:

```csharp
public interface IUserStore
{
    User? GetById(Guid id);
    Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
}

// Really async implementation
public sealed class DbUserStore(AppDbContext db) : IUserStore
{
    public User? GetById(Guid id)
    {
        return db.Users.Find(id);                                  // real sync API
    }

    public async Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await db.Users.FindAsync([id], cancellationToken);
    }
}

// Implementation with no async work
public sealed class InMemoryUserStore : IUserStore
{
    private readonly Dictionary<Guid, User> _users = new();

    public User? GetById(Guid id)
    {
        return _users.GetValueOrDefault(id);
    }

    public async Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await Task.FromResult(GetById(id));
    }
}
```

Rules for the pair:
- **Sync implementations:** the real logic lives in the sync method. The async method only wraps it, and `return await Task.FromResult(...)` / `await Task.CompletedTask` is allowed **only** there.
- **Async implementations:** the sync version must call a real synchronous API (`SaveChanges`, `File.ReadAllText`, …). It must **never** block on the async version with `.Result`, `.Wait()` or `.GetAwaiter().GetResult()`. If there is no sync API, stop and tell the user rather than blocking.
- **Callers:** in async code, call the `Async` version. In sync code, call the sync one.
- **Contracts you don't own** (framework interfaces, overrides of library base classes, delegates): you can't add a sync version. Keep the signature, mark the method `async`, and use `await Task.CompletedTask;` / `return await Task.FromResult(value);`.
- **JS/TS:** same approach. Add a sync sibling (`getUser` / `getUserAsync`) to the interface or type. In the sync implementation, `async getUserAsync(id) { return this.getUser(id); }` is enough, because `async` wraps the value automatically.

## Exempt

- **Test code:** anything in test projects (`*.Tests`, `*.UnitTests`, `*.IntegrationTests`, `*.UITests`) or test files (`*.test.ts`, `*.spec.ts`, `__tests__/`). That includes mock setups such as `.ReturnsAsync(...)` and `.Returns(Task.FromResult(...))`, and test helpers returning tasks.
- **Members with no body:** interface members, abstract members and delegate declarations.

## When editing existing code

- Any async code you write or change follows the rule.
- Convert unawaited task/promise returns in any method you touch.
- Don't rewrite whole untouched files unless asked. List the violations and offer a separate change.
- In code review, report every violation in the diff, outside test code.

## Enforce it in the project

**JS/TS (typescript-eslint, with type-aware linting):**

```js
rules: {
  "@typescript-eslint/promise-function-async": "error",     // Promise-returning functions must be async
  "@typescript-eslint/return-await": ["error", "always"],   // always `return await`
  "@typescript-eslint/require-await": "error",              // async functions must await
  "@typescript-eslint/no-floating-promises": "error",
  "@typescript-eslint/no-misused-promises": "error",
},
overrides: [
  { files: ["**/*.test.*", "**/*.spec.*", "**/__tests__/**"],
    rules: { "@typescript-eslint/promise-function-async": "off",
             "@typescript-eslint/return-await": "off",
             "@typescript-eslint/require-await": "off" } },
]
```

**C# / .NET:** no built-in analyzer enforces "always `return await`", so this skill and code review are what enforce it. You can still:
- Treat CS1998 (async method lacks await) and CS4014 (unawaited call) as errors in `Directory.Build.props`: `<WarningsAsErrors>$(WarningsAsErrors);CS1998;CS4014</WarningsAsErrors>`.
- **Turn off analyzers that recommend the opposite**, if the project uses them: AsyncFixer `AsyncFixer01` and Roslynator `RCS1174` (both "remove unnecessary async/await"). Set them to `none` in `.editorconfig`.
- Keep test projects out of these settings, for example with a `tests/.editorconfig` that relaxes them.
