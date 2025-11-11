# CLA Check

A reusable action to test that a contributor has agreed to a CLA by adding their
username to the CONTRIBUTORS file in that repository.

## Usage

```yaml
name: CLA Check

on:
    pull_request_target:

jobs:
    cla_check:
        uses: MetOffice/growss/.github/workflows/cla-check.yaml@main

        # Optional
        with:
            runner: 'ubuntu-24.04'
```
