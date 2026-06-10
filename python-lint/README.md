# Python Lint Workflow

A reusable GitHub Actions [workflow](../.github/workflows/python-lint.yaml)
that performs Fortran code linting using the
[Ruff](https://github.com/astral-sh/ruff) linter.

## Features

## Usage

### Basic Usage

### Advanced Usage

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
