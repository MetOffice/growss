# GitHub Reusable Workflow to lint fortran using fortitude

This reusable workflow serves as a a generic workflow to lint fortran
code using the fotitude linter.

## Usage

By default this workflow will check all the rules included in fortitude linter.
However, should you wish to check only a certain set of rules in your local repository
you can do this by implementing a `fortitude.toml` file in the top-level/root directory
of your local repository, defining the rules which should be checked when running this
reusable workflow from a caller workflow. The following toml file is an example of
what your `fortitude.toml` file could look like:

### Example fortitude configuration
```toml
[check]
select = ["S", "T"]
ignore = ["S001", "S051"]
line-length = 132
```
In order to use this reusable workflow you should implement a calling workflow as
a YAML file in your `.github/workflows` directory containing the follwing:

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

Where runner,timeout and python-version are all appropriately defined inputs
to the workflow as defined in `MetOffice/growss/.github/workflows/fortan-lint.yaml` 
