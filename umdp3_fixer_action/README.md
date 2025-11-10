# UMDP3 Fixer Action

This action runs the UMDP3 fixer script stored in
[MetOffice/SimSys_Scripts](https://github.com/MetOffice/SimSys_Scripts).

## Usage

```yaml
name: umdp3 Fixer

on:
    pull_request:
        types: [opened, synchronize, reopened]
    workflow_dispatch:

jobs:
    umdp3_fixer:
        uses: MetOffice/growss/.github/workflows/umdp3_fixer.yaml@main
        secrets:
            gh_action_token: ${{ secrets.GITHUB_TOKEN }}

        with:
            # Optional
            runner: 'ubuntu-24.04'
            timeout: 10
```
