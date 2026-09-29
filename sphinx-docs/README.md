# Build Sphinx Documentation and Deploy to GitHub Pages

A reusable GitHub Actions [workflow](../.github/workflows/sphinx-docs.yaml) that
builds [Sphinx documentation](https://www.sphinx-doc.org/) and optionally
deploys it to GitHub Pages.

## Features

- Auto-detects dependencies from `conf.py` (highest priority), falling back to
  `pyproject.toml` in the docs tree, then the repo root
- Supports forcing `pyproject.toml` resolution via `use-pyproject: true`,
  bypassing `conf.py` entirely — useful when dependencies are already declared
  under `[project.optional-dependencies]` or `[dependency-groups]`
- When resolving from `conf.py`, detects packages from both `extensions` and
  `html_theme`
- Lints documentation source with
  [`sphinx-lint`](https://github.com/sphinx-contrib/sphinx-lint)
- Uses `make html` if a `Makefile` is present in the docs directory, otherwise
  falls back to `sphinx-build`
- Automatically appends `-v --show-traceback` to Sphinx invocations when the
  [GitHub Actions runner debug mode](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/enabling-debug-logging)
  is active (`ACTIONS_RUNNER_DEBUG=true`)
- Deploys to GitHub Pages **only on pushes to the upstream `main` branch** —
  never from forks or pull requests

## Platform Support

The workflow is compatible with `ubuntu-*` and `macos-*` GitHub Actions
runners, where [`yq`](https://github.com/mikefarah/yq) and `bash` are
pre-installed.

> [!WARNING]
> This workflow is **not natively supported** on Windows runners (`windows-*`).

## Supported Directory Layouts

### Typical layout (default)

```text
repo/
├── pyproject.toml        # optional — used if no conf.py found, or forced via use-pyproject
├── src/
└── docs/
    ├── Makefile          # optional
    └── source/
        ├── conf.py       # highest priority for dependency resolution
        └── index.rst
```

Use with defaults — no input overrides required:

```yaml
jobs:
    docs:
        uses: MetOffice/growss/.github/workflows/sphinx-docs.yaml@main
```

### Flat docs layout

```text
repo/
├── pyproject.toml        # optional — used if no conf.py found, or forced via use-pyproject
└── docs/
    ├── Makefile          # optional
    ├── conf.py           # highest priority for dependency resolution
    └── index.rst
```

Override `source-dir` to point to `docs`:

```yaml
jobs:
    docs:
        uses: MetOffice/growss/.github/workflows/sphinx-docs.yaml@main
        with:
            source-dir: docs
```

## Inputs

| Input             | Description                                                                                                        | Required | Default                                                                          |
| ----------------- | ------------------------------------------------------------------------------------------------------------------ | -------- | -------------------------------------------------------------------------------- |
| `python-version`  | Python version to use                                                                                              | No       | `3.12`                                                                           |
| `venv-path`       | Virtual environment path                                                                                           | No       | `.venv`                                                                          |
| `runner`          | GitHub Actions runner                                                                                              | No       | `ubuntu-24.04`                                                                   |
| `timeout-minutes` | Job timeout in minutes                                                                                             | No       | `10`                                                                             |
| `sphinx-options`  | Additional options passed to `sphinx-build` or `make` via `SPHINXOPTS`                                             | No       | `--jobs auto --write-all --fresh-env --nitpicky --fail-on-warnings --keep-going` |
| `deploy`          | Whether to deploy to GitHub Pages                                                                                  | No       | `true`                                                                           |
| `docs-dir`        | Path to the docs directory where `Makefile` lives                                                                  | No       | `docs`                                                                           |
| `source-dir`      | Path to the Sphinx source directory where `conf.py` lives                                                          | No       | `docs/source`                                                                    |
| `build-dir`       | Sphinx build output directory (relative to `docs-dir`)                                                             | No       | `_build`                                                                         |
| `use-pyproject`   | Force `pyproject.toml` resolution, skipping `conf.py` entirely                                                     | No       | `false`                                                                          |
| `extras`          | Optional dependency extra or group name to pass to `uv sync` (see [Dependency Resolution](#dependency-resolution)) | No       | `''`                                                                             |

## Outputs

| Output      | Description                           |
| ----------- | ------------------------------------- |
| `pages-url` | URL of the deployed GitHub Pages site |

## Permissions

The calling workflow must grant the following permissions:

```yaml
permissions:
    contents: read
    pages: write
    id-token: write
```

## Usage Examples

### Minimal — build and deploy on push to `main`

```yaml
name: Docs

on:
    push:
        branches: [main]

jobs:
    docs:
        uses: MetOffice/growss/.github/workflows/sphinx-docs.yaml@main
        permissions:
            contents: read
            pages: write
            id-token: write
```

### Full — build on PRs, deploy only when merged to `main`

```yaml
name: Docs

on:
    push:
        branches: [main]
    pull_request:
        types: [opened, reopened, synchronize]
    workflow_dispatch:

concurrency:
    group: ${{ github.workflow }}-${{ github.ref }}
    cancel-in-progress: true

jobs:
    docs:
        uses: MetOffice/growss/.github/workflows/sphinx-docs.yaml@main
        with:
            python-version: "3.12"
            runner: ubuntu-24.04
            timeout-minutes: 10
            docs-dir: docs
            source-dir: docs/source
            build-dir: _build
        permissions:
            contents: read
            pages: write
            id-token: write
```

> **Note:** You do not need to pass `deploy: ${{ github.ref_name == 'main' }}`
> yourself. The workflow enforces deployment guards internally — it will only
> deploy when **all** of the following are true:
>
> - `deploy` input is `true` (the default)
> - The ref is exactly `refs/heads/main`
> - The run is on the **upstream** repository, not a fork
> - The event is **not** a `pull_request`

### Force `pyproject.toml` with optional dependencies

Use this when Sphinx dependencies are declared under
`[project.optional-dependencies]` in your `pyproject.toml`:

```toml
# pyproject.toml
[project.optional-dependencies]
docs = [
    "sphinx",
    "furo",
    "myst-parser",
    "sphinx-copybutton",
]
```

```yaml
jobs:
    docs:
        uses: MetOffice/growss/.github/workflows/sphinx-docs.yaml@main
        with:
            use-pyproject: true
            extras: docs # → uv sync --extra docs
        permissions:
            contents: read
            pages: write
            id-token: write
```

### Force `pyproject.toml` with a dependency group (PEP 735)

Use this when dependencies are declared under `[dependency-groups]`:

```toml
# pyproject.toml
[dependency-groups]
docs = [
    "sphinx",
    "furo",
    "myst-parser",
    "sphinx-copybutton",
]
```

```yaml
jobs:
    docs:
        uses: MetOffice/growss/.github/workflows/sphinx-docs.yaml@main
        with:
            use-pyproject: true
            extras: docs # → uv sync --group docs
        permissions:
            contents: read
            pages: write
            id-token: write
```

The workflow automatically inspects `pyproject.toml` to determine whether
`extras` refers to an optional-dependency extra (`--extra`) or a dependency
group (`--group`) and sets the correct `uv sync` flag. If the name is not found
in either section, a warning is emitted and plain `uv sync` is run.

### Build only, no deployment

```yaml
jobs:
    docs:
        uses: MetOffice/growss/.github/workflows/sphinx-docs.yaml@main
        with:
            deploy: false
        permissions:
            contents: read
            pages: write
            id-token: write
```

### Use the deployed URL in a downstream job

```yaml
jobs:
    docs:
        uses: MetOffice/growss/.github/workflows/sphinx-docs.yaml@main
        permissions:
            contents: read
            pages: write
            id-token: write

    notify:
        needs: docs
        runs-on: ubuntu-24.04
        steps:
            - run: echo "Docs published at ${{ needs.docs.outputs.pages-url }}"
```

## Dependency Resolution

Dependencies are resolved in the following order of precedence:

| Priority | Condition                                                | Action                                                                            |
| -------- | -------------------------------------------------------- | --------------------------------------------------------------------------------- |
| —        | `use-pyproject: true` + `pyproject.toml` in `docs-dir`   | Run `uv sync [flags]` from `docs-dir`; skip `conf.py`                             |
| —        | `use-pyproject: true` + `pyproject.toml` in `source-dir` | Run `uv sync [flags]` from `source-dir`; skip `conf.py`                           |
| —        | `use-pyproject: true` + `pyproject.toml` at root         | Run `uv sync [flags]` from repo root; skip `conf.py`                              |
| —        | `use-pyproject: true` + no `pyproject.toml` found        | **Fails** with an error                                                           |
| 1        | `conf.py` found in `source-dir` (default)                | Parse `extensions` and `html_theme`; install mapped packages via `uv pip install` |
| 2        | `pyproject.toml` found in `docs-dir`                     | Run `uv sync [flags]` from `docs-dir`                                             |
| 3        | `pyproject.toml` found in `source-dir`                   | Run `uv sync [flags]` from `source-dir`                                           |
| 4        | `pyproject.toml` found at repo root                      | Run `uv sync [flags]` from repo root                                              |
| —        | None of the above                                        | **Fails** with an error                                                           |

### `extras` and `uv sync` flags

When `extras` is set and a `pyproject.toml` is used, the workflow inspects the
file to determine the correct `uv sync` flag:

| Section in `pyproject.toml`       | `uv sync` flag emitted               |
| --------------------------------- | ------------------------------------ |
| `[project.optional-dependencies]` | `--extra <extras>`                   |
| `[dependency-groups]` (PEP 735)   | `--group <extras>`                   |
| Not found in either               | _(plain `uv sync`, warning emitted)_ |

### `conf.py` parsing

When `conf.py` is used as the dependency source, the workflow extracts packages
from two variables:

- **`extensions`** — each entry is looked up in a built-in mapping of known
  Sphinx extension module names to PyPI package names. Unknown third-party
  extensions not in the mapping are included using a best-effort guess derived
  from the module root (e.g. `my_ext.sub` → `my-ext`). Built-in `sphinx.ext.*`
  extensions are always skipped as they are bundled with Sphinx.
- **`html_theme`** — the theme name is looked up in a built-in mapping of known
  theme names to PyPI package names. Built-in Sphinx themes (e.g. `alabaster`,
  `classic`) are skipped. Unknown themes are included using a best-effort guess
  (e.g. `my_theme` → `my-theme`).

`sphinx` and `sphinx-lint` are always installed regardless of `conf.py` content.

### Deployment guards

The `deploy` input enables deployment intent, but the workflow enforces the
following additional conditions internally to prevent accidental deployments
from forks or pull requests:

| Condition                                                | Purpose                                                 |
| -------------------------------------------------------- | ------------------------------------------------------- |
| `deploy` input is `true`                                 | Caller opt-in                                           |
| `github.ref == 'refs/heads/main'`                        | Exact ref match — rules out all other branches and tags |
| `github.repository == github.event.repository.full_name` | Upstream repo only — excludes forks                     |
| `github.event_name != 'pull_request'`                    | Belt-and-braces guard against PR events                 |

## Licence

&copy; Crown copyright Met Office. See [LICENCE](../LICENCE) file for details.
