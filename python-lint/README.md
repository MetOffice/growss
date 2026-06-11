# Python Lint Workflow

A reusable GitHub Actions [workflow](../.github/workflows/python-lint.yaml)
that performs Fortran code linting using the
[Ruff](https://github.com/astral-sh/ruff) linter.

## Usage

### Basic Usage

This section provides instructions on how to use the python-lint tool in its
most common scenarios. The basic workflow includes running the linter on Python
source files to check for style violations, code quality issues, and potential
errors.

```yaml
name: Lint Python Code
on:
  pull_request:
  push:
    branches:
      - main
jobs:
  fortran-lint:
    uses: MetOffice/growss/.github/workflows/python-lint.yaml@main
```

### Advanced Usage

This section demonstrates how to customize the Python linting workflow using
the available input parameters for more specific use cases.

#### Custom Runner and Timeout

Use a self-hosted runner with an extended timeout for larger codebases:

```yaml
jobs:
  python-lint:
    uses: MetOffice/growss/.github/workflows/python-lint.yaml@main
    with:
      runner: self-hosted
      timeout: 30
```

#### Specific Ruff Version

Pin to a specific version of Ruff for reproducible linting results:

```yaml
jobs:
  python-lint:
    uses: MetOffice/growss/.github/workflows/python-lint.yaml@main
    with:
      ruff-version: '0.14.0'
```

#### Custom Source Path

Lint Python code in a specific directory (e.g., when Python code is in a
subdirectory):

```yaml
jobs:
  python-lint:
    uses: MetOffice/growss/.github/workflows/python-lint.yaml@main
    with:
      source-path: 'src/python'
```

#### Non-Blocking Lint Checks

Allow the workflow to continue even if linting errors are found (useful for
gradual adoption or reporting-only mode):

```yaml
jobs:
  python-lint:
    uses: MetOffice/growss/.github/workflows/python-lint.yaml@main
    with:
      fail-on-error: false
```

#### Combined Configuration

Example combining multiple parameters for a complex setup:

```yaml
jobs:
  python-lint:
    uses: MetOffice/growss/.github/workflows/python-lint.yaml@main
    with:
      runner: ubuntu-latest
      timeout: 20
      ruff-version: '0.15.0'
      source-path: 'lib/python'
      fail-on-error: true
```

## Input Parameters
| Parameter           | Description                             | Required | Default                         | Type    |
| ------------------- | --------------------------------------- | -------- | ------------------------------- | ------- |
| `runner`            | The runner to use for the job           | No       | `ubuntu-latest`                 | string  |
| `timeout`           | Maximum time in minutes the job can run | No       | `10`                            | number  |
| `ruff-version`      | Ruff linter version                     | No       | `0.15.0`                        | string  |
| `source-path`       | Path to source code directory           | No       | `.`                             | string  |
| `fail-on-error`     | Fail workflow on linting errors         | No       | `true`                          | boolean |

## About Ruff

[Ruff](https://github.com/astral-sh/ruff) is a modern Python linter
that helps maintain code quality and consistency.

## License

&copy; Crown copyright Met Office. See LICENCE file for details.
