# GRoWSS - GitHub Reusable Workflows for Simulation Systems :recycle:

Placeholder for a collection of
[reusable workflows](https://docs.github.com/en/actions/learn-github-actions/reusing-workflows)
for the Met Office Simulation Systems Repositories.

## CLA Check

A reusable action to test that a contributor has agreed to a CLA by adding their
username to the CONTRIBUTORS file in that repository.

### Usage

```yaml
name: CLA Check

on:
    pull_request:
        types: [opened, synchronize, reopened]
    workflow_dispatch:

jobs:
    cla_check:
        uses: MetOffice/growss/.github/workflows/cla-check.yaml@main

        # Optional
        with:
            runner: 'ubuntu-24.04'
```
