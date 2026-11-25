---
name: security-review-checklist
description: Stack-agnostic application security checklist for reviewing or writing code that touches authentication, authorization, user input, secrets, or public endpoints. Use when adding an endpoint, handling credentials or tokens, reviewing a PR for security, or responding to pen-test findings.
---

# Security review checklist

Work through the sections relevant to the change. Report concrete findings (file, line, scenario), not generic advice.

## Secrets
- No secrets in source, config committed to git, Dockerfiles, compose files, or logs. Look for `.env`, `secrets.yaml`, `appsettings.*.json`, `*.pfx`, `*.pem`, tokens in test fixtures.
- Secrets come from environment, a secret store, or a git-ignored file — and that file is actually in `.gitignore`.
- Example/template files use obvious placeholders.

## Authentication & sessions
- Passwords only ever reach the component that verifies them. No password grant / no forwarding credentials between services.
- Tokens: short-lived access tokens, validated issuer/audience/signature/expiry. Refresh re-checks that the user is still allowed.
- Lockout or throttling per account **and** rate limiting per client IP per endpoint (one protects an account, the other bounds credential stuffing across accounts).

## Account enumeration
- Login, registration, password reset and "forgot username" return the same response (status, body, and roughly the same timing) whether or not the account exists. Notify the real owner out of band instead.
- Validation errors that disclose nothing about other accounts (e.g. password policy) may still be reported.

## Authorization
- Every endpoint has an explicit policy. Default-deny; anonymous access is opt-in and deliberate.
- Object-level checks: the caller may act on *this* record (tenant, owner, org), not just on this type of record.
- Admin / platform operations are separated from tenant-scoped ones.

## Input & output
- Parameterised queries only; no string-built SQL, shell commands, or file paths from user input.
- Validate size and shape at the boundary; reject rather than sanitize where possible.
- Encode output for its context (HTML, attribute, JS, URL). Prefer a strict CSP; pages that handle credentials should run no third-party script.
- Redirect targets are validated against an allow-list (open redirects).

## Transport & headers
- HTTPS everywhere outside local dev; HSTS in production.
- Cookies: `Secure`, `HttpOnly`, appropriate `SameSite`.
- CORS origins are an explicit list, never reflected.

## Failure modes
- Errors don't leak stack traces, SQL, or internal hostnames to clients.
- Dangerous dev/test switches (e.g. relaxed PKCE, seeded test users) **refuse to start** in Production rather than just being off by default.
- Security-relevant events (login failure, privilege change, client/secret changes) are audit-logged without logging the secret itself.

## Dependencies
- New packages are maintained and pinned; check for known vulnerabilities with the ecosystem's tool (`dotnet list package --vulnerable`, `npm audit`, etc.).
