# Track Review Project Action

This action modifies the Simulation Systems Review Tracker project entries in
pull requests. It will automatically fill the reviewer fields based on the
entries in the pull request template. It will change the state based on reviews
requested and performed. If a CR hasn't been requested, it will do so when
moving to the CR state. It will also add the PR author as an assignee if none
exist.

It requires a PAT with permissions to write to projects to be added as a secret
to the repository - the default name of this secret is `PROJECT_ACTION_PAT` but
this can be overridden with the `project_pat` input. Project edits made using
this token will be shown as performed by the owner of the token.

## Usage

```yaml
name: Track Review Project

on:
  pull_request:
    types: ["opened", "synchronize", "reopened", "edited", "review_requested", "review_request_removed"]
  pull_request_review:
  pull_request_review_comment:
  workflow_dispatch:

jobs:
  track_review_project:
    uses: MetOffice/growss/.github/workflows/track-review-project.yaml@main
    # Optional inputs (with default values)
    with:
      runner: "ubuntu-22.04"
      project_secret: "PROJECT_ACTION_PAT"
```
