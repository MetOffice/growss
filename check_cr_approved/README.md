# Check CR Approved Action

This action checks that a code reviewer has been assigned to a pull request (via
the pr template) and then checks that that user has approved the PR, failing if
not.
This is to prevent sci tech reviewers accidentally merging without the review
process being finalised.
The intention is for this to be a failure that reviewers can bypass so that for
trivial tickets it doesn't need to be fulfilled.

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
