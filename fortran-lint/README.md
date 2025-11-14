# GitHub Reusable Workflow to lint fortran using fortitude

## Usage

### Example usage in caller workflow
```yaml
steps:
  - name: Lint Fortran
    uses: MetOffice/growss/.github/workflows/fortan-lint.yaml@main

    with:
       runner: The runner to use for the job (ubuntu-latest)
       timeout: The maximum time in minutes the job can run for (10)
       python-version: The Python version to use (3.14)
```
### Example fortitude configuration
```toml
[check]
select = ["S", "T"]
ignore = ["S001", "S051"]
line-length = 132
```
