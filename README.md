# GRoWSS - GitHub Reusable Workflows for Simulation Systems :recycle:

Placeholder for a collection of
[reusable workflows](https://docs.github.com/en/actions/learn-github-actions/reusing-workflows)
for the Met Office Simulation Systems Repositories.

## UMDP3 Fixer Action

This action runs the UMDP3 fixer script stored in
[MetOffice/SimSys_Scripts](https://github.com/MetOffice/SimSys_Scripts).

### Usage

```yaml
name: umdp3 Fixer

on:
    pull_request:
        types: [opened, synchronize, reopened]
    workflow_dispatch:

jobs:
    umdp3_fixer:
        uses: MetOffice/growss/.github/workflows/umdp3_fixer.yaml@main

        # Optional
        with:
            runner: 'ubuntu-24.04'
```
