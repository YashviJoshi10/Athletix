# Contributing to Athletix

First off, thank you for considering contributing to Athletix! 🙌

---

## Getting Started

1. **Fork the repository**: [Fork the repo from here](https://github.com/vjlive/athletix/fork)


2. **Clone your fork into your system**

```bash
git clone https://github.com/<your-username>/athletix.git
cd athletix
```

3. **Set up the project**

   * Follow the [Development Guide](./DEVELOPMENT.md) to install and run locally.

---

## Contributing Guidelines

### Project Setup Instructions

* Install dependencies:

```bash
flutter pub get
```

* Run the application:

```bash
flutter run
```

- It is recommended to use your physical mobile for development. 

### Branching Strategy

* Always branch out from `main`:

```bash
git checkout -b feat/your-feature-name
```

* Use these prefixes for your branches:

| Type    | Prefix   |
| ------- | -------- |
| Feature | `feat/`  |
| Fix     | `fix/`   |
| Docs    | `docs/`  |
| Chore   | `chore/` |

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```bash
git commit -m "feat(component): add navbar component"
```

### Pull Request Process

* Ensure your PR includes a clear title and description.
* Link to any relevant issues.
* Add screenshots or demos if applicable.
* PRs should:

  * Be reviewed by at least one maintainer
  * Be rebased or merged cleanly with `main`

---

## How to File a Bug

* Open an [issue](https://github.com/vjlive/athletix/issues)
* Choose **Bug Report** template
* Include:

  * Steps to reproduce
  * Expected vs actual behavior
  * Screenshots or logs if helpful

---

## Pull Request Checklist

Before submitting your pull request, please ensure the following:

* [ ] **Clear title and description** that explain what the PR does
* [ ] **Follows the branching strategy** (`feat/`, `fix/`, etc.) and **uses Conventional Commits**
* [ ] Includes **tests** or **relevant usage examples**, if applicable
* [ ] All **new/updated components are documented**
* [ ] Screenshots/demos included (for UI changes)
* [ ] Linked to a related **issue** (if one exists)
* [ ] PR is up-to-date with the `main` branch (`git pull origin main` before pushing)
* [ ] Ready for review: tagged with appropriate labels (e.g., `enhancement`, `bug`, `docs`)
* [ ] Reviewed and approved by at least one maintainer

---

## Useful Resources

* [Flutter Documentation](https://docs.flutter.dev/)
* [Firebase Documentation](https://firebase.google.com/docs)
* [Conventional Commits Guide](https://www.conventionalcommits.org/en/v1.0.0/)
* [Open Source Guide](https://opensource.guide/how-to-contribute/)

---

## Code of Conduct

We follow the [Contributor Covenant Code of Conduct](./CODE_OF_CONDUCT.md). Be respectful, inclusive, and collaborative in all contributions.

---

Let’s build something great together!
