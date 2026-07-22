# Track Review Project Action

This action modifies the Simulation Systems Review Tracker project (376) entries
in pull requests. It will automatically fill the reviewer fields based on the
entries in the pull request template. It will change the state based on reviews
requested and performed. If a CR hasn't been requested, it will do so when
moving to the CR state. It will also add the PR author as an assignee if none
exist.

In order for this to work with forks when reviews are completed, a triggering
workflow is also required. This can be shown by the "Trigger Project Workflow"
yaml file below. The "Track Action Project" workflow is triggered by this
workflow via github "workflow_run" syntax.

It requires a PAT with permissions to write to projects to be added as a secret
to the repository with the name `PROJECT_ACTION_PAT`. Project edits made using
this token will be shown as performed by the owner of the token.

## Usage

```yaml
name: Track Review Project

on:
  workflow_run:
    workflows: [Trigger Review Project]
    types:
      - completed
  workflow_dispatch:

permissions:
  contents: read

jobs:
  track_review_project:
    permissions:
      actions: read
      contents: read
      pull-requests: write
    uses: MetOffice/growss/.github/workflows/track-review-project.yaml@main
    secrets:
      PROJECT_ACTION_PAT: ${{ secrets.PROJECT_ACTION_PAT }}
    # Optional inputs (with default values)
    with:
      runner: "ubuntu-24.04"
      project_org: "MetOffice"
      project_number: 376

```

```yaml
name: Trigger Review Project

on:
  pull_request_target:
    types: ["opened", "synchronize", "reopened", "edited", "review_requested", "review_request_removed", "closed"]
  pull_request_review:
  pull_request_review_comment:

permissions:
  contents: read

jobs:
  trigger_project_workflow:
    # Only run on upstream repository
    if: github.repository == 'MetOffice/<repo-name>'    
    permissions:
      actions: read  # Required to evaluate the event trigger metadata safely
      contents: read  # Required to check out code or parse files safely
      pull-requests: write  # Required for the downstream engine to add comments or update metadata on the PR
    uses: MetOffice/growss/.github/workflows/trigger-project-workflow.yaml@main    
```
