# Check CR Approved Action

This action checks that a code reviewer has been assigned to a pull request (via
the pr template) and then checks that that user has approved the PR, failing if
not.
This is to prevent sci tech reviewers accidentally merging without the review
process being finalised.
The intention is for this to be bypassable so it just acts as a reminder and
removes the green commit button before we're ready for it.

## Usage

```yaml
name: Check CR approved

on:
    pull_request:
        types: [opened, synchronize, reopened, edited]
    pull_request_review:
        types: [submitted, edited, dismissed]
    workflow_dispatch:

jobs:
    check_cr_approved:
        uses: MetOffice/growss/.github/workflows/check-cr-approved.yaml@main

```
