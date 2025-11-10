# CLA Check

A reusable action to test that a contributor has agreed to a CLA by adding their
username to the CONTRIBUTORS file in that repository.

## Usage

```yaml
name: CLA Check

on:
    pull_request:
        types: [opened, synchronize, reopened]
    workflow_dispatch:

jobs:
    cla_check:
        uses: MetOffice/growss/.github/workflows/cla-check.yaml@main
        secrets:
            gh_action_token: ${{ secrets.GITHUB_TOKEN }}

        with:
            # Optional
            runner: 'ubuntu-24.04'
```
