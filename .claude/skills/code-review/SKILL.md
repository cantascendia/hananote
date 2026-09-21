---
name: code-review
description: Comprehensive code review for HanaNote Flutter project with security focus
---

# Code Review Skill

## When to Use
After completing any feature or significant code change, run this review.

## Review Dimensions

### 1. Security Audit (HIGHEST PRIORITY)
- [ ] No plaintext data written to disk
- [ ] No system photo gallery access
- [ ] No sensitive data in logs or error messages
- [ ] All file writes go through CryptoEngine
- [ ] Encryption keys only in Keychain/KeyStore
- [ ] Notification text contains no health/drug info
- [ ] No hardcoded secrets or keys

### 2. Architecture Compliance
- [ ] Clean Architecture layers respected (no upward dependencies)
- [ ] Feature modules don't import each other's data layers
- [ ] Domain entities have no external package dependencies
- [ ] Repository pattern properly implemented
- [ ] BLoC/Cubit properly manages state lifecycle

### 3. Code Quality
- [ ] Functions ≤ 30 lines
- [ ] Files ≤ 300 lines
- [ ] All public APIs documented with dartdoc
- [ ] No `dynamic` types (except JSON parsing)
- [ ] Null safety properly handled
- [ ] No magic numbers — use named constants
- [ ] Proper use of sealed classes for exhaustive matching

### 4. Testing
- [ ] All domain logic has unit tests
- [ ] All BLoC state transitions tested
- [ ] Edge cases covered (empty data, error states, boundary values)
- [ ] Test file structure mirrors source

### 5. Localization
- [ ] No hardcoded user-facing strings
- [ ] All new strings added to all ARB files (zh, ja, en)

### 6. Performance
- [ ] Heavy crypto operations use Isolate
- [ ] No unnecessary rebuilds in widget tree
- [ ] Database queries are indexed for common access patterns

## Output Format
For each issue found:
- **[SECURITY/ARCH/QUALITY/TEST/L10N/PERF]** severity: description → fix suggestion
