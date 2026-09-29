# Validate Symlinks

This workflow will look for broken symlinks in the calling repository, raising
an error and listing details if these exist.

## Usage

```yaml
name: Validate Symlinks

on:
  pull_request:
    types: [opened, synchronize, reopened]
  workflow_dispatch:

jobs:
  validate_symlinks:
    uses: MetOffice/growss/.github/workflows/validate_symlinks.yaml@main
    # Optional non default inputs
    with:
      runner: "ubuntu-latest"
      timeout: 10
```
