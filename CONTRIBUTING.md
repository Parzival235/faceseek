# Contributing to FaceSeek

Thanks for your interest in contributing! This project is built in public as part of a 100-day coding challenge.

---

## ⚠️ Ethical Requirements

Before contributing, you **must** agree to the [DISCLAIMER](DISCLAIMER.md). All contributions must:

- Not facilitate unauthorized identification or tracking of individuals
- Not bypass or weaken the ethical use checks in the app
- Respect user privacy at all times

Any PR that violates these principles will be closed immediately.

---

## 🛠️ How to Contribute

### Reporting Bugs

1. Check [existing issues](../../issues) first to avoid duplicates
2. Open a new issue with the `bug` label
3. Include:
   - Flutter version (`flutter --version`)
   - Device / OS
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if possible

### Suggesting Features

1. Open an issue with the `enhancement` label
2. Describe the feature and **why** it fits the project's purpose
3. Wait for discussion before opening a PR

### Submitting Code

1. Fork the repo
2. Create a branch: `git checkout -b feat/your-feature-name`
3. Follow the code style below
4. Commit with clear messages (see convention below)
5. Open a Pull Request against `main`

---

## 📝 Commit Convention

Use this format:

```
type: short description

Examples:
feat: add face crop preview screen
fix: resolve ML Kit crash on Android 12
chore: update dependencies
ui: improve dark theme contrast
docs: update README roadmap
```

Types: `feat` `fix` `ui` `chore` `docs` `refactor` `test`

---

## 🎨 Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter analyze` before submitting — zero warnings
- Use `const` constructors wherever possible
- Keep widgets small and single-responsibility
- No hardcoded strings — use constants

---

## 📦 Branch Structure

| Branch | Purpose |
|---|---|
| `main` | Stable, deployable code |
| `feat/*` | New features |
| `fix/*` | Bug fixes |
| `day-XX` | Daily build commits |

---

## 🚫 What Will Be Rejected

- Code that removes or weakens the disclaimer/ethical use checks
- Features that enable bulk face scraping or surveillance
- API keys or secrets committed to the repo
- Code with zero tests for critical logic (Day 50+)

---

## 📄 License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
