UMDP3 Fixer Action
==================

This action runs the UMDP3 fixer script stored in
[MetOffice/SimSys_Scripts](https://github.com/MetOffice/SimSys_Scripts).

It can be called with the following yaml:

```yaml
name: umdp3 Fixer

on:
    pull_request:
        types: [opened, synchronize, reopened]
    workflow_dispatch:

jobs:
    umdp3_fixer:
        uses: MetOffice/growss/umdp3_fixer_action/umdp3_fixer.yaml@main
```
