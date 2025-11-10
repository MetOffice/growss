# CLA Check

A reusable action to test that a contributor has agreed to a CLA by adding their
username to the CONTRIBUTORS file in that repository.

## Usage

### Add label

Adds label `bug` to PR/issue no. 1 in `owner/repo` repository.

```yaml
name: CLA Check

on:
    pull_request:
        types: [opened, synchronize, reopened]
    workflow_dispatch:

jobs:
    umdp3_fixer:
        uses: MetOffice/growss/cla_check/cla-check.yaml@main
```
